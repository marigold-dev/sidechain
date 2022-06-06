open Helpers

module Make (P : sig
  val size : int
end) : sig
  type t [@@deriving yojson, bin_io]

  val to_string : t -> string

  val of_string : string -> t option

  val of_raw_string : string -> t option

  val to_raw_string : t -> string

  val equal : t -> t -> bool

  val compare : t -> t -> int

  val hash : string -> t

  val verify : hash:t -> string -> bool

  val both : t -> t -> t

  val size : int

  module Map : Map.S with type key = t

  val encoding : t Data_encoding.t
end = struct
  include P

  include Digestif.Make_BLAKE2B (struct
    let digest_size = P.size
  end)

  let of_raw_string = of_raw_string_opt

  let to_string = to_hex

  let of_string string =
    let%some () =
      match String.length string = size * 2 with
      | true -> Some ()
      | false -> None in
    of_hex_opt string

  let to_yojson str = `String (to_hex str)

  let of_yojson json =
    let%ok hex = [%of_yojson: string] json in
    of_string hex |> Option.to_result ~none:"Invalid hex"

  let equal = equal

  let compare = unsafe_compare

  let hash data = digest_string data

  let verify ~hash:expected_hash data = expected_hash = hash data

  let both a b = hash (to_raw_string a ^ to_raw_string b)

  let bin_read_t buf ~pos_ref = match of_string @@ Bin_prot.Read.bin_read_string buf ~pos_ref:pos_ref with
    | None -> failwith "Invalid hex"
    | Some t -> t

  let bin_reader_t = failwith "Not used by Pollinate"
  let __bin_read_t__ = failwith "Not used by Pollinate"
  
  let bin_write_t buf ~pos t = Bin_prot.Write.bin_write_string buf ~pos:pos (to_hex t)

  let bin_writer_t = failwith "Not used by Pollinate"
  let __bin_write_t__ = failwith "Not used by Pollinate"

  let bin_size_t = failwith "Not used by Pollinate"
  let bin_shape_t = failwith "Not used by Pollinate" 
  let bin_t = failwith "Not used by Pollinate"

  module Map = Map.Make (struct
    type nonrec t = t

    let compare = compare
  end)

  let encoding =
    let open Data_encoding in
    conv
      (fun hash -> to_raw_string hash)
      (fun string -> string |> of_raw_string |> Option.get)
      (Fixed.string size)
end

module BLAKE2B_20 = Make (struct
  let size = 20
end)

include Make (struct
  let size = 32
end)
