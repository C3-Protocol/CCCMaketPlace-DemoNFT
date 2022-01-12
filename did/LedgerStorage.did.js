export const idlFactory = ({ IDL }) => {
  const TokenIndex__1 = IDL.Nat;
  const Time = IDL.Int;
  const Operation__1 = IDL.Variant({
    'Bid' : IDL.Null,
    'List' : IDL.Null,
    'Mint' : IDL.Null,
    'Sale' : IDL.Null,
    'CancelList' : IDL.Null,
    'Transfer' : IDL.Null,
    'UpdateList' : IDL.Null,
  });
  const TokenIndex = IDL.Nat;
  const NftPhotoStoreCID = IDL.Record({
    'index' : TokenIndex,
    'canisterId' : IDL.Principal,
  });
  const Operation = IDL.Variant({
    'Bid' : IDL.Null,
    'List' : IDL.Null,
    'Mint' : IDL.Null,
    'Sale' : IDL.Null,
    'CancelList' : IDL.Null,
    'Transfer' : IDL.Null,
    'UpdateList' : IDL.Null,
  });
  const OpRecord = IDL.Record({
    'op' : Operation,
    'to' : IDL.Opt(IDL.Principal),
    'from' : IDL.Opt(IDL.Principal),
    'timestamp' : Time,
    'price' : IDL.Opt(IDL.Nat),
  });
  const LedgerStorage = IDL.Service({
    'addBuyRecord' : IDL.Func(
        [
          TokenIndex__1,
          IDL.Opt(IDL.Principal),
          IDL.Opt(IDL.Principal),
          IDL.Opt(IDL.Nat),
          Time,
        ],
        [],
        [],
      ),
    'addRecord' : IDL.Func(
        [
          TokenIndex__1,
          Operation__1,
          IDL.Opt(IDL.Principal),
          IDL.Opt(IDL.Principal),
          IDL.Opt(IDL.Nat),
          Time,
        ],
        [],
        [],
      ),
    'cancelFavorite' : IDL.Func([IDL.Principal, NftPhotoStoreCID], [], []),
    'getCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'getFavorite' : IDL.Func(
        [IDL.Principal],
        [IDL.Vec(NftPhotoStoreCID)],
        ['query'],
      ),
    'getHistory' : IDL.Func([TokenIndex__1], [IDL.Vec(OpRecord)], ['query']),
    'getNftFavoriteNum' : IDL.Func([TokenIndex__1], [IDL.Nat], ['query']),
    'getWrapNftCanisterId' : IDL.Func([], [IDL.Principal], ['query']),
    'isFavorite' : IDL.Func(
        [IDL.Principal, NftPhotoStoreCID],
        [IDL.Bool],
        ['query'],
      ),
    'setFavorite' : IDL.Func([IDL.Principal, NftPhotoStoreCID], [], []),
    'setWrapNftCanisterId' : IDL.Func([IDL.Principal], [IDL.Bool], []),
    'wallet_receive' : IDL.Func([], [IDL.Nat], []),
  });
  return LedgerStorage;
};
export const init = ({ IDL }) => { return [IDL.Principal]; };
