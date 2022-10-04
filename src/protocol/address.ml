open Deku_crypto
open Deku_stdlib

type address =
  | Implicit of Key_hash.t
  | Originated of { address : Contract_address.t; entrypoint : string option }

and t = address [@@deriving eq, ord, yojson, show]

let of_key_hash key_hash = Implicit key_hash
let to_key_hash = function Implicit x -> Some x | Originated _ -> None

let of_contract_address contract_address =
  Originated { address = contract_address; entrypoint = None }

let to_contract_address = function
  | Implicit _ -> None
  | Originated x -> Some x.address

let of_b58 x =
  let implicit string =
    let%some implicit = Key_hash.of_b58 string in
    Some (Implicit implicit)
  in
  let originated string =
    let%some contract, entrypoint =
      match String.split_on_char '%' string with
      | [ contract ] -> Some (contract, None)
      | [ contract; entrypoint ]
        when String.length entrypoint < 32 && entrypoint <> "default" ->
          Some (contract, Some entrypoint)
      | _ -> None
    in
    let%some address = Contract_address.of_b58 contract in
    Some (Originated { address; entrypoint })
  in
  Deku_repr.decode_variant [ implicit; originated ] x

let to_b58 = function
  | Implicit key_hash -> Key_hash.to_b58 key_hash
  | Originated { address; entrypoint = None } -> Contract_address.to_b58 address
  | Originated { address; entrypoint = Some entrypoint } ->
      Contract_address.to_b58 address ^ "%" ^ entrypoint

module Map = Deku_stdlib.Map.Make (struct
  type nonrec t = t

  let compare = compare_address
  let t_of_yojson = t_of_yojson
  let yojson_of_t = yojson_of_t
end)

let cmdliner_converter =
  let of_string s =
    match of_b58 s with
    | Some s -> `Ok s
    | None -> `Error (Format.sprintf "Could not parse '%s' as a Deku address" s)
  in
  let to_string fmt t = Format.fprintf fmt "%s" (to_b58 t) in
  (of_string, to_string)
