export const idlFactory = ({ IDL }) => {
  const TokenIndex__1 = IDL.Nat;
  const TokenIndex = IDL.Nat;
  const Component = IDL.Record({
    'attr1' : IDL.Nat,
    'attr2' : IDL.Nat,
    'attr3' : IDL.Nat,
    'attr4' : IDL.Nat,
    'attr5' : IDL.Text,
    'nftId' : TokenIndex,
  });
  const HeaderField = IDL.Tuple(IDL.Text, IDL.Text);
  const HttpRequest = IDL.Record({
    'url' : IDL.Text,
    'method' : IDL.Text,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
  });
  const StreamingCallbackToken = IDL.Record({
    'key' : IDL.Text,
    'sha256' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'index' : IDL.Nat,
    'content_encoding' : IDL.Text,
  });
  const StreamingCallbackResponse = IDL.Record({
    'token' : IDL.Opt(StreamingCallbackToken),
    'body' : IDL.Vec(IDL.Nat8),
  });
  const StreamingStrategy = IDL.Variant({
    'Callback' : IDL.Record({
      'token' : StreamingCallbackToken,
      'callback' : IDL.Func(
          [StreamingCallbackToken],
          [StreamingCallbackResponse],
          ['query'],
        ),
    }),
  });
  const HttpResponse = IDL.Record({
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
    'streaming_strategy' : IDL.Opt(StreamingStrategy),
    'status_code' : IDL.Nat16,
  });
  const MetaData = IDL.Service({
    'deleteImage' : IDL.Func([IDL.Nat], [IDL.Bool], []),
    'getComponentByIndex' : IDL.Func(
        [TokenIndex__1],
        [IDL.Opt(Component)],
        ['query'],
      ),
    'getCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'http_request' : IDL.Func([HttpRequest], [HttpResponse], ['query']),
    'uploadComponents' : IDL.Func([IDL.Vec(Component)], [IDL.Bool], []),
    'uploadImage' : IDL.Func([IDL.Nat, IDL.Vec(IDL.Nat8)], [IDL.Bool], []),
    'wallet_receive' : IDL.Func([], [IDL.Nat], []),
  });
  return MetaData;
};
export const init = ({ IDL }) => { return [IDL.Principal]; };
