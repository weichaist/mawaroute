// Ethers helpers for the minter wallet and the deployed contracts.
const { ethers } = require("ethers");
const NFTArtifact = require("../../abi/NFT.json");
const ERC20TokenArtifact = require("../../abi/ERC20Token.json");
const {
  CHAIN_ID,
  ERC20_TOKEN_ADDRESS,
  MINTER_PRIVATE_KEY,
  NFT_CONTRACT_ADDRESS,
  RPC_URL,
} = require("./params");

const STATUS = {
  UPLOADED_IMAGE_TO_IPFS: "UPLOADED_IMAGE_TO_IPFS",
  STORING_METADATA_IN_DB: "STORING_METADATA_IN_DB",
  UPLOADED_METADATA_TO_IPFS: "UPLOADED_METADATA_TO_IPFS",
  MINTED: "MINTED",
};

const toWei = (num) => ethers.parseEther(num.toString());
const fromWei = (num) => ethers.formatEther(num);

const chainId = () => Number(CHAIN_ID.value());

// Moralis takes the chain as a hex string, e.g. "0x13882" for Amoy.
const chainHex = () => `0x${chainId().toString(16)}`;

const rpcSigner = () => {
  const provider = new ethers.JsonRpcProvider(RPC_URL.value(), chainId(), {
    staticNetwork: true,
  });
  return new ethers.Wallet(MINTER_PRIVATE_KEY.value(), provider);
};

const minterAddress = () => new ethers.Wallet(MINTER_PRIVATE_KEY.value()).address;

const loadNFTContract = (signer) =>
  new ethers.Contract(NFT_CONTRACT_ADDRESS.value(), NFTArtifact.abi, signer);

const loadERC20TokenContract = (signer) =>
  new ethers.Contract(ERC20_TOKEN_ADDRESS.value(), ERC20TokenArtifact.abi, signer);

module.exports = {
  STATUS,
  chainHex,
  fromWei,
  loadERC20TokenContract,
  loadNFTContract,
  minterAddress,
  rpcSigner,
  toWei,
};
