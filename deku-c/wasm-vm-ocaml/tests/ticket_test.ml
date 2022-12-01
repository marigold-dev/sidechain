(* Test based on the following contract:
   { parameter bytes ;
     storage int ;
     code { UNPAIR ;
            PUSH nat 100 ;
            SWAP ;
            TICKET ;
            SENDER ;
            CONTRACT (ticket bytes) ;
            IF_NONE
              { DROP ; PUSH string "Incorrect address" ; FAILWITH }
              { PUSH mutez 0 ; DIG 2 ; TRANSFER_TOKENS } ;
            SWAP ;
            NIL operation ;
            DIG 2 ;
            CONS ;
            PAIR } }

   with
     - no entrypoint except default
     - minting and sending bytes tickets
*)

let originate =
  let open Ocaml_wasm_vm in
  let module_ =
    "0061736d0100000001c3808080000d60017e017e60017e0060017e017f60027e7e017e60017f017e6000017e60027e7f0060037e7e7e017e60027e7f017e60027f7e017e60037e7e7e0060017f00600000028a888080005103656e760769735f6c656674000203656e76086475705f686f7374000103656e760470616972000303656e7606706169725f6e000403656e7606756e70616972000103656e76057a5f616464000303656e76057a5f737562000303656e76057a5f6d756c000303656e76036e6567000003656e76036c736c000303656e7606636f6e636174000303656e76036c7372000303656e7607636f6d70617265000303656e7603636172000003656e7603636472000003656e7604736f6d65000003656e76036e696c000503656e760474727565000503656e7608756e706169725f6e000603656e760566616c7365000503656e76046e6f6e65000503656e7604756e6974000503656e76047a65726f000503656e7609656d7074795f6d6170000503656e7609656d7074795f736574000503656e760d656d7074795f6269675f6d6170000503656e760673656e646572000503656e7606736f75726365000503656e76076d61705f676574000303656e76036d656d000303656e7606757064617465000703656e760469746572000603656e76036d6170000803656e760769665f6c656674000203656e760769665f6e6f6e65000203656e760769665f636f6e73000203656e760569736e6174000003656e76036e6f74000003656e76026f72000303656e7603616e64000303656e7603786f72000303656e760a64657265665f626f6f6c000203656e76036e6571000003656e76086661696c77697468000103656e76056765745f6e000903656e760465786563000303656e76056170706c79000303656e7605636f6e7374000403656e7603616273000003656e76026571000003656e76026774000003656e76026c74000003656e7607636c6f73757265000403656e76046c656674000003656e76057269676874000003656e7604636f6e73000303656e760f7472616e736665725f746f6b656e73000703656e760761646472657373000003656e7608636f6e7472616374000003656e760473656c66000503656e760c73656c665f61646472657373000503656e760e6765745f616e645f757064617465000a03656e760b726561645f7469636b6574000103656e76067469636b6574000303656e760c6a6f696e5f7469636b657473000003656e760c73706c69745f7469636b6574000303656e7606616d6f756e74000503656e760762616c616e6365000503656e760465646976000303656e76026765000003656e76026c65000003656e760473697a65000003656e7603696e74000003656e7610696d706c696369745f6163636f756e74000003656e7607626c616b653262000003656e76047061636b000003656e7606756e7061636b000003656e76066b656363616b000003656e7606736861323536000003656e760473686133000003656e76067368613531320000038d808080000c08060b0b0b0c0b0b05010b000485808080000170010000058380808000010004069980808000047f0041000b7f0141a01f0b7f0141e8070b7f00418080020b07c580808000060470757368005a03706f700059046d61696e005c08636c6f737572657301000d63616c6c5f63616c6c6261636b00511263616c6c5f63616c6c6261636b5f756e69740052098680808000010041000b000aa7848080000c898080800000200020011100000b898080800000200020011101000bc48080800001037f4100210123012102230220006b22032402034041082303200320016a6a6c4108200220016a6c290300370300200141016a22012000470d000b200220006a24010bc48080800001037f230120006b22022401230221034100210103404108200220016a6c23034108200320016a6c6a290300370300200141016a22012000470d000b200320006a24020b8f80808000004108230120006a6c29030010010b948080800001027e10592100105921012000105a2001105a0bcb8080800002037f017e230120006a210323012201220241086c29030021040340410820016c200241016a220241086c290300370300200141016a210120012003490d000b410820036c20043703000bc28080800002027f017e4108230120006a22016c29030021030340410820016c210220024108200141016b22016c29030037030023012001490d000b410820016c20033703000b958080800001017f4108230122006c290300200041016a24010b978080800001017f4108230141016b22016c2000370300200124010b898080800000230120006a24010beb8080800001017e2000105a105910044100102f105a105610591059103f105a101a105a1059103a105a1059102204404101105b4101102f105a1059102b00051016105a410210581059105910591038105a0b10561010105a41021058105910591037105a105910591002105a10590b"
  in
  (* No entrypoint *)
  let json = Data_encoding.Json.from_string {|{
  }|} in
  let json = Result.get_ok json in
  let entrypoints = Data_encoding.Json.destruct Entrypoints.encoding json in
  Operation.Originate
    {
      initial_storage = Int Z.zero;
      module_;
      entrypoints;
      constants = [| (0, Int Z.zero) |];
    }

let invoke =
  let open Ocaml_wasm_vm in
  let open Deku_ledger in
  let bytes = Bytes.of_string "1234" in
  let argument = Value.(Bytes bytes) in
  Operation.Call
    {
      address =
        Address.of_contract_address
          ( Contract_address.of_user_operation_hash
              (Deku_crypto.BLAKE2b.hash "tutturu"),
            None );
      argument;
    }

let new_address () =
  let open Deku_crypto in
  let open Deku_ledger in
  let secret = Ed25519.Secret.generate () in
  let secret = Secret.Ed25519 secret in
  let key = Key.of_secret secret in
  let key_hash = Key_hash.of_key key in
  Address.of_key_hash key_hash

let test () =
  let open Alcotest in
  let open Ocaml_wasm_vm in
  let addr = new_address () in
  let x =
    Env.execute
      ~operation_hash:(Deku_crypto.BLAKE2b.hash "tutturu")
      ~tickets:[]
      Env.
        {
          source = addr;
          sender = addr;
          ledger = Deku_ledger.Ledger.initial;
          state = State.empty;
          ticket_table = Ticket_table.init [];
        }
      ~operation:originate
  in
  let state = Result.get_ok x in
  let (State_entry.Entry { storage; _ }) =
    State.fetch_contract state.state
      Deku_ledger.(
        Contract_address.of_user_operation_hash
          (Deku_crypto.BLAKE2b.hash "tutturu"))
  in
  (check bool) "Originate" true (Value.equal storage (Int Z.zero));
  let x =
    Env.execute
      ~operation_hash:(Deku_crypto.BLAKE2b.hash "tutturu")
      ~tickets:[]
      Env.
        {
          source = addr;
          sender = addr;
          ledger = Deku_ledger.Ledger.initial;
          state = state.state;
          ticket_table = Ticket_table.init [];
        }
      ~operation:invoke
  in
  let state = Result.get_ok x in
  let (Env.Ledger.Ledger { table; _ }) = state.Env.ledger in
  (* FIXME not sure how to get the ticketer so we inspect the whole ledger *)
  let table =
    (table
      :> Deku_concepts.Amount.t Deku_ledger.Ticket_table.Ticket_map.t
         Deku_ledger.Ticket_table.Address_map.t)
  in
  let ledger = Deku_ledger.Ticket_table.Address_map.bindings table in
  let _deposit_address, ticket_map = List.nth ledger 0 in
  let _ticket_id, amount =
    Deku_ledger.Ticket_table.Ticket_map.bindings ticket_map
    |> Fun.flip List.nth 0
  in
  (* FIXME check ticked_id too? *)
  (check bool) "Should have minted 100 tickets" true (Obj.magic amount = 100);
  ()
