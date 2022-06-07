open Cmdliner
open External_vm

let transition (storage : External_vm_server.storage) sender tx_hash operation =
  print_endline "Transaction received";
  print_endline (sender |> Crypto.Key_hash.to_string);
  print_endline (tx_hash |> Crypto.BLAKE2B.to_string);
  print_endline (operation |> Yojson.Safe.to_string);

  let result =
    match storage.get "counter" with
    | Some (`Int n) ->
      let next_value = n + 1 in
      print_endline (Printf.sprintf "previous value: %i" n);
      print_endline (Printf.sprintf "next value: %i" next_value);
      Ok next_value
    | _ -> Error "counter is unknown" in

  result |> Result.map (fun counter -> storage.set "counter" (`Int counter))

let deku_vm named_pipe_path =
  External_vm_server.start_chain_ipc ~named_pipe_path;
  External_vm_server.main [{ key = "counter"; value = `Int 1 }] transition

let node =
  let named_pipe =
    let docv = "named_pipe" in
    let doc =
      "Path to the named pipes used for IPC with the chain. Will suffix with \
       '_read' and '_write' respectively." in
    let open Arg in
    required & pos 0 (some string) None & info [] ~doc ~docv in
  let open Term in
  const deku_vm $ named_pipe

let _ = Cmd.eval @@ Cmd.v (Cmd.info "deku-vm") node
