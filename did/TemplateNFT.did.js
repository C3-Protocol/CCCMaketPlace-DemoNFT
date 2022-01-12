export const idlFactory = ({ IDL }) => {
  const TokenIndex__1 = IDL.Nat;
  const TokenIndex = IDL.Nat;
  const TransferResponse = IDL.Variant({
    'ok' : TokenIndex,
    'err' : IDL.Variant({
      'ListOnMarketPlace' : IDL.Null,
      'NotAllowTransferToSelf' : IDL.Null,
      'NotOwnerOrNotApprove' : IDL.Null,
      'Other' : IDL.Null,
    }),
  });
  const BuyRequest = IDL.Record({
    'tokenIndex' : TokenIndex,
    'marketFeeRatio' : IDL.Nat,
    'feeTo' : IDL.Principal,
  });
  const BuyResponse = IDL.Variant({
    'ok' : TokenIndex,
    'err' : IDL.Variant({
      'NotAllowBuySelf' : IDL.Null,
      'InsufficientBalance' : IDL.Null,
      'AlreadyTransferToOther' : IDL.Null,
      'NotFoundIndex' : IDL.Null,
      'Unauthorized' : IDL.Null,
      'Other' : IDL.Null,
      'LessThanFee' : IDL.Null,
      'AllowedInsufficientBalance' : IDL.Null,
    }),
  });
  const ListResponse = IDL.Variant({
    'ok' : TokenIndex,
    'err' : IDL.Variant({
      'NotApprove' : IDL.Null,
      'NotNFT' : IDL.Null,
      'NotFoundIndex' : IDL.Null,
      'SamePrice' : IDL.Null,
      'NotOwner' : IDL.Null,
      'Other' : IDL.Null,
      'AlreadyList' : IDL.Null,
    }),
  });
  const NftPhotoStoreCID = IDL.Record({
    'index' : TokenIndex,
    'canisterId' : IDL.Principal,
  });
  const Time = IDL.Int;
  const Listings = IDL.Record({
    'tokenIndex' : TokenIndex,
    'time' : Time,
    'seller' : IDL.Principal,
    'price' : IDL.Nat,
  });
  const SoldListings = IDL.Record({
    'lastPrice' : IDL.Nat,
    'time' : Time,
    'account' : IDL.Nat,
  });
  const ListRequest = IDL.Record({
    'tokenIndex' : TokenIndex,
    'price' : IDL.Nat,
  });
  const MintRequest = IDL.Record({
    'user' : IDL.Principal,
    'nftId' : TokenIndex,
  });
  const TemplateNFT = IDL.Service({
    'airDrop' : IDL.Func([], [IDL.Bool], []),
    'approve' : IDL.Func([IDL.Principal, TokenIndex__1], [IDL.Bool], []),
    'balanceOf' : IDL.Func([IDL.Principal], [IDL.Nat], ['query']),
    'batchTransferFrom' : IDL.Func(
        [IDL.Principal, IDL.Vec(IDL.Principal), IDL.Vec(TokenIndex__1)],
        [TransferResponse],
        [],
      ),
    'buyNow' : IDL.Func([BuyRequest], [BuyResponse], []),
    'cancelFavorite' : IDL.Func([TokenIndex__1], [IDL.Bool], []),
    'cancelList' : IDL.Func([TokenIndex__1], [ListResponse], []),
    'getAllNFT' : IDL.Func(
        [IDL.Principal],
        [IDL.Vec(IDL.Tuple(TokenIndex__1, IDL.Principal))],
        ['query'],
      ),
    'getAllNftPhotoCanister' : IDL.Func([], [IDL.Principal], []),
    'getApproved' : IDL.Func(
        [TokenIndex__1],
        [IDL.Opt(IDL.Principal)],
        ['query'],
      ),
    'getCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'getListings' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(NftPhotoStoreCID, Listings))],
        ['query'],
      ),
    'getSoldListings' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(NftPhotoStoreCID, SoldListings))],
        ['query'],
      ),
    'getStorageCanisterId' : IDL.Func([], [IDL.Opt(IDL.Principal)], ['query']),
    'getWICPCanisterId' : IDL.Func([], [IDL.Principal], ['query']),
    'isApprovedForAll' : IDL.Func(
        [IDL.Principal, IDL.Principal],
        [IDL.Bool],
        ['query'],
      ),
    'isList' : IDL.Func([TokenIndex__1], [IDL.Opt(Listings)], ['query']),
    'list' : IDL.Func([ListRequest], [ListResponse], []),
    'mint' : IDL.Func([IDL.Vec(MintRequest)], [IDL.Bool], []),
    'newStorageCanister' : IDL.Func([IDL.Principal], [IDL.Bool], []),
    'ownerOf' : IDL.Func([TokenIndex__1], [IDL.Opt(IDL.Principal)], ['query']),
    'pubSell' : IDL.Func([], [IDL.Bool], []),
    'setApprovalForAll' : IDL.Func([IDL.Principal, IDL.Bool], [IDL.Bool], []),
    'setFavorite' : IDL.Func([TokenIndex__1], [IDL.Bool], []),
    'setNftPhotoCanister' : IDL.Func([IDL.Principal], [IDL.Bool], []),
    'setOwner' : IDL.Func([IDL.Principal], [IDL.Bool], []),
    'setStorageCanisterId' : IDL.Func([IDL.Opt(IDL.Principal)], [IDL.Bool], []),
    'setWICPCanisterId' : IDL.Func([IDL.Principal], [IDL.Bool], []),
    'transferFrom' : IDL.Func(
        [IDL.Principal, IDL.Principal, TokenIndex__1],
        [TransferResponse],
        [],
      ),
    'updateList' : IDL.Func([ListRequest], [ListResponse], []),
    'wallet_receive' : IDL.Func([], [IDL.Nat], []),
  });
  return TemplateNFT;
};
export const init = ({ IDL }) => { return [IDL.Principal, IDL.Principal]; };
