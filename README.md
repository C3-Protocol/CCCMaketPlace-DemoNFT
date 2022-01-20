# Launched your NFT on CCC MarketPlace
support other NFT project launched on CCC platform marketplace

## How to launched your NFT on CCC marketplace

### Template.mo
it's the major smart contract, store all the nft-owner relationship,and support list/cancelList/transferFrom/batchTransferFrom and so on.

### storage.mo
it store all the transaction records, so every tx can be tracked.

## what you need to do?
1. deploy the two canister: Template.mo, storage.mo and metaData.mo
2. set nft-owner relationship into Template canister(through airdrop/mint/pubsell interface)
3. set your nft-store canister-id(metaData.mo) into Template canister
   
provide your nft-store canister-id, and set into the TemplateNFT, yout nft-store canister must provide a https_request to show your nft-photo or nft-video, than ccc web-front can show them on marketplace.

## Interface
### Must Interface
```shell
TemplateNFT.mo
/// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
/// @param _from The current owner of the NFT
/// @param _to The new owner
/// @param _tokenId The index NFT to transfer
/// @return tokenIndex if success, errorcode otherwise
public shared(msg) func transferFrom(from: Principal, to: Principal, tokenIndex: TokenIndex): async TransferResponse 

/// @notice List your Nft on marketplace
/// @param listReq include tokenindex and price
/// @return tokenIndex if success, errorcode otherwise
public shared(msg) func list(listReq: ListRequest): async ListResponse

/// @notice cancelList your Nft from marketplace
/// @param listReq include tokenindex and price
/// @return tokenIndex if success, errorcode otherwise
public shared(msg) func updateList(listReq: ListRequest): async ListResponse

/// @notice updateList your Nft from marketplace
/// @param listReq include tokenindex and price
/// @return tokenIndex if success, errorcode otherwise
public shared(msg) func updateList(listReq: ListRequest): async ListResponse

/// @notice buyNow buy Nft from marketplace
/// @param buyRequest include tokenindex, feeTo and marketFeeRatio
/// @return tokenIndex if success, errorcode otherwise
public shared(msg) func buyNow(buyRequest: BuyRequest): async BuyResponse

/// @notice get all list nft
/// @return all listed NFT
public query func getListings() : async [(NftPhotoStoreCID, Listings)]

/// @notice Query the NFTs that have been traded recently
/// @return all Sold-listed NFT
public query func getSoldListings() : async [(NftPhotoStoreCID, SoldListings)]

/// @notice check if the index-nft listed
/// @return list-info
public query func isList(index: TokenIndex) : async ?Listings

/// @notice check if the index-nft listed
/// @return list-info
public query func isList(index: TokenIndex) : async ?Listings

/// @notice getAllNFT get all nft by principal-id
/// @param user principal-id
/// @return all user nft
public query func getAllNFT(user: Principal) : async [(TokenIndex, Principal)]

/// @notice balanceOf get number of user nfts
/// @return number
public query func balanceOf(user: Principal) : async Nat

MetaData.mo
/// @notice upload Nft-Image to canister
/// @param token_id & image blob data
/// @return true if success, false otherwise
public shared(msg) func uploadImage(token_id: Nat,tokenImage: Blob): async Bool

/// @notice http_request display Nft-Photo/video
/// @param request
public query func http_request(request: HttpRequest) : async HttpResponse

LedgerStorage.mo

/// @notice addRecord add tx record into storage canister
shared(msg) func addRecord(index: TokenIndex, op: Operation, from: ?Principal, to: ?Principal, price: ?Nat, timestamp: Time.Time) : async () 

/// @notice addBuyRecord add buyRecord into storage canister
public shared(msg) func addBuyRecord(index: TokenIndex, from: ?Principal, to: ?Principal,
price: ?Nat, timestamp: Time.Time) : async ()
```

### Optioin Interface
```shell
TemplateNFT.mo

/// @notice mint mint nft to users
/// @param mintRequest
/// @return MintResponse
public shared(msg) func mint(mintRequest: [MintRequest]): async MintResponse

/// @notice accroding to your nft project logic
public shared(msg) func airDrop(): async Bool 

/// @notice accroding to your nft project logic
public shared(msg) func pubSell(): async Bool

/// @notice Change or reaffirm the approved address for an NFT
///  Throws unless msg.caller is the current NFT owner, or an authorized
///  operator of the current owner.
/// @param _approved The new approved NFT controller
/// @param tokenIndex The index NFT to approve
/// @return True if success, false otherwise
public shared(msg) func approve(approve: Principal, tokenIndex: TokenIndex): async Bool

/// @notice Enable or disable approval for a third party ("operator") to manage
///  all of msg.caller assets
/// @dev Emits the ApprovalForAll event. The contract MUST allow
///  multiple operators per owner.
/// @param _operator Address to add to the set of authorized operators
/// @param _approved True if the operator is approved, false to revoke approval
/// @return True if success, false otherwise
public shared(msg) func setApprovalForAll(operatored: Principal, approved: Bool): async Bool

/// @notice batchTransfer ownership of some NFT -- THE CALLER IS RESPONSIBLE
/// @param _from The current owner of the NFT
/// @param _tos The new owners
/// @param tokenIndexs The index NFT to transfer
/// @return tokenIndex if success, errorcode otherwise
public shared(msg) func batchTransferFrom(from: Principal, tos: [Principal], tokenIndexs: [TokenIndex]): async TransferResponse
```

## What benefit of launched on ccc marketplace.

* we use WICP that created by C3-Prootocol, alreay have more than 4k customers, and more than 73K+ WICP transactions. you can check the website. 
https://opdit-ciaaa-aaaah-aa5ra-cai.ic0.app/#/index
use WICP can guarantee the atomic transaction.

* We put the account that receives the commission in the parameters of buyNow, that means all front-end trading markets can integrate this standard nft to earn commission fees. and project can set royaltyfeeRatio to earn royalty fee at every transaction.


## Contract us
Twitter: https://twitter.com/CCCProtocol

Email:   C3-Protocol@outlook.com