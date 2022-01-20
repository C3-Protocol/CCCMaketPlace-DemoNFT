import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Float "mo:base/Float";
import Bool "mo:base/Bool";
import Cycles "mo:base/ExperimentalCycles";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Iter "mo:base/Iter";
import Types "../common/types";
import Hash "mo:base/Hash";

shared(msg) actor class MetaData(_owner: Principal) = this {
    type HttpRequest = Types.HttpRequest;
    type HttpResponse = Types.HttpResponse;
    type Component = Types.Component;
    type TokenIndex = Types.TokenIndex;
    type Result<T,E> = Result.Result<T,E>;
    type Image = Types.Image;

    private stable var owner : Principal = _owner;
    private stable var imageDatas: [var Types.Image] = Array.init<Types.Image>(10000, Blob.fromArray([]));

    private stable var componentsEntries : [(TokenIndex, Component)] = [];
    private var components = HashMap.HashMap<TokenIndex, Component>(1, Types.TokenIndex.equal, Types.TokenIndex.hash); 

    public shared(msg) func uploadImage(token_id: Nat,tokenImage: Blob): async Bool {
        assert(msg.caller == owner);
        imageDatas[token_id] := tokenImage;
        true
    };

    public shared(msg) func uploadComponents(components_data: [Component]): async Bool {
        assert(msg.caller == owner);
        for (data in components_data.vals()) {
            components.put(data.nftId, data);
        };
        true
    };

    public query func getComponentByIndex(index: TokenIndex): async ?Component {
        components.get(index)
    };

    public shared(msg) func deleteImage(token_id: Nat): async Bool{
        assert(msg.caller == owner);
        imageDatas[token_id] := Blob.fromArray([]);
        true
    };

    public query func http_request(request: HttpRequest) : async HttpResponse {
        
        let path = Iter.toArray(Text.tokens(request.url, #text("/")));
        if (path.size() != 2){
            assert(false);
        };

        var nftData :Image = Blob.fromArray([]);
        let tokenId = Types.textToNat(path[1]);

        if (path[0] == "nft") {
            nftData := imageDatas[tokenId];
        }else {assert(false)};

        return {
                body = nftData;
                headers = [("Content-Type", "image/png")];
                status_code = 200;
                streaming_strategy = null;
        };
    };

    public shared(msg) func wallet_receive() : async Nat {
        let available = Cycles.available();
        let accepted = Cycles.accept(available);
        return accepted;
    };

    public query func getCycles() : async Nat {
        return Cycles.balance();
    };

    system func preupgrade() {    
    };

    system func postupgrade() {
    };
 
}