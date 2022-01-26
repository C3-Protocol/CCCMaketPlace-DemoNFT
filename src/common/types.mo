import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import List "mo:base/List";
import Time "mo:base/Time";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Char "mo:base/Char";

module Types = {

  public let CREATECANVAS_CYCLES: Nat = 1_000_000_000_000;  //1 T
  public type Result<T,E> = Result.Result<T,E>;
  public type TokenIndex = Nat;

  public type Balance = Nat;

  public type CanvasIdentity = {
    index: TokenIndex;
    canisterId: Principal;
  };

  public type MintRequest = {
    user: Principal;
    nftId: TokenIndex;
  };

  public type BuyRequest = {
    tokenIndex: TokenIndex;
    feeTo:      Principal;
    marketFeeRatio: Nat;
  };

  public type TransferResponse = Result.Result<TokenIndex, {
    #NotOwnerOrNotApprove;
    #NotAllowTransferToSelf;
    #ListOnMarketPlace;
    #Other;
  }>;

  public type BuyResponse = Result.Result<TokenIndex, {
    #Unauthorized;
    #LessThanFee;
    #InsufficientBalance;
    #AllowedInsufficientBalance;
    #NotFoundIndex;
    #NotAllowBuySelf;
    #AlreadyTransferToOther;
    #Other;
  }>;

  public type PreMint = {
    user: Principal;
    index: TokenIndex;
  };

  public type MintRecord = {
    index: Nat;
    record: OpRecord;
  };

  public type MintResponse = Result.Result<[CanvasIdentity], {
    #Unauthorized;
    #LessThanFee;
    #InsufficientBalance;
    #AllowedInsufficientBalance;
    #Other;
    #SoldOut;
    #NotOpen;
    #NotEnoughToMint;
    #NotWhiteListOrMaximum;
  }>;

  public type ListRequest = {
    tokenIndex : TokenIndex;
    price : Nat;
  };

  public type Listings = { 
    tokenIndex : TokenIndex; 
    seller : Principal; 
    price : Nat;
    time : Time.Time;
  };

  public type SoldListings = {
    lastPrice : Nat;
    time : Time.Time;
    account : Nat;
  };

  public type Operation = {
    #Mint;
    #List;
    #UpdateList;
    #CancelList;
    #Sale;
    #Transfer;
    #Bid;
  };

  public type OpRecord = {
    op: Operation;
    price: ?Nat;
    from: ?Principal;
    to: ?Principal;
    timestamp: Time.Time;
  };

  public type ListResponse = Result.Result<TokenIndex, {
    #NotOwner;
    #NotFoundIndex;
    #AlreadyList;
    #NotApprove;
    #NotNFT;
    #SamePrice;
    #Other;
  }>;

  public type Component = {
    nftId: TokenIndex;
    attr1: Nat;
    attr2: Nat;
    attr3: Nat;
    attr4: Nat;
    attr5: Text;
  };

  public type LedgerStorageActor = actor {
    setFavorite : shared (user: Principal, info: CanvasIdentity) -> async ();
    cancelFavorite : shared (user: Principal, info: CanvasIdentity) -> async ();
    addRecord : shared (index: TokenIndex, op: Operation, from: ?Principal, to: ?Principal, 
        price: ?Nat, timestamp: Time.Time) -> async ();
    addBuyRecord : shared (index: TokenIndex, from: ?Principal, to: ?Principal, 
        price: ?Nat, timestamp: Time.Time) -> async ();
    addRecords : shared (records: [MintRecord]) -> async ();
  };

  public module TokenIndex = {
    public func equal(x : TokenIndex, y : TokenIndex) : Bool {
      x == y
    };
    public func hash(x : TokenIndex) : Hash.Hash {
      Text.hash(Nat.toText(x))
    };
  };

  public type Image = Blob;

  //Http Request and Response
  public type HttpRequest = {
      body: Blob;
      headers: [HeaderField];
      method: Text;
      url: Text;
  };

  public type HeaderField = (Text, Text);

  public type HttpResponse = {
      body: Blob;
      headers: [HeaderField];
      status_code: Nat16;
      streaming_strategy: ?StreamingStrategy;
  };

  public type StreamingCallbackToken =  {
      content_encoding: Text;
      index: Nat;
      key: Text;
      sha256: ?Blob;
  };

  public type StreamingStrategy = {
      #Callback: {
          callback: query (StreamingCallbackToken) -> async (StreamingCallbackResponse);
          token: StreamingCallbackToken;
      };
  };

  public type StreamingCallbackResponse = {
      body: Blob;
      token: ?StreamingCallbackToken;
  };

  public func textToNat( txt : Text) : Nat {
        assert(txt.size() > 0);
        let chars = txt.chars();

        var num : Nat = 0;
        for (v in chars){
            let charToNum = Nat32.toNat(Char.toNat32(v)-48);
            assert(charToNum >= 0 and charToNum <= 9);
            num := num * 10 +  charToNum;          
        };

        num;
    };

}

