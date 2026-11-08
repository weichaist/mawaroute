# MaWaRoute contracts

The Solidity contracts behind MaWaRoute's crypto rewards, as compiled
**Hardhat artifacts** (ABI plus creation and deployed bytecode) in
[`artifacts/`](artifacts).

**The Solidity sources are not in this repository.** No source repo was
found, so only the compiled artifacts are kept. They're enough to deploy the
contracts and call them. You can't change or re-verify them without
rewriting the sources. Each artifact still records its original path
(`contracts/<Name>.sol`).

Everything below is read from the ABIs and from strings in the bytecode.

## ERC20Token: the reward token ("GGMTToken", symbol `GGMT`)

`artifacts/ERC20Token.json`, with an empty constructor.

- Standard ERC-20 (18 decimals): `transfer`, `approve`, `transferFrom`,
  `allowance`, `balanceOf`, `totalSupply`, `increaseAllowance`, `decreaseAllowance`.
- `Ownable`: `owner`, `transferOwnership`, `renounceOwnership`.
- `mint(address to, uint256 amount)`. Judging by the `Ownable` pattern it's
  owner-only, but the source isn't available to confirm it.
- Burnable: `burn`, `burnFrom`.
- Pausable: `pause`, `unpause`, `paused`.

These look like OpenZeppelin's `ERC20`, `ERC20Burnable`, `Pausable` and `Ownable`.

How the functions use it ([`../functions/src/ethers_transfer.js`](../functions/src/ethers_transfer.js),
[`../functions/src/moralis.js`](../functions/src/moralis.js)):

- `MintERC20Token` calls `mint(minter, amount)`.
- `TransferERC20TokenFromUid(V2)` calls `transfer(userWallet, amount)` from the minter wallet.
- `GetWalletTokenBalances` and `GetTopGGMTHolders` read balances and holders through Moralis.

## NFT: reward / event NFTs (name "RonyToken")

`artifacts/NFT.json`, with an empty constructor.

- ERC-721 with metadata: `balanceOf`, `ownerOf`, `tokenURI`, `approve`,
  `setApprovalForAll`, `transferFrom`, `safeTransferFrom`, `supportsInterface`,
  `name`, `symbol`.
- `Ownable`.
- `mint(string metadataURI) payable returns (uint256)` mints a token with
  that URI to the caller. `count()` returns the number minted.
  `isContentOwned(string uri)` tells whether a URI has already been minted,
  so the same content can't be minted twice.

How the functions use it ([`../functions/src/nft.js`](../functions/src/nft.js)):
`Mint` calls `mint(uri)` from the minter wallet, using the metadata URI that
`UploadIPFSMetaData` produced.

## MarketPlace: fixed-price NFT marketplace

`artifacts/MarketPlace.json`, with `constructor(uint256 _feePercent)`.

- `makeItem(address nft, uint256 tokenId, uint256 price)` lists an NFT and
  emits `Offered`.
- `purchaseItem(uint256 itemId) payable` buys it, pays the seller and
  `feeAccount`, and emits `Bought`. It reverts with "not enough ether",
  "item doesn't exist" or "item already sold".
- `getTotalPrice(itemId)` returns the price plus the `feePercent` fee.
  `items(itemId)` returns `(itemId, nft, tokenId, price, seller, sold)`.
  `count()`, `feeAccount()` and `feePercent()` are getters.
- It's guarded by `ReentrancyGuard`.

No function calls it. It's kept because it was deployed with the other two.

## Deploying

Mumbai, the testnet the original used, was shut down in 2024. Deploy to
Polygon Amoy (chain id `80002`) for testing, or Polygon mainnet (`137`).
Any tool that can send a raw contract-creation transaction works. With ethers v6:

```js
const { ethers } = require("ethers");
const artifact = require("./artifacts/ERC20Token.json");
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, new ethers.JsonRpcProvider(process.env.RPC_URL));
const factory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, wallet);
const token = await factory.deploy();            // MarketPlace: factory.deploy(feePercent)
await token.waitForDeployment();
console.log(await token.getAddress());
```

Deploy from the same wallet you give the functions as `MINTER_PRIVATE_KEY`,
so it owns the contracts. Then set `ERC20_TOKEN_ADDRESS` and
`NFT_CONTRACT_ADDRESS` (see [`../functions/README.md`](../functions/README.md)).
The functions read only the `abi` field. Their copies are in
[`../functions/abi`](../functions/abi).

## Historical deployment (Mumbai, no longer reachable)

The old functions pointed at these Mumbai testnet addresses. They're listed
only for reference:

| Contract | Address |
| --- | --- |
| ERC20Token | `0x03E7F350bf9550AFdA1AC957550de9d55011747C` |
| MarketPlace | `0x1997C567A94c14bF8FAD2D61eB0B336516F9e942` |
| NFT | `0x3832853417b0e6796e9Bb1EaDEef07C843dE4808` |
