open Helpers
open Bin_common
open Deku_accounts
open Deku_validators
open Deku_tickets
open Deku_block_queries

(*************************************************************************)
(* Transactions *)

let make_transaction ~block_level ~ticket ~sender ~recipient ~amount =
  let amount = Core.Amount.of_int amount in
  let transaction =
    Core.User_operation.Transaction
      { destination = recipient.Files.Wallet.address; amount; ticket } in
  let data =
    Core.User_operation.make ~source:sender.Files.Wallet.address transaction
  in
  Protocol.Operation.Core_user.sign ~secret:sender.Files.Wallet.priv_key
    ~nonce:(Crypto.Random.int32 Int32.max_int)
    ~block_height:block_level ~data

let spam_transactions ~ticketer ~n () =
  let validator_uri = get_random_validator_uri () in
  let%await block_level = get_current_block_level () in
  let ticket = make_ticket ticketer in
  let transactions =
    List.init n (fun _ ->
        make_transaction ~block_level ~ticket ~sender:alice_wallet
          ~recipient:bob_wallet ~amount:1) in
  Format.eprintf "Number of transactions - packed: %d\n%!"
    (List.length transactions);
  let%await _ =
    Network.request_user_operations_gossip
      { user_operations = transactions }
      validator_uri in
  Lwt.return transactions

let rec spam ~ticketer =
  let n = 2000 in
  let%await _ =
    Lwt_list.iter_p Fun.id
    @@ (* REMARK: list 4 *)
    List.init 4 (fun _ ->
        let%await _ = spam_transactions ~ticketer ~n () in
        await ()) in
  let%await () = Lwt_unix.sleep 1.0 in
  spam ~ticketer

let load_test_transactions ticketer =
  let%await starting_block_level = get_current_block_level () in
  Format.printf "Starting block level: %Li\n%!" starting_block_level;
  spam ~ticketer

let load_test_transactions ticketer =
  load_test_transactions ticketer |> Lwt_main.run
