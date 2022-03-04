/**
 * Module     : storage.mo
 * Copyright  : 2021 Hellman Team
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Hellman Team - Leven
 * Stability  : Experimental
 */

import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Types "../common/types";
import Cycles "mo:base/ExperimentalCycles";

shared(msg) actor class Storage(_owner: Principal) {
    type OpRecord = Types.OpRecord;
    type Operation = Types.Operation;
    type TokenIndex = Types.TokenIndex;
    type NftPhotoStoreCID = Types.CanvasIdentity;

    private stable var owner_ : Principal = _owner;
    private stable var wrapNftCID : Principal = msg.caller;

    type ListRecord = List.List<OpRecord>;
    private stable var opsEntries: [(TokenIndex, [OpRecord])] = [];
    private var ops = HashMap.HashMap<TokenIndex, ListRecord>(1, Types.TokenIndex.equal, Types.TokenIndex.hash);
 
    private stable var userFavoriteEntries: [(Principal, [NftPhotoStoreCID])] = [];
    private var userFavorite = HashMap.HashMap<Principal, [NftPhotoStoreCID]>(1, Principal.equal, Principal.hash);

    private stable var nftFavoriteEntries : [(TokenIndex, Nat)] = [];
    private var nftFavorite = HashMap.HashMap<TokenIndex, Nat>(1, Types.TokenIndex.equal, Types.TokenIndex.hash);

    system func preupgrade() {
        userFavoriteEntries := Iter.toArray(userFavorite.entries());
        nftFavoriteEntries := Iter.toArray(nftFavorite.entries());

        var size0 : Nat = ops.size();
        var temp0 : [var (TokenIndex, [OpRecord])] = Array.init<(TokenIndex, [OpRecord])>(size0, (0, []));
        size0 := 0;
        for ((k, v) in ops.entries()) {
            temp0[size0] := (k, List.toArray(v));
            size0 += 1;
        };
        opsEntries := Array.freeze(temp0);
    };

    system func postupgrade() {
        userFavorite := HashMap.fromIter<Principal, [NftPhotoStoreCID]>(userFavoriteEntries.vals(), 1, Principal.equal, Principal.hash);
        nftFavorite := HashMap.fromIter<TokenIndex, Nat>(nftFavoriteEntries.vals(), 1, Types.TokenIndex.equal, Types.TokenIndex.hash);

        userFavoriteEntries := [];
        nftFavoriteEntries := [];

        for ((k, v) in opsEntries.vals()) {
            ops.put(k, List.fromArray<OpRecord>(v));
        };
        opsEntries := [];
    };

    public shared(msg) func setWrapNftCanisterId(multiNftCid: Principal) : async Bool {
        assert(msg.caller == owner_);
        wrapNftCID := multiNftCid;
        return true;
    };

    public query func getWrapNftCanisterId() : async Principal {
        wrapNftCID
    };

    private func _addRecord(index: TokenIndex, op: Operation, from: ?Principal, to: ?Principal, 
        price: ?Nat, timestamp: Time.Time
    ) {
        let o : OpRecord = {
            op = op;
            from = from;
            to = to;
            price = price;
            timestamp = timestamp;
        };
        switch (ops.get(index)) {
            case (?l) {
                let newl = List.push<OpRecord>(o, l);
                ops.put(index, newl);
            };
            case (_) {
                let l1 = List.nil<OpRecord>();
                let l2 = List.push<OpRecord>(o, l1);
                ops.put(index, l2);
            };   
        }
    };

    public shared(msg) func addRecord(index: TokenIndex, op: Operation, from: ?Principal, to: ?Principal, 
        price: ?Nat, timestamp: Time.Time
    ) : async () {
        assert( msg.caller == wrapNftCID);
        _addRecord(index, op, from, to, price, timestamp);
    };

    public shared(msg) func addBuyRecord(index: TokenIndex, from: ?Principal, to: ?Principal, 
        price: ?Nat, timestamp: Time.Time
    ) : async () {
        assert( msg.caller == wrapNftCID);
        _addRecord(index, #Sale, from, to, price, timestamp);
        _addRecord(index, #Transfer, from, to, null, timestamp);
    };

    public shared(msg) func setFavorite(user: Principal, info: NftPhotoStoreCID) : async () {
        assert( msg.caller == wrapNftCID);
        
        var ret: Bool = false; 
        switch(userFavorite.get(user)){
            case (?arr){
                if(Option.isNull(Array.find<NftPhotoStoreCID>(arr, func (x : NftPhotoStoreCID): Bool { x.index == info.index })))
                {
                    var arrNew : [NftPhotoStoreCID] = Array.append(arr, [info]);
                    userFavorite.put(user, arrNew);
                    ret := true;
                };
            };
            case _ {
                userFavorite.put(user, [info]);
                ret := true;
            };
        };
        if(ret){
            _addNftFavoriteNum(info.index);
        };
    };

    public shared(msg) func cancelFavorite(user: Principal, info: NftPhotoStoreCID) : async () {
        assert( msg.caller == wrapNftCID);
        
        var ret: Bool = false; 
        switch(userFavorite.get(user)){
            case (?arr){
                var arrNew : [NftPhotoStoreCID] = Array.filter<NftPhotoStoreCID>(arr, func (x : NftPhotoStoreCID): Bool { x.index != info.index } );
                userFavorite.put(user, arrNew);
                ret := true;
            };
            case _ {};
        };
        if(ret){
            _subNftFavoriteNum(info.index);
        };
    };

    public query func getFavorite(user: Principal): async [NftPhotoStoreCID] {
        var ret: [NftPhotoStoreCID] = [];
        switch(userFavorite.get(user)){
            case (?arr){
                ret := arr;
            };
            case _ {};
        };
        return ret;
    };

    public query func isFavorite(user:Principal, info: NftPhotoStoreCID): async Bool {
        var ret: Bool = false;
        switch(userFavorite.get(user)){
            case (?arr){
                for (v in arr.vals()) {
                    if(info.index == v.index and info.canisterId == v.canisterId)
                    {
                        ret := true;
                    };
                };
            };
            case _ {};
        };
        return ret;
    };

    public query func getNftFavoriteNum(index: TokenIndex): async Nat {
        var retNum: Nat = 0;
        switch(nftFavorite.get(index)){
            case (?n){
                retNum := n;
            };
            case _ {};
        };
        return retNum;
    };

    public query func getHistory(index: TokenIndex) : async [OpRecord] {
        var ret: [OpRecord] = [];
        switch (ops.get(index)) {
            case (?l) {
                ret := List.toArray(l);
            };
            case (_) {};   
        };
        return ret;
    };

    private func _addNftFavoriteNum(index: TokenIndex) {
        switch(nftFavorite.get(index)){
            case(?n) { nftFavorite.put(index, n + 1); };
            case _ { nftFavorite.put(index, 1); };
        };
    };

    private func _subNftFavoriteNum(index: TokenIndex) {
        switch(nftFavorite.get(index)){
            case(?n) { 
                nftFavorite.put(index, n - 1); 
                if(n ==1 ){ nftFavorite.delete(index); };
            };
            case _ {};
        };
    };

    public query func getCycles() : async Nat {
        return Cycles.balance();
    };

    public shared(msg) func wallet_receive() : async Nat {
        let available = Cycles.available();
        let accepted = Cycles.accept(available);
        return accepted;
    };

};