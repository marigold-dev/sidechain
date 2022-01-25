open Helpers;
open Crypto;
open Core;

[@deriving ord]
type t = {
  // TODO: what is the name of a signature?
  signature: Signature.t,
  public_key: Wallet.t,
  address: Key_hash.t,
};
let public_key = t => t.public_key;
let address = t => t.address;
let signature = t => t.signature;

let (to_yojson, of_yojson) = {
  module Serialized_data = {
    [@deriving yojson]
    type t = {
      signature: Signature.t,
      public_key: Wallet.t,
    };
  };

  let to_yojson = t =>
    Serialized_data.to_yojson({
      signature: t.signature,
      public_key: t.public_key,
    });
  let of_yojson = json => {
    let.ok {signature, public_key} = Serialized_data.of_yojson(json);
    let address = Address.Implicit.of_key(public_key);
    Ok({signature, public_key, address});
  };
  (to_yojson, of_yojson);
};

let sign = (~key as secret, hash) => {
  let signature = Signature.sign(secret, hash);
  let public_key = Key.of_secret(secret);
  let address = Address.Implicit.of_key(public_key);
  {signature, public_key, address};
};
let verify = (~signature, hash) =>
  Signature.verify(signature.public_key, signature.signature, hash);
module type S = {
  type value;
  type signature = t;
  type t =
    pri {
      value,
      signature,
    };
  let sign: (~key: Secret.t, value) => t;
  let verify: (~signature: signature, value) => bool;
};
module Make = (P: {
                 type t;
                 let hash: t => BLAKE2B.t;
               }) => {
  type value = P.t;
  type signature = t;
  type t = {
    value,
    signature,
  };
  let sign = (~key, value) => {
    // TODO: maybe reuse this hash?
    let signature = P.hash(value) |> sign(~key);
    {value, signature};
  };
  // TODO: pretty sure this should be reused
  let verify = (~signature, value) => P.hash(value) |> verify(~signature);
};
