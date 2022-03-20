open Crypto
open Tezos

type t
val spawn : unit -> t

(* response *)
module Transaction : sig
  type t =
    | Applied     of { hash : string }
    | Failed      of { hash : string option }
    | Skipped     of { hash : string option }
    | Backtracked of { hash : string option }
    | Unknown     of { hash : string option }
    | Error       of { error : string }
end

val transaction :
  t ->
  rpc_node:Uri.t ->
  secret:Secret.t ->
  required_confirmations:int ->
  destination:Address.t ->
  entrypoint:string ->
  payload:Yojson.Safe.t ->
  Transaction.t Lwt.t

val storage :
  t ->
  rpc_node:Uri.t ->
  required_confirmations:int ->
  destination:Address.t ->
  (Michelson.t, string) result Lwt.t
