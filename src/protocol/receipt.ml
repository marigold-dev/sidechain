type receipt =
  | Receipt_operation of { operation : Operation_hash.t }
  | Receipt_tezos_withdraw of Ledger.Withdrawal_handle.t

and t = receipt [@@deriving eq]
