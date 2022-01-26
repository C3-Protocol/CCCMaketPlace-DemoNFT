/**
 * Module     : TemplateNFT.mo
 * Copyright  : 2021 CCC Team
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : CCC Team - Leven
 * Stability  : Experimental
 */

import WICP "../common/WICP";
import Types "../common/types";
import LedgerStorage "../storage/LedgerStorage";
import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Bool "mo:base/Bool";
import HashMap "mo:base/HashMap";
import Option "mo:base/Option";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Time "mo:base/Time";
import Char "mo:base/Char";
import List "mo:base/List";
import Cycles "mo:base/ExperimentalCycles";

/**
 * Factory Canister to Create Canvas Canister
 */
shared(msg)  actor class TemplateNFT (owner_: Principal, royaltyfeeto_: Principal) = this {

    type WICPActor = WICP.WICPActor;
    type TokenIndex = Types.TokenIndex;
    type Balance = Types.Balance;
    type TransferResponse = Types.TransferResponse;
    type ListRequest = Types.ListRequest;
    type ListResponse = Types.ListResponse;
    type BuyResponse = Types.BuyResponse;
    type Listings = Types.Listings;
    type MintRequest = Types.MintRequest;
    type SoldListings = Types.SoldListings;
    type OpRecord = Types.OpRecord;
    type Operation = Types.Operation;
    type BuyRequest = Types.BuyRequest;
    type StorageActor = Types.LedgerStorageActor;
    type NftPhotoStoreCID = Types.CanvasIdentity;
    type PreMint = Types.PreMint;
    type MintRecord = Types.MintRecord;
    type MintResponse = Types.MintResponse;

    private stable var supply : Balance  = 5000; //according to your project
    private stable var name : Text  = "Crazy Zombie"; //according to your project

    private stable var owner: Principal = owner_;
    private stable var WICPCanisterActor: WICPActor = actor("xxxxx-xxxxx-xxxxx-xxxxx-xxx");

    private stable var cyclesCreateCanvas: Nat = Types.CREATECANVAS_CYCLES;

    private stable var mintAccount : Balance  = 0;
    //nft store canister-id, provide https_request to show yout nft-photo/nft-video
    //you also can provide use this canister, but suggest use another canister
    private stable var nftStoreCID : Principal = Principal.fromText("xxxxx-xxxxx-xxxxx-xxxxx-xxx");
    private stable var storageCanister : List.List<Principal> = List.nil<Principal>();
    private stable var royaltyfeeTo : Principal = royaltyfeeto_;
    private stable var royaltyfeeRatio : Nat = 2;

    private stable var listingsEntries : [(TokenIndex, Listings)] = [];
    private var listings = HashMap.HashMap<TokenIndex, Listings>(1, Types.TokenIndex.equal, Types.TokenIndex.hash);

    private stable var soldListingsEntries : [(TokenIndex, SoldListings)] = [];
    private var soldListings = HashMap.HashMap<TokenIndex, SoldListings>(1, Types.TokenIndex.equal, Types.TokenIndex.hash);

    // Mapping from owner to number of owned token
    private stable var balancesEntries : [(Principal, Nat)] = [];
    private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);

    // Mapping from NFT canister ID to owner
    private stable var ownersEntries : [(TokenIndex, Principal)] = [];
    private var owners = HashMap.HashMap<TokenIndex, Principal>(1, Types.TokenIndex.equal, Types.TokenIndex.hash); 

     // Mapping from NFT canister ID to approved address
    private stable var availableEntries : [(TokenIndex, Bool)] = [];
    private var availableMint = HashMap.HashMap<TokenIndex, Bool>(1, Types.TokenIndex.equal, Types.TokenIndex.hash); 

    private stable var mintPrice : Balance  = 200_000_000;

    system func preupgrade() {
        listingsEntries := Iter.toArray(listings.entries());
        soldListingsEntries := Iter.toArray(soldListings.entries());
        balancesEntries := Iter.toArray(balances.entries());
        ownersEntries := Iter.toArray(owners.entries());

        availableEntries := Iter.toArray(availableMint.entries());
    };

    system func postupgrade() {
        balances := HashMap.fromIter<Principal, Nat>(balancesEntries.vals(), 1, Principal.equal, Principal.hash);
        owners := HashMap.fromIter<TokenIndex, Principal>(ownersEntries.vals(), 1, Types.TokenIndex.equal, Types.TokenIndex.hash);
        listings := HashMap.fromIter<TokenIndex, Listings>(listingsEntries.vals(), 1, Types.TokenIndex.equal, Types.TokenIndex.hash);
        soldListings := HashMap.fromIter<TokenIndex, SoldListings>(soldListingsEntries.vals(), 1, Types.TokenIndex.equal, Types.TokenIndex.hash);
        availableMint := HashMap.fromIter<TokenIndex, Bool>(availableEntries.vals(), 1, Types.TokenIndex.equal, Types.TokenIndex.hash);

        listingsEntries := [];
        soldListingsEntries := [];
        balancesEntries := [];
        ownersEntries := [];
        availableEntries := [];
    };

    /*
    set new storage canister to store the tx history
    */
    public shared(msg) func setStorageCanisterId(storage: ?Principal) : async Bool {
        assert(msg.caller == owner);
        switch(storage){
            case (?s) {storageCanister := List.push(s, storageCanister);};
            case _ {};
        };
        return true;
    };

    public shared(msg) func setRoyaltyfeeRatio(newfeeRatio: Nat) : async Bool {
        assert(msg.caller == owner and newfeeRatio < 3);
        royaltyfeeRatio := newfeeRatio;
        return true;
    };

    public query func getLastStorageCanisterId() : async ?Principal {
        _getStorageCanisterId()
    };

    public query func getAllStorageCanisterId() : async [Principal] {
        List.toArray(storageCanister)
    };

    private func _getStorageCanisterId() : ?Principal {
        List.get(storageCanister, 0)
    };

    /*
    create new storage canister to store the tx history
    */
    public shared(msg) func newStorageCanister(owner: Principal) : async Bool {
        assert(msg.caller == owner);
        Cycles.add(cyclesCreateCanvas);
        let storage = await LedgerStorage.LedgerStorage(owner);
        let canvasCid = Principal.fromActor(storage);
        storageCanister := List.push(canvasCid, storageCanister);
        return true;
    };

    /*
    set NFT-Store canisterId, 
    than web-front can call https_request to show your nft-photo/nft-video
    if you have many store, nftStoreCID can be a Array
    */
    public shared(msg) func setNftPhotoCanister(storeCID: Principal) : async Bool {
        assert(msg.caller == owner_);
        nftStoreCID := storeCID;
        return true;
    };

    public shared(msg) func getAllNftPhotoCanister() : async Principal {
        assert(msg.caller == owner_);
        nftStoreCID
    };

    public shared(msg) func setFavorite(tokenIndex: TokenIndex): async Bool {
        switch(_getStorageCanisterId()){
            case(?s){
                let storageA: StorageActor = actor(Principal.toText(s));
                let info: NftPhotoStoreCID = { 
                    index=tokenIndex; 
                    canisterId=nftStoreCID;
                };
                ignore storageA.setFavorite(msg.caller, info);
            };
            case _ {};
        };
        return true;
    };

    public shared(msg) func cancelFavorite(tokenIndex: TokenIndex): async Bool {
        switch(_getStorageCanisterId()){
            case(?s){
                let storageA: StorageActor = actor(Principal.toText(s));
                let info: NftPhotoStoreCID = { 
                    index=tokenIndex; 
                    canisterId=nftStoreCID;
                };
                ignore storageA.cancelFavorite(msg.caller, info);
            };
            case _ {};
        };
        return true;
    };

    /*
    airdrop interface, accroding to your nft project logic
    */
    public shared(msg) func airDrop(): async Bool {
        true
    };

    /*
    publicSell interface, accroding to your nft project logic
    this is a example
    */
    public shared(msg) func preMint(preMintArr: [PreMint]) : async Bool {
        assert(msg.caller == owner);
        var records: [MintRecord] = [];
        for(v in preMintArr.vals()){
            let rec: MintRecord = {
                index = v.index;
                record = {op = #Mint; from = null; to = ?v.user; price = null; timestamp = Time.now();};
            };
            records := Array.append(records, [rec]);
            owners.put(v.index, v.user);
        };
        switch(_getStorageCanisterId()){
            case(?s){
                let storageA: StorageActor = actor(Principal.toText(s));
                ignore storageA.addRecords(records);
            };
            case _ {};
        };
        return true;
    };

    /*
    mint interface, accroding to your nft project logic
    this is a simple example, sell nft
    */
    public shared(msg) func mint(amount: Nat) : async MintResponse {
        assert(amount > 0);
        if(mintAccount >= supply){ return #err(#SoldOut); };
        if(mintAccount + amount > supply){ return #err(#NotEnoughToMint); };

        let tokenIndexArr = randomNfts(amount, msg.caller);
        if(tokenIndexArr.size() == 0){ return #err(#SoldOut); };

        let transferResult = await WICPCanisterActor.transferFrom(msg.caller, royaltyfeeTo, mintPrice * tokenIndexArr.size());
        switch(transferResult){
            case(#ok(b)) {};
            case(#err(errText)){
                for(v in tokenIndexArr.vals()){
                    availableMint.put(v, true);
                };
                return #err(errText);
            };
        };

        var records: [MintRecord] = [];
        var idArr: [NftPhotoStoreCID] = [];

        for(v in tokenIndexArr.vals()){
            let rec: MintRecord = {
                index = v;
                record = {op = #Mint; from = null; to = ?msg.caller; price = null; timestamp = Time.now();};
            };
            let zombieId: NftPhotoStoreCID = { 
                index=v; 
                canisterId=nftStoreCID;
            };
            
            records := Array.append(records, [rec]);
            idArr := Array.append(idArr, [zombieId]);
            owners.put(v, msg.caller);
        };
        balances.put( msg.caller, _balanceOf(msg.caller) + tokenIndexArr.size() );
        mintAccount += tokenIndexArr.size();
        switch(_getStorageCanisterId()){
            case(?s){
                let storageA: StorageActor = actor(Principal.toText(s));
                ignore storageA.addRecords(records);
            };
            case _ {};
        };

        return #ok(idArr);
    };

    //transferFrom
    public shared(msg) func transferFrom(from: Principal, to: Principal, tokenIndex: TokenIndex): async TransferResponse {
        if(Option.isSome(listings.get(tokenIndex))){
            return #err(#ListOnMarketPlace);
        };
        if( not _checkOwner(tokenIndex, from) ){
            return #err(#NotOwnerOrNotApprove);
        };
        if(from == to){
            return #err(#NotAllowTransferToSelf);
        };
        _transfer(from, to, tokenIndex);
        if(Option.isSome(listings.get(tokenIndex))){
            listings.delete(tokenIndex);
        };
        switch(_getStorageCanisterId()){
            case(?s){
                let storageA: StorageActor = actor(Principal.toText(s));
                ignore storageA.addRecord(tokenIndex, #Transfer, ?from, ?to, null, Time.now());
            };
            case _ {};
        };
        return #ok(tokenIndex);
    };

    //batchTransferFrom
    public shared(msg) func batchTransferFrom(from: Principal, tos: [Principal], tokenIndexs: [TokenIndex]): async TransferResponse {
        if(tokenIndexs.size() == 0 or tos.size() == 0
            or tokenIndexs.size() != tos.size()){
            return #err(#Other);
        };
        for(v in tokenIndexs.vals()){
            if(Option.isSome(listings.get(v))){
                return #err(#ListOnMarketPlace);
            };
            if( not _checkOwner(v, from) ){
                return #err(#NotOwnerOrNotApprove);
            };
        };
        for(i in Iter.range(0, tokenIndexs.size() - 1)){
            _transfer(from, tos[i], tokenIndexs[i]);
        };
        return #ok(tokenIndexs[0]);
    };

    //list on marketplace
    public shared(msg) func list(listReq: ListRequest): async ListResponse {
        if(Option.isSome(listings.get(listReq.tokenIndex))){
            return #err(#AlreadyList);
        };
        if(not _checkOwner(listReq.tokenIndex, msg.caller)){
            return #err(#NotOwner);
        };
        let timeStamp = Time.now();
        var order:Listings = {
            tokenIndex = listReq.tokenIndex; 
            seller = msg.caller; 
            price = listReq.price;
            time = timeStamp;
        };
        listings.put(listReq.tokenIndex, order);
        switch(_getStorageCanisterId()){
            case(?s){
                let storageA: StorageActor = actor(Principal.toText(s));
                ignore storageA.addRecord(listReq.tokenIndex, #List, ?msg.caller, null, ?listReq.price, timeStamp);
            };
            case _ {};
        };
        return #ok(listReq.tokenIndex);
    };

    public shared(msg) func updateList(listReq: ListRequest): async ListResponse {
        let orderInfo = switch(listings.get(listReq.tokenIndex)){
            case (?o){o};
            case _ {return #err(#NotFoundIndex);};
        };
        if(listReq.price == orderInfo.price){
            return #err(#SamePrice);
        };
        if(not _checkOwner(listReq.tokenIndex, msg.caller)){
            return #err(#NotOwner);
        };
        let timeStamp = Time.now();
        var order:Listings = {
            tokenIndex = listReq.tokenIndex; 
            seller = msg.caller; 
            price = listReq.price;
            time = timeStamp;
        };
        listings.put(listReq.tokenIndex, order);
        switch(_getStorageCanisterId()){
            case(?s){
                let storageA: StorageActor = actor(Principal.toText(s));
                ignore storageA.addRecord(listReq.tokenIndex, #UpdateList, ?msg.caller, null, ?listReq.price, timeStamp);
            };
            case _ {};
        };
        return #ok(listReq.tokenIndex);
    };
    
    //cancelList on marketplace
    public shared(msg) func cancelList(tokenIndex: TokenIndex): async ListResponse {
        let orderInfo = switch(listings.get(tokenIndex)){
            case (?o){o};
            case _ {return #err(#NotFoundIndex);};
        };
        
        if(not _checkOwner(tokenIndex, msg.caller)){
            return #err(#NotOwner);
        };
        var price: Nat = orderInfo.price;
        listings.delete(tokenIndex);
        switch(_getStorageCanisterId()){
            case(?s){ 
                let storageA: StorageActor = actor(Principal.toText(s));
                ignore storageA.addRecord(tokenIndex, #CancelList, ?msg.caller, null, ?price, Time.now());
            };
            case _ {};
        };
        return #ok(tokenIndex);
    };

    //buyNow
    public shared(msg) func buyNow(buyRequest: BuyRequest): async BuyResponse {
        assert(buyRequest.marketFeeRatio < 5);
        let orderInfo = switch(listings.get(buyRequest.tokenIndex)){
            case (?l){l};
            case _ {return #err(#NotFoundIndex);};
        };
        if(msg.caller == orderInfo.seller){
            return #err(#NotAllowBuySelf);
        };
        
        if(not _checkOwner(buyRequest.tokenIndex, orderInfo.seller)){
            listings.delete(buyRequest.tokenIndex);
            return #err(#AlreadyTransferToOther);
        };

        var tos: [Principal] = [];
        var values: [Nat] = [];

        let marketFee:Nat = Nat.div(Nat.mul(orderInfo.price, buyRequest.marketFeeRatio), 100);
        let royaltyFee:Nat = Nat.div(Nat.mul(orderInfo.price, royaltyfeeRatio), 100);
        let value = orderInfo.price - marketFee - royaltyFee;

        tos := Array.append(tos, [buyRequest.feeTo]);
        tos := Array.append(tos, [royaltyfeeTo]);
        tos := Array.append(tos, [orderInfo.seller]);
        
        values := Array.append(values, [marketFee]);
        values := Array.append(values, [royaltyFee]);
        values := Array.append(values, [value]);

        listings.delete(buyRequest.tokenIndex);
        let transferResult = await WICPCanisterActor.batchTransferFrom(msg.caller, tos, values);
        switch(transferResult){
            case(#ok(b)) {};
            case(#err(errText)){
                listings.put(buyRequest.tokenIndex, orderInfo);
                return #err(errText);
            };
        };
        var price: Nat = orderInfo.price;
        _transfer(orderInfo.seller, msg.caller, orderInfo.tokenIndex);
        _addSoldListings(orderInfo);
        switch(_getStorageCanisterId()){
            case(?s){ 
                let storageA: StorageActor = actor(Principal.toText(s));
                ignore storageA.addBuyRecord(buyRequest.tokenIndex, ?orderInfo.seller, ?msg.caller, ?price, Time.now());
            };
            case _ {};
        };
        return #ok(buyRequest.tokenIndex);
    };

    //setWICPCanisterId
    public shared(msg) func setWICPCanisterId(wicpCanisterId: Principal) : async Bool {
        assert(msg.caller == owner);
        WICPCanisterActor := actor(Principal.toText(wicpCanisterId));
        return true;
    };

    //change owner
    public shared(msg) func setOwner(newOwner: Principal) : async Bool {
        assert(msg.caller == owner);
        owner := newOwner;
        return true;
    };

    public shared(msg) func wallet_receive() : async Nat {
        let available = Cycles.available();
        let accepted = Cycles.accept(available);
        return accepted;
    };

    //get All Listing on marketplace
    public query func getListings() : async [(NftPhotoStoreCID, Listings)] {

        var ret: [(NftPhotoStoreCID, Listings)] = [];
        for((k,v) in listings.entries()){
            let identity:NftPhotoStoreCID = {
                index = k;
                canisterId = nftStoreCID;
            };
            ret := Array.append(ret, [(identity, v)]);
        };
        return ret;
    };

     //get All soldListing on marketplace
    public query func getSoldListings() : async [(NftPhotoStoreCID, SoldListings)] {

        var ret: [(NftPhotoStoreCID, SoldListings)] = [];
        for((k,v) in soldListings.entries()){
            let identity:NftPhotoStoreCID = {
                index = k;
                canisterId = nftStoreCID;
            };
            ret := Array.append(ret, [(identity, v)]);
        };
        return ret;
    };

    public query func isList(index: TokenIndex) : async ?Listings {
        listings.get(index)
    };

    public query func ownerOf(tokenIndex: TokenIndex) : async ?Principal {
        _ownerOf(tokenIndex)
    };

    public query func balanceOf(user: Principal) : async Nat {
        _balanceOf(user)
    };

    public query func getCycles() : async Nat {
        return Cycles.balance();
    };

    public query func getWICPCanisterId() : async Principal {
        Principal.fromActor(WICPCanisterActor)
    };

    //get all NFT of user
    public query func getAllNFT(user: Principal) : async [(TokenIndex, Principal)] {
        var ret: [(TokenIndex, Principal)] = [];
        for((k,v) in owners.entries()){
            if(v == user){
                ret := Array.append(ret, [ (k, nftStoreCID) ] );
            };
        };
        Array.sort(ret, func (x : (TokenIndex, Principal), y : (TokenIndex, Principal)) : { #less; #equal; #greater } {
            if (x.0 < y.0) { #less }
            else if (x.0 == y.0) { #equal }
            else { #greater }
        })
    };

    public shared(msg) func proAvailableMint() : async Bool {
        assert(msg.caller == owner);
        availableMint := HashMap.HashMap<TokenIndex, Bool>(1, Types.TokenIndex.equal, Types.TokenIndex.hash); 
        for(i in Iter.range(0,4999)){
            if(Option.isNull(owners.get(i))){
                availableMint.put(i, true);
            };
        };
        return true;
    };

    public query func getAvailableMint() : async [(TokenIndex, Bool)] {
        Iter.toArray(availableMint.entries())
    };


    private func getSeedFromCaller( user : Principal) : Nat {
        
        let chars = Principal.toText(user).chars();

        var num : Nat32 = 0;
        label outer for (v in chars){
            if(v == '-'){
                break outer;
            };
            let charToNum = Char.toNat32(v);
            num += charToNum;        
        };
        Nat32.toNat(num)
    };

    private func randomNfts(mintAmount: Nat, user : Principal) : [Nat] {
        var ret: [Nat] = [];

        let seed = Int.abs(Time.now()) + getSeedFromCaller(user);
        let arr = Iter.toArray(availableMint.entries());
        if(arr.size() < mintAmount){
            return ret;
        };
        for(i in Iter.range(0, mintAmount-1)){
            var lotteryIndex = ( seed/(i+1)) % arr.size();
            while( Option.isSome(Array.find<Nat>(ret, func(v) {v == arr[lotteryIndex].0})) ){
                lotteryIndex := (lotteryIndex + 1) % arr.size();
            };
            availableMint.delete(arr[lotteryIndex].0);
            ret := Array.append(ret, [arr[lotteryIndex].0]);
        };
        return ret;
    };

    private func _balanceOf(owner: Principal): Nat {
        switch(balances.get(owner)){
            case (?n){n};
            case _ {0};
        }
    };

    private func _transfer(from: Principal, to: Principal, tokenIndex: TokenIndex) {
        balances.put( from, _balanceOf(from) - 1 );
        balances.put( to, _balanceOf(to) + 1 );
        owners.put(tokenIndex, to);
    };

    private func _addSoldListings( orderInfo :Listings) {
        switch(soldListings.get(orderInfo.tokenIndex)){
            case (?sold){
                let newDeal = {
                    lastPrice = orderInfo.price;
                    time = Time.now();
                    account = sold.account + 1;
                };
                soldListings.put(orderInfo.tokenIndex, newDeal);
            };
            case _ {
                let newDeal = {
                    lastPrice = orderInfo.price;
                    time = Time.now();
                    account = 1;
                };
                soldListings.put(orderInfo.tokenIndex, newDeal);
            };
        };
    };

    private func _ownerOf(tokenIndex: TokenIndex) : ?Principal {
        owners.get(tokenIndex)
    };

    private func _checkOwner(tokenIndex: TokenIndex, from: Principal) : Bool {
        switch(owners.get(tokenIndex)){
            case (?o){
                if(o == from){
                    true
                }else{
                    false
                }
            };
            case _ {false};
        }
    };
}
