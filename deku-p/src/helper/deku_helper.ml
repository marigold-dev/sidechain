open Deku_protocol
open Deku_stdlib
open Deku_concepts
open Deku_gossip
open Deku_crypto

let post_directly_to_node ~env ~operation =
  let host = "127.0.0.1" in
  let port = 4440 in
  let net = Eio.Stdenv.net env in
  let content = Message.Content.operation operation in
  let (Message { network; _ }) = Message.encode ~content in
  let (Network_message { raw_header; raw_content }) = network in
  let open Deku_network in
  let message = Network_message.message ~raw_header ~raw_content in
  Network_protocol.Client.connect ~net ~host ~port @@ fun connection ->
  Network_protocol.Connection.write connection message

let post_to_api ~sw ~env ~operation =
  let node = "http://localhost:8080/api/v1/operations" |> Uri.of_string in
  let json =
    Data_encoding.Json.construct Operation.Signed.encoding operation
    |> Data_encoding.Json.to_string
  in
  let body = Piaf.Body.of_string json in
  let post_result = Piaf.Client.Oneshot.post ~body ~sw env node in
  match post_result with
  | Ok _ -> print_endline "operation submitted"
  | Error _ -> print_endline "FAIL to submit operation"

let make_identity secret =
  secret |> Secret.of_b58 |> Option.get |> Identity.make

type level_response = { level : Level.t }

let make_level ~sw ~env () =
  let response =
    Piaf.Client.Oneshot.get ~sw env
      (Uri.of_string "http://localhost:8080/api/v1/chain/level")
  in
  let body =
    match response with
    | Error _ -> failwith "cannot connect to the API"
    | Ok res -> res.body
  in
  let string = Piaf.Body.to_string body in
  let body =
    match string with
    | Error _ -> failwith "cannot parse body"
    | Ok body -> body
  in
  let json = Data_encoding.Json.from_string body in
  match json with
  | Ok json ->
      let level = Data_encoding.Json.destruct Level.encoding json in
      level
  | _ -> failwith "cannot decode level"

let make_nonce () =
  let rng = Stdlib.Random.State.make_self_init () in
  Stdlib.Random.State.bits64 rng
  |> Int64.abs |> Z.of_int64 |> N.of_z |> Option.get |> Nonce.of_n

