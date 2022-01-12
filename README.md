# WrapNft on CCC MarketPlace
support other NFT project launched on CCC platform marketplace

## How to launched your NFT on CCC marketplace

### WrapNFT.mo
it's the major smart contract, store all the nft-owner relationship,and support list/cancelList/transferFrom/batchTransferFrom and so on.

### storage.mo
it store all the transaction records, so every tx can be tracked.

## what you need to do?
1. deploy the two canister: WrapNFT.mo and storage.mo
2. use mint interface to set nft-owner relationship into WrapNFT canister
3. set your nft-store canister-id into WrapNFT canister
   
provide your nft-store canister-id, and set into thr WrapNFT, yout nft-store canister must provide a https_request to show your nft-photo or nft-video, than ccc web-front can show on marketplace.

## Interface
### Must Interface
* transferFrom
* list
* cancelList
* buyNow
* getListings
* getSoldListings
* isList
* getAllNFT
* balanceOf

### Optioin Interface
* mint
* airdrop
* pubSell
* approve
* batchTransferFrom
* setApprovalForAll

## why you need to launched on ccc marketplace.

we use WICP that created by C3-Prootocol, alreay have more than 4k customers, and more than 70K+ WICP transactions. you can check the website. 
https://opdit-ciaaa-aaaah-aa5ra-cai.ic0.app/#/index
use WICP can guarantee the atomic transaction.

## Contract us
Twitter: https://twitter.com/CCCProtocol

Email:   C3-Protocol@outlook.com