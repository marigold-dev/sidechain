open Deku_stdlib
open Handlers
open Deku_block_storage
open Api_middlewares
open Deku_network
open Deku_gossip
open Api_state
open Deku_protocol
open Deku_consensus
open Deku_concepts

let make_dump_loop ~sw ~env ~data_folder =
  let resolver_ref = Atomic.make None in
  let domains = Eio.Stdenv.domain_mgr env in

  let rec loop () : unit =
    let promise, resolver = Eio.Promise.create () in
    Atomic.set resolver_ref (Some resolver);
    let current_block, protocol, receipts = Eio.Promise.await promise in
    (try
       Api_state.Api_storage.write ~env ~data_folder ~current_block ~protocol
         ~receipts
     with exn ->
       Logs.err (fun m -> m "api.storage.failure: %s" (Printexc.to_string exn)));
    loop ()
  in
  let dump ~current_block ~protocol ~receipts =
    match Atomic.exchange resolver_ref None with
    | Some resolver ->
        Eio.Promise.resolve resolver (current_block, protocol, receipts)
    | None -> ()
  in
  ( Eio.Fiber.fork_sub ~sw ~on_error:Deku_constants.async_on_error @@ fun _sw ->
    Eio.Domain_manager.run domains (fun () -> loop ()) );
  dump

let save_block ~sw ~indexer ~block =
  let on_error err = print_endline (Printexc.to_string err) in
  (* TODO: better logging *)
  Eio.Fiber.fork_sub ~sw ~on_error @@ fun _sw ->
  Block_storage.save_block ~block indexer

let apply_block ~sw ~state ~block =
  state.current_block <- block;
  save_block ~sw ~indexer:state.indexer ~block;
  let (Block.Block { level; payload; tezos_operations; _ }) = block in
  let (Payload.Payload payload) = Payload.decode ~payload in
  let payload =
    Parallel.map_p
      (fun string ->
        let operation =
          string |> Data_encoding.Binary.of_string_exn Operation.Signed.encoding
        in
        let (Operation.Signed.Signed_operation { initial; _ }) = operation in
        initial)
      payload
  in
  let protocol, receipts, _ =
    Protocol.apply ~current_level:level ~payload ~tezos_operations
      state.protocol
  in
  let receipts =
    List.fold_left
      (fun receipts receipt ->
        let open Receipt in
        let hash =
          match receipt with
          | Ticket_transfer_receipt { operation; _ }
          | Withdraw_receipt { operation; _ }
          | Vm_transaction_receipt { operation; _ } ->
              operation
        in
        Operation_hash.Map.add hash receipt receipts)
      state.receipts receipts
  in
  state.receipts <- receipts;
  (* TODO: how do we clear the list of receipts ?*)
  state.protocol <- protocol;
  state.is_sync <- true;
  state.dump ~current_block:block ~protocol ~receipts

let on_accepted_block ~sw ~state ~block =
  let (Block.Block { level = api_level; _ }) = state.current_block in
  let (Block.Block { level; _ }) = block in
  match Level.equal (Level.next api_level) level with
  | true -> apply_block ~sw ~state ~block
  | false ->
      (*This case should not happened thanks to on_connection*)
      ()

let on_connection ~connection state =
  let (Block.Block { level = api_level; _ }) = state.current_block in
  let (Request.Request { network; _ }) = Request.encode ~above:api_level in
  let (Request.Network.Network_request { raw_header; raw_content }) = network in
  Network_manager.send_request ~connection ~raw_header ~raw_content
    state.network

let on_message ~sw ~raw_header ~raw_content state =
  let header = Message.Header.decode ~raw_header in
  let message = Message.decode ~expected:header ~raw_content in
  let (Message.Message { header = _; content; network = _ }) = message in
  match content with
  | Message.Content.Content_accepted { block; votes = _ } ->
      on_accepted_block ~sw ~state ~block
  | _ -> ()

let listen_to_node ~net ~clock ~port ~state =
  let Api_state.{ network; _ } = state in
  let on_connection ~connection = on_connection state ~connection in
  let on_request ~connection:_ ~raw_header:_ ~raw_content:_ = () in
  let on_message ~raw_header:_ ~raw_content:_ = () in
  let () =
    Network_manager.listen ~net ~clock ~port ~on_connection ~on_request
      ~on_message network
  in
  ()

let start_api ~env ~sw ~port ~state =
  let request_handler =
    cors_middleware @@ no_cache_middleware
    @@ (Server.empty
       |> Server.without_body (module Get_genesis)
       |> Server.without_body (module Get_head)
       |> Server.without_body (module Get_block_by_level_or_hash)
       |> Server.without_body (module Get_level)
       |> Server.without_body (module Get_proof)
       |> Server.without_body (module Get_balance)
       |> Server.without_body (module Get_chain_info)
       |> Server.with_body (module Helpers_operation_message)
       |> Server.with_body (module Helpers_hash_operation)
       |> Server.with_body (module Post_operation)
       |> Server.without_body (module Get_vm_state)
       |> Server.without_body (module Get_vm_state_key)
       |> Server.without_body (module Get_stats)
       |> Server.with_body (module Get_hexa_to_signed)
       |> Server.without_body (module Get_receipt)
       |> Server.with_body (module Compute_contract_hash)
       |> Server.with_body (module Helper_compile_origination)
       |> Server.make_handler ~state)
  in
  let config = Piaf.Server.Config.create port in
  let server = Piaf.Server.create ~config request_handler in
  let _ = Piaf.Server.Command.start ~sw env server in
  ()

type params = {
  consensus_address : Deku_tezos.Address.t;
      [@env "DEKU_TEZOS_CONSENSUS_ADDRESS"]
  node_uri : string; [@env "DEKU_API_NODE_URI"]
  port : int; [@env "DEKU_API_PORT"]
  tcp_port : int; [@env "DEKU_API_TCP_PORT"] [@default 5550]
  database_uri : Uri.t; [@env "DEKU_API_DATABASE_URI"]
  domains : int; [@default 8] [@env "DEKU_API_DOMAINS"]
  data_folder : string; [@env "DEKU_API_DATA_FOLDER"]
}
[@@deriving cmdliner]

let main params =
  let {
    consensus_address;
    node_uri;
    port;
    tcp_port;
    database_uri;
    domains;
    data_folder;
  } =
    params
  in
  Eio_main.run @@ fun env ->
  Eio.Switch.run @@ fun sw ->
  Parallel.Pool.run ~env ~domains @@ fun () ->
  let net = Eio.Stdenv.net env in
  let clock = Eio.Stdenv.clock env in
  let domains = Eio.Stdenv.domain_mgr env in
  let node_host, node_port =
    match String.split_on_char ':' node_uri with
    | [ node_host; node_port ] -> (node_host, node_port |> int_of_string)
    | _ -> failwith "wrong node uri"
  in

  let identity =
    let secret =
      Deku_crypto.Secret.Ed25519 (Deku_crypto.Ed25519.Secret.generate ())
    in
    Deku_concepts.Identity.make secret
  in

  let network = Network_manager.make ~identity in
  let indexer =
    let worker = Parallel.Worker.make ~domains ~sw in
    Block_storage.make ~worker ~uri:database_uri
  in

  let dump = make_dump_loop ~sw ~env ~data_folder in

  let state = Api_storage.read ~env ~folder:data_folder in
  let state =
    match state with
    | None ->
        let vm_state = Ocaml_wasm_vm.State.empty in
        let protocol = Protocol.initial_with_vm_state ~vm_state in
        let current_block = Genesis.block in
        let receipts = Operation_hash.Map.empty in
        Api_state.make ~consensus_address ~indexer ~network ~identity ~protocol
          ~current_block ~receipts ~dump
    | Some state_data ->
        let Api_storage.{ protocol; current_block; receipts } = state_data in
        Api_state.make ~consensus_address ~indexer ~network ~identity ~protocol
          ~current_block ~receipts ~dump
  in

  Eio.Fiber.all
    [
      (fun () ->
        Network_manager.connect ~net ~clock
          ~nodes:[ (node_host, node_port) ]
          ~on_connection:(on_connection state)
          ~on_request:(fun ~connection:_ ~raw_header:_ ~raw_content:_ -> ())
          ~on_message:(on_message ~sw state) network);
      (fun () -> start_api ~env ~sw ~port ~state);
      (fun () -> listen_to_node ~net ~clock ~port:tcp_port ~state);
    ]

type init_from_chain_params = { node_folder : string; out_folder : string }
[@@deriving cmdliner]

(* Convert a chain.json to a json storage api *)
let init_from_chain params =
  Eio_main.run @@ fun env ->
  let { node_folder; out_folder } = params in
  let open Deku_storage in
  let storage = Storage.Chain.read ~env ~folder:node_folder in
  let chain =
    match storage with
    | None -> failwith "Did you put the good path ?"
    | Some storage -> storage
  in
  let storage = Api_storage.of_chain ~chain in
  let Api_storage.{ current_block; protocol; receipts } = storage in
  let () =
    Api_storage.write ~env ~data_folder:out_folder ~current_block ~protocol
      ~receipts
  in
  ()

let () =
  let open Cmdliner in
  let main_info = Cmd.info "main" in
  let main_term = Term.(const main $ params_cmdliner_term ()) in
  let main_cmd = Cmd.v main_info main_term in

  let init_info = Cmd.info "init" in
  let init_term =
    Term.(const init_from_chain $ init_from_chain_params_cmdliner_term ())
  in
  let init_cmd = Cmd.v init_info init_term in

  let cmd =
    Cmd.group (Cmd.info "deku-api") ~default:main_term [ main_cmd; init_cmd ]
  in

  exit (Cmd.eval ~catch:true cmd)