let main ~env ~sw:_ =
  let identity =
    make_identity "edsk4UWkJqpZrAm26qvJE8uY9ZFGFqQiFuBcDyEPASXeHxuD68WvvF"
  in
  let level = Level.zero in
  let nonce = make_nonce () in
  let _content2 =
    {|
    { "operation":
    { "initial_storage": [ "Map", [] ],
      "module":
        "0061736d0100000001c3808080000d60017e017e60017e0060017e017f60027e7e017e60017f017e6000017e60027e7f0060037e7e7e017e60027e7f017e60027f7e017e60037e7e7e0060017f006000000294888080005203656e760769735f6c656674000203656e76086475705f686f7374000103656e760470616972000303656e7606706169725f6e000403656e7606756e70616972000103656e76057a5f616464000303656e76057a5f737562000303656e76057a5f6d756c000303656e76036e6567000003656e76036c736c000303656e7606636f6e636174000303656e76036c7372000303656e7607636f6d70617265000303656e7603636172000003656e7603636472000003656e7604736f6d65000003656e76036e6f77000503656e76036e696c000503656e760474727565000503656e7608756e706169725f6e000603656e760566616c7365000503656e76046e6f6e65000503656e7604756e6974000503656e76047a65726f000503656e7609656d7074795f6d6170000503656e7609656d7074795f736574000503656e760d656d7074795f6269675f6d6170000503656e760673656e646572000503656e7606736f75726365000503656e76076d61705f676574000303656e76036d656d000303656e7606757064617465000703656e760469746572000603656e76036d6170000803656e760769665f6c656674000203656e760769665f6e6f6e65000203656e760769665f636f6e73000203656e760569736e6174000003656e76036e6f74000003656e76026f72000303656e7603616e64000303656e7603786f72000303656e760a64657265665f626f6f6c000203656e76036e6571000003656e76086661696c77697468000103656e76056765745f6e000903656e760465786563000303656e76056170706c79000303656e7605636f6e7374000403656e7603616273000003656e76026571000003656e76026774000003656e76026c74000003656e7607636c6f73757265000403656e76046c656674000003656e76057269676874000003656e7604636f6e73000303656e760f7472616e736665725f746f6b656e73000703656e760761646472657373000003656e7608636f6e7472616374000003656e760473656c66000503656e760c73656c665f61646472657373000503656e760e6765745f616e645f757064617465000a03656e760b726561645f7469636b6574000103656e76067469636b6574000303656e760c6a6f696e5f7469636b657473000003656e760c73706c69745f7469636b6574000303656e7606616d6f756e74000503656e760762616c616e6365000503656e760465646976000303656e76026765000003656e76026c65000003656e760473697a65000003656e7603696e74000003656e7610696d706c696369745f6163636f756e74000003656e7607626c616b653262000003656e76047061636b000003656e7606756e7061636b000003656e76066b656363616b000003656e7606736861323536000003656e760473686133000003656e760673686135313200000391808080001008060b0b0b0c0b0b05010b00000000000485808080000170010404058380808000010004069980808000047f0041000b7f0141a01f0b7f0141e8070b7f00418080020b07c580808000060470757368005b03706f70005a046d61696e006108636c6f737572657301000d63616c6c5f63616c6c6261636b00521263616c6c5f63616c6c6261636b5f756e69740053098a80808000010041000b04605f5e5d0ae8e180800010898080800000200020011100000b898080800000200020011101000bc48080800001037f4100210123012102230220006b22032402034041082303200320016a6a6c4108200220016a6c290300370300200141016a22012000470d000b200220006a24010bc48080800001037f230120006b22022401230221034100210103404108200220016a6c23034108200320016a6c6a290300370300200141016a22012000470d000b200320006a24020b8f80808000004108230120006a6c29030010010b948080800001027e105a2100105a21012000105b2001105b0bcb8080800002037f017e230120006a210323012201220241086c29030021040340410820016c200241016a220241086c290300370300200141016a210120012003490d000b410820036c20043703000bc28080800002027f017e4108230120006a22016c29030021030340410820016c210220024108200141016b22016c29030037030023012001490d000b410820016c20033703000b958080800001017f4108230122006c290300200041016a24010b978080800001017f4108230141016b22016c2000370300200124010b898080800000230120006a24010b988280800001017e2000105b105a1004105a4107101341071059105a1004105a105a101d105b105a102304401017105b1057105a105a1002105b1017105b1017105b105a105a1002105b410410591017105b105a105a1002105b105a105a1002105b410510591017105b105a105a1002105b4105105941051059105a105a1002105b105a105a1002105b105a105a1002105b1017105b1017105b105a105a1002105b1017105b41051059105a105a1002105b105a105a1002105b1017105b1017105b105a105a1002105b410410591019105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b0510574102105941031059410410594105105941061059410710594107105c0b105a0b8e8380800001017e2000105b41001030105b41011056105a100d105b105a100d105b105a100e105b105a100d105b105a100e105b105a105a1007105b410a1030105b41021056105a100d105b105a100e105b105a100e105b105a100d105b105a100d105b105a105a1007105b410b1030105b41031056105a100d105b105a100e105b105a100d105b105a100e105b105a100d105b105a105a1007105b410c1030105b41041056105a100d105b105a100e105b105a100e105b105a100e105b105a100d105b105a105a1007105b410d1030105b41051056105a100d105b105a100d105b105a100e105b105a100e105b105a100e105b105a105a1007105b410e1030105b41061056105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b105a105a1007105b410f1030105b41071059105a100e105b105a100e105b105a105a1007105b10574102105941031059410410594105105941061059105a105a1005105b105a105a1005105b105a105a1005105b105a105a1005105b105a105a1005105b105a105a1005105b105a0bd48a80800001017e2000105b105a1004105a4108101341081059105a1004105a10220440410210594105105941061059410710594104105c105a1022044041031059410410594102105c105a102204404101105c41001056105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b41081030105b105a105a1002105b410310561057105a105a102e105b41021059105a105a1007105b1057105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b41021030105b105a105a1002105b410210591057105a105a102e105b1057105a105a1045105b105a1023044041091030105b105a102c000b105a100d105b054104105c1017105b0b05410210594101105c105a10220440410210594102105c41001056105a100d105b105a100d105b105a100e105b105a100d105b105a100e105b41081030105b105a105a1002105b410310561057105a105a102e105b41021059105a105a1007105b1057105a100d105b105a100d105b105a100e105b105a100d105b105a100e105b41021030105b105a105a1002105b410210591057105a105a102e105b1057105a105a1045105b105a1023044041091030105b105a102c000b105a100d105b05410310594102105c41001056105a100d105b105a100d105b105a100e105b105a100e105b105a100e105b41081030105b105a105a1002105b410310561057105a105a102e105b41021059105a105a1007105b1057105a100d105b105a100d105b105a100e105b105a100e105b105a100e105b41021030105b105a105a1002105b410210591057105a105a102e105b1057105a105a1045105b105a1023044041091030105b105a102c000b105a100d105b0b0b054103105941041059410810594103105c105a1022044041021059410310594102105c105a10220440410310594102105c41001056105a100d105b105a100e105b105a100d105b105a100e105b105a100d105b41081030105b105a105a1002105b410310561057105a105a102e105b41021059105a105a1007105b1057105a100d105b105a100e105b105a100d105b105a100e105b105a100d105b41021030105b105a105a1002105b410210591057105a105a102e105b1057105a105a1045105b105a1023044041091030105b105a102c000b105a100d105b05410210594102105c41001056105a100d105b105a100e105b105a100e105b105a100d105b105a100d105b41081030105b105a105a1002105b410310561057105a105a102e105b41021059105a105a1007105b1057105a100d105b105a100e105b105a100e105b105a100d105b105a100d105b41021030105b105a105a1002105b410210591057105a105a102e105b1057105a105a1045105b105a1023044041091030105b105a102c000b105a100d105b0b0541041059410510594102105c105a10220440410210594102105c41001056105a100d105b105a100e105b105a100e105b105a100e105b105a100d105b41081030105b105a105a1002105b410310561057105a105a102e105b41021059105a105a1007105b1057105a100d105b105a100e105b105a100e105b105a100e105b105a100d105b41021030105b105a105a1002105b410210591057105a105a102e105b1057105a105a1045105b105a1023044041091030105b105a102c000b105a100d105b05410310594102105c41001056105a100e105b105a100e105b41081030105b105a105a1002105b410310561057105a105a102e105b41021059105a105a1007105b1057105a100e105b105a100e105b41021030105b105a105a1002105b410210591057105a105a102e105b1057105a105a1045105b105a1023044041091030105b105a102c000b105a100d105b0b0b0b105a0bb28180800001017e2000105b105a100441001030105b105a105a1002105b105a105a1002105b105a1036105b0340105a10220440105a1004105a10041017105b41031056105a105a100c105b105a1032105b105a102a04401057410210594102105c105a1037105b0541001030105b41031059105a105a1006105b105a1031105b410210564103105941031059105a105a1007105b105a105a1002105b105a105a1002105b105a1036105b0b105a10000d010b0b105a0beccc80800001017e2000105b41001035105b41011030105b41021030105b41031030105b41041030105b41051030105b41061030105b41071030105b41011035105b410810564108105641081056410810564108105641081056410810564108105641081003105b105a105a102f105b410810594101105c41021035105b41031035105b4109105641091056410910564109105641091056410910564109105641071003105b105a105a102f105b410310594104105941051059410610594107105941081059410910594107105c41031059105a1004105a1022044041031059410410594102105c105a10220440101b105b4102105641011056105a105a1002105b410410591057105a105a102e105b41001056105a100d105b105a100d105b105a100d105b105a100d105b105a100d105b410310591012105b1057105a105a105a101f105b410310594102105941001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b41031056105a100d105b105a100d105b105a100d105b105a100e105b41041059105a100d105b105a100d105b105a100d105b105a100d105b105a100e105b41061059105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b105a100f105b41021059105a105a105a101f105b054101105641011056105a100e105b105a105a1002105b410310561057105a105a102e105b105a100d105b105a100d105b105a100d105b105a100d105b105a100d105b101b105b105a105a101e105b105a102a04404101105641011056105a100e105b105a105a1002105b410310591057105a105a102e105b41011056105a100d105b41011056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a100c105b105a1046105b105a102a044041011056105a100d105b41011056105a100d105b105a100d105b105a100e105b105a100e105b105a100d105b105a105a1005105b41021056105a100d105b41021056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a1006105b105a1031105b410410594103105941001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b4105105941041056105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b105a105a1002105b41041059105a100d105b105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b41001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b105a100e105b105a100e105b41051059105a105a1002105b41031056105a100d105b105a100d105b105a100e105b105a100d105b105a105a1002105b41031059105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b105a100f105b41021059105a100e105b105a105a105a101f105b054102105c0b05410210594102105c0b0b05105a1022044041001056105a100e105b105a10220440105a10220440105a102204404101105c4101105641011056105a100d105b105a100e105b105a105a1002105b410310561057105a105a102e105b105a100d105b105a100d105b105a100d105b105a100d105b105a100d105b101b105b105a105a101e105b105a102a04404101105641011056105a100d105b105a100e105b105a105a1002105b410310591057105a105a102e105b41001056105a100d105b105a100d105b105a100d105b105a100d105b105a100e105b41011056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a100c105b105a1046105b105a102a044041001030105b41011056105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b105a105a1005105b41011056105a100d105b105a100d105b105a100d105b105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a1006105b105a1031105b4102105941001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b4104105941041056105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b105a105a1002105b41041059105a100d105b105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b41001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b41031056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b41051059105a105a1002105b41041059105a100d105b105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b4100105641021056105a100e105b105a105a1002105b410510591057105a105a102e105b41011056410510591057105a105a102e105b4102105941001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b41031056105a100d105b105a100d105b105a100d105b105a100e105b4106105941051059105a100d105b105a100d105b105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b41001056105a100e105b4102105941021056105a100d105b105a100e105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100d105b105a105a1002105b41021059105a100d105b105a100d105b105a105a1002105b105a105a1002105b410210591057105a100f105b41021059105a100d105b105a100e105b105a105a105a101f105b05105741031059410410594104105c0b054102105941031059410410594104105c0b0541041059410510594103105c4101105641011056105a100d105b105a100e105b105a105a1002105b410310591057105a105a102e105b41001056105a100d105b105a100d105b105a100d105b105a100d105b105a100d105b101b105b105a105a101e105b105a102a044041011056105a100d105b105a100d105b41011056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a1005105b410310594102105941001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b4105105941041056105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b105a105a1002105b41041059105a100d105b105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b105a100f105b41021059105a100d105b105a100e105b105a105a105a101f105b054102105c0b0b05105a102204404101105c4101105641011056105a100d105b105a100e105b105a105a1002105b410310561057105a105a102e105b105a100d105b105a100d105b105a100d105b105a100d105b105a100d105b101b105b105a105a101e105b105a102a04404101105641011056105a100d105b105a100e105b105a105a1002105b410310591057105a105a102e105b41001056105a100d105b105a100d105b105a100e105b105a100d105b105a100d105b41011056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a100c105b105a1046105b105a102a044041001030105b41011056105a100d105b105a100d105b105a100e105b105a100d105b105a100e105b105a105a1005105b41011056105a100d105b105a100d105b105a100e105b105a100d105b105a100d105b41021056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a1006105b105a1031105b4102105941001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b4104105941041056105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b105a105a1002105b41041059105a100d105b105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b41001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b105a100e105b4104105941041056105a100d105b105a100d105b105a100e105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b41031059105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b4100105641021056105a100e105b105a105a1002105b410510591057105a105a102e105b41011056410510591057105a105a102e105b4102105941001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b105a100e105b41031056105a100d105b105a100d105b105a100e105b105a100d105b105a100e105b41061059105a105a1002105b105a105a1002105b41031059105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b41001056105a100e105b4102105941021056105a100d105b105a100e105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100d105b105a105a1002105b41021059105a100d105b105a100d105b105a105a1002105b105a105a1002105b410210591057105a100f105b41021059105a100d105b105a100e105b105a105a105a101f105b05105741031059410410594104105c0b054102105941031059410410594104105c0b054101105c4101105641011056105a100d105b105a100e105b105a105a1002105b410310561057105a105a102e105b105a100d105b105a100d105b105a100d105b105a100d105b105a100d105b101b105b105a105a101e105b105a102a04404101105641011056105a100d105b105a100e105b105a105a1002105b410310591057105a105a102e105b41001056105a100d105b105a100e105b105a100d105b105a100d105b105a100d105b41011056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a100c105b105a1046105b105a102a044041001030105b41011056105a100d105b105a100d105b105a100e105b105a100e105b105a100e105b105a105a1005105b41011056105a100d105b105a100e105b105a100d105b105a100d105b105a100d105b41021056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a1006105b105a1031105b4102105941001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b4104105941041056105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b105a105a1002105b41041059105a100d105b105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b41001056105a100e105b41011056105a100d105b105a100e105b4103105941031056105a100d105b105a100d105b105a100e105b105a100e105b105a100d105b105a105a1002105b41031056105a100d105b105a100d105b105a100e105b105a100d105b105a105a1002105b41031059105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b4100105641021056105a100e105b105a105a1002105b410510591057105a105a102e105b41011056410510591057105a105a102e105b4102105941001056105a100e105b41011056105a100d105b105a100e105b105a100e105b41021056105a100d105b105a100e105b105a100d105b105a100e105b41031056105a100d105b105a100e105b105a100d105b105a100d105b105a100e105b41061059105a105a1002105b105a105a1002105b105a105a1002105b41021059105a100d105b105a100d105b105a105a1002105b105a105a1002105b41001056105a100e105b4102105941021056105a100d105b105a100e105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100d105b105a105a1002105b41021059105a100d105b105a100d105b105a105a1002105b105a105a1002105b410210591057105a100f105b41021059105a100d105b105a100e105b105a105a105a101f105b05105741031059410410594104105c0b054102105941031059410410594104105c0b0b0b05105a10220440105a102204404101105c4101105641011056105a100d105b105a100e105b105a105a1002105b410310561057105a105a102e105b105a100d105b105a100d105b105a100d105b105a100d105b105a100d105b101b105b105a105a101e105b105a102a04404101105641011056105a100d105b105a100e105b105a105a1002105b410310591057105a105a102e105b41001056105a100d105b105a100e105b105a100d105b105a100d105b105a100e105b41011056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a100c105b105a1046105b105a102a044041001030105b41011056105a100d105b105a100e105b105a100d105b105a100e105b105a100d105b105a105a1005105b41011056105a100d105b105a100e105b105a100d105b105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a1006105b105a1031105b4102105941001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b4104105941041056105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b105a105a1002105b41041059105a100d105b105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b41001056105a100e105b41011056105a100d105b105a100e105b105a100e105b41021056105a100d105b105a100e105b105a100d105b105a100e105b105a100e105b41041059105a105a1002105b41031056105a100d105b105a100e105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b41021059105a100d105b105a100d105b105a105a1002105b105a105a1002105b4100105641021056105a100e105b105a105a1002105b410510591057105a105a102e105b41011056410510591057105a105a102e105b4102105941001056105a100e105b41011056105a100d105b105a100e105b105a100e105b41021056105a100d105b105a100e105b105a100d105b105a100e105b4105105941041056105a100d105b105a100e105b105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b41021059105a100d105b105a100d105b105a105a1002105b105a105a1002105b41001056105a100e105b4102105941021056105a100d105b105a100e105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100d105b105a105a1002105b41021059105a100d105b105a100d105b105a105a1002105b105a105a1002105b410210591057105a100f105b41021059105a100d105b105a100e105b105a105a105a101f105b05105741031059410410594104105c0b054102105941031059410410594104105c0b054101105c4101105641011056105a100d105b105a100e105b105a105a1002105b410310561057105a105a102e105b105a100d105b105a100d105b105a100d105b105a100d105b105a100d105b101b105b105a105a101e105b105a102a04404101105641011056105a100d105b105a100e105b105a105a1002105b410310591057105a105a102e105b41001056105a100d105b105a100e105b105a100d105b105a100e105b105a100e105b41011056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a100c105b105a1046105b105a102a044041001030105b41011056105a100d105b105a100e105b105a100e105b105a100d105b105a100d105b105a105a1005105b41011056105a100d105b105a100e105b105a100d105b105a100e105b105a100e105b41021056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a1006105b105a1031105b4102105941001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b4104105941041056105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b105a105a1002105b41041059105a100d105b105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b41001056105a100e105b41011056105a100d105b105a100e105b105a100e105b105a100e105b41021056105a100d105b105a100e105b105a100e105b105a100d105b105a100e105b41041059105a105a1002105b105a105a1002105b41021056105a100d105b105a100e105b105a100d105b105a105a1002105b41021059105a100d105b105a100d105b105a105a1002105b105a105a1002105b4100105641021056105a100e105b105a105a1002105b410510591057105a105a102e105b41011056410510591057105a105a102e105b4102105941001056105a100e105b41011056105a100d105b105a100e105b105a100e105b4104105941031056105a100d105b105a100e105b105a100d105b105a100e105b105a100d105b105a105a1002105b41031056105a100d105b105a100e105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b41021059105a100d105b105a100d105b105a105a1002105b105a105a1002105b41001056105a100e105b4102105941021056105a100d105b105a100e105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100d105b105a105a1002105b41021059105a100d105b105a100d105b105a105a1002105b105a105a1002105b410210591057105a100f105b41021059105a100d105b105a100e105b105a105a105a101f105b05105741031059410410594104105c0b054102105941031059410410594104105c0b0b05105a102204404101105c4101105641011056105a100d105b105a100e105b105a105a1002105b410310561057105a105a102e105b105a100d105b105a100d105b105a100d105b105a100d105b105a100d105b101b105b105a105a101e105b105a102a04404101105641011056105a100d105b105a100e105b105a105a1002105b410310591057105a105a102e105b41001056105a100d105b105a100e105b105a100e105b105a100d105b105a100e105b41011056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a100c105b105a1046105b105a102a044041001030105b41011056105a100d105b105a100e105b105a100e105b105a100e105b105a100d105b105a105a1005105b41011056105a100d105b105a100e105b105a100e105b105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a1006105b105a1031105b4102105941001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b4104105941041056105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b105a105a1002105b41041059105a100d105b105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b41001056105a100e105b41011056105a100d105b105a100e105b105a100e105b105a100e105b105a100e105b41031059105a105a1002105b41021056105a100d105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100d105b105a105a1002105b41021059105a100d105b105a100d105b105a105a1002105b105a105a1002105b4100105641021056105a100e105b105a105a1002105b410510591057105a105a102e105b41011056410510591057105a105a102e105b4102105941001056105a100e105b41011056105a100d105b105a100e105b105a100e105b105a100e105b4104105941031056105a100d105b105a100e105b105a100e105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b41021056105a100d105b105a100e105b105a100d105b105a105a1002105b41021059105a100d105b105a100d105b105a105a1002105b105a105a1002105b41001056105a100e105b4102105941021056105a100d105b105a100e105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100d105b105a105a1002105b41021059105a100d105b105a100d105b105a105a1002105b105a105a1002105b410210591057105a100f105b41021059105a100d105b105a100e105b105a105a105a101f105b05105741031059410410594104105c0b054102105941031059410410594104105c0b054101105c4101105641011056105a100d105b105a100e105b105a105a1002105b410310561057105a105a102e105b105a100d105b105a100d105b105a100d105b105a100d105b105a100d105b101b105b105a105a101e105b105a102a04404101105641011056105a100d105b105a100e105b105a105a1002105b410310591057105a105a102e105b41001056105a100e105b105a100d105b41011056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a100c105b105a1046105b105a102a044041001030105b41011056105a100e105b105a100e105b105a105a1005105b41011056105a100e105b105a100d105b41021056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a1006105b105a1031105b4102105941001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b4104105941041056105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b105a105a1002105b41041059105a100d105b105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b105741011056105a100e105b105a100d105b105a105a1002105b1057105a100d105b105a105a1002105b4100105641021056105a100e105b105a105a1002105b410510591057105a105a102e105b41011056410510591057105a105a102e105b4102105941001056105a100e105b105a100e105b41031059105a105a1002105b1057105a100d105b105a105a1002105b41001056105a100e105b4102105941021056105a100d105b105a100e105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100e105b105a100d105b105a105a1002105b41021056105a100d105b105a100e105b105a100d105b105a105a1002105b41021059105a100d105b105a100d105b105a105a1002105b105a105a1002105b410210591057105a100f105b41021059105a100d105b105a100e105b105a105a105a101f105b05105741031059410410594104105c0b054102105941031059410410594104105c0b0b0b0b0541031059410410594102105c4101105641011056105a100d105b105a100e105b105a105a1002105b410310561057105a105a102e105b105a100d105b105a100d105b105a100d105b105a100d105b105a100d105b101b105b105a105a101e105b105a102a04404101105641011056105a100d105b105a100e105b105a105a1002105b410310561057105a105a102e105b41011056105a100d105b105a100d105b41011056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a100c105b105a1046105b105a102a04404102105641021056105a100e105b105a105a1002105b410410591057105a105a102e105b41021056105a100d105b105a100d105b41021056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a1006105b41031056105a100d105b105a100d105b41021056105a100d105b105a100d105b105a100d105b105a100e105b105a100e105b105a105a1005105b410510594104105941001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b41061059105a1031105b41041056105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b105a105a1002105b41041059105a100d105b105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b105a100f105b41041056105a100d105b105a100e105b105a105a105a101f105b4102105941001056105a100e105b41011056105a100d105b105a100e105b41021056105a100d105b105a100d105b105a100e105b4105105941041056105a100d105b105a100d105b105a100d105b105a100e105b105a100d105b105a105a1002105b41041059105a100d105b105a100d105b105a100d105b105a100d105b105a105a1002105b105a105a1002105b105a105a1002105b105a105a1002105b105a100f105b41021059105a100e105b105a105a105a101f105b051057410310594103105c0b05410210594102105c0b0b0b1011105b105a105a1002105b105a0b",
      "constants":
        [ [ 0, [ "Int", "1" ] ], [ 1, [ "Int", "15" ] ],
          [ 2, [ "Int", "100" ] ], [ 3, [ "Int", "1100" ] ],
          [ 4, [ "Int", "12000" ] ], [ 5, [ "Int", "130000" ] ],
          [ 6, [ "Int", "1400000" ] ], [ 7, [ "Int", "20000000" ] ],
          [ 8, [ "Int", "115" ] ], [ 9, [ "String", "DIV by 0" ] ],
          [ 10, [ "Int", "3" ] ], [ 11, [ "Int", "8" ] ],
          [ 12, [ "Int", "47" ] ], [ 13, [ "Int", "260" ] ],
          [ 14, [ "Int", "1400" ] ], [ 15, [ "Int", "7800" ] ] ],
      "entrypoints":
        { "%delegate": [ "Left", "Left" ], "%eat": [ "Left", "Right" ],
          "%mint": [ "Right", "Left" ], "%transfer": [ "Right", "Right" ] } },
  "tickets": [] }
|}
  in
  (* Change this string with your appropriate needs*)
  let _content =
    {| 
    { "operation":
    { "address": "tz1YCm2e83y4fWJG2Enf1EZVf3mSQykQJYMD",
      "argument":
        [ "Pair",
          [ [ "Pair",
              [ [ "Int", "1" ],
                [ "Option",
                  [ "Some",
                    [ "Union",
                      [ "Left",
                        [ "Union",
                          [ "Left", [ "Union", [ "Right", [ "Unit" ] ] ] ] ] ] ] ] ] ] ],
            [ "Pair",
              [ [ "Union", [ "Left", [ "Union", [ "Right", [ "Unit" ] ] ] ] ],
                [ "Option", [ "None", {} ] ] ] ] ] ] }, "tickets": [] }
    |}
  in
  let operation = Data_encoding.Json.from_string _content2 in
  let operation =
    match operation with
    | Ok operation ->
        Data_encoding.Json.destruct Ocaml_wasm_vm.Operation_payload.encoding
          operation
    | _ -> failwith "impossible to decode operation"
  in
  print_endline (Ocaml_wasm_vm.Operation_payload.show operation);

  let (Deku_protocol.Operation.Signed.Signed_operation transaction as op) =
    Operation.Signed.vm_transaction ~level ~nonce ~content:operation ~identity
  in
  let (Deku_protocol.Operation.Initial.Initial_operation { hash; _ }) =
    transaction.initial
  in
  Format.printf "hash: %a\n%!" Operation_hash.pp hash;
  let address =
    Deku_ledger.Contract_address.of_user_operation_hash
      (Deku_protocol.Operation_hash.to_blake2b hash)
    |> Deku_ledger.Contract_address.to_b58
  in
  (match operation.operation with
  | Originate _ ->
      print_newline ();
      print_endline ("Address: " ^ address ^ "\n");
      print_newline ()
  | _ -> ());
  let _ = post_directly_to_node ~identity ~env ~operation:op in
  ()

let () =
  Eio_main.run @@ fun env ->
  Eio.Switch.run @@ fun sw -> main ~env ~sw
