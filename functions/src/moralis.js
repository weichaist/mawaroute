// Wallet data and IPFS uploads through the Moralis API.
const admin = require("firebase-admin");
const axios = require("axios");
const { logger } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { checkLogin } = require("./lib/auth");
const { STATUS, chainHex, fromWei, minterAddress, toWei } = require("./lib/chain");
const { moralis } = require("./lib/clients");
const {
  ERC20_TOKEN_ADDRESS,
  ERC20_TOKEN_SYMBOL,
  MINTER_PRIVATE_KEY,
  MORALIS_API_KEY,
} = require("./lib/params");

const getOptions = (address) => {
  return {
    address: address,
    chain: chainHex(),
    limit: 10,
  };
};

const moralisOptions = { secrets: [MORALIS_API_KEY] };

exports.GetWalletTokenBalances = onCall(moralisOptions, async ({ data, auth }) => {
  checkLogin(auth);
  try {
    logger.info("Calling getWalletTokenBalances!", { structuredData: true });
    const Moralis = await moralis();
    const { address } = data;
    const options = getOptions(address);
    delete options.limit;
    const response = await Moralis.EvmApi.token.getWalletTokenBalances(options);
    let balance = toWei(0);
    for (const item of response.raw) {
      if (item.symbol === ERC20_TOKEN_SYMBOL.value()) {
        balance = item.balance;
      }
    }
    return fromWei(balance);
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Call getWalletTokenBalances.");
  }
});

// From mawaroute_token_cloud_functions: image URLs of the NFTs a wallet holds.
exports.GetWalletNFTs = onCall(moralisOptions, async ({ data, auth }) => {
  checkLogin(auth);
  try {
    logger.info("Calling getWalletNFTs!", { structuredData: true });
    const Moralis = await moralis();
    const { address } = data;
    const options = getOptions(address);
    const response = await Moralis.EvmApi.nft.getWalletNFTs(options);
    const images = [];
    for (const element of response.raw.result) {
      const metadataResponse = await axios.get(element.token_uri);
      images.push(metadataResponse.data.image);
    }
    return images;
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Call getWalletNFTs.");
  }
});

// From mawaroute_token_cloud_functions: the wallet's last ERC-20 transfers.
exports.GetWalletTokenTransfers = onCall(moralisOptions, async ({ data, auth }) => {
  checkLogin(auth);
  try {
    logger.info("Calling getWalletTokenTransfers!", { structuredData: true });
    const Moralis = await moralis();
    const { address } = data;
    const options = getOptions(address);
    const response = await Moralis.EvmApi.token.getWalletTokenTransfers(options);
    const results = [];
    for (const element of response.raw.result) {
      results.push({
        "fromAddress": element.from_address,
        "toAddress": element.to_address,
        "value": fromWei(element.value),
      });
    }
    return results;
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Call getWalletTokenTransfers.");
  }
});

// Top 30 holders of the ERC-20 token, minus the minter wallet. Used by the
// business console's "Top token holders" screen. The original scraped the
// Mumbai Polygonscan holders page, which no longer exists; this asks Moralis.
exports.GetTopGGMTHolders = onCall(
  { timeoutSeconds: 180, secrets: [MORALIS_API_KEY, MINTER_PRIVATE_KEY] },
  async ({ auth }) => {
    try {
      checkLogin(auth);
      logger.info("Top token holders!", { structuredData: true });
      const Moralis = await moralis();
      const response = await Moralis.EvmApi.token.getTokenOwners({
        chain: chainHex(),
        tokenAddress: ERC20_TOKEN_ADDRESS.value(),
        order: "DESC",
        limit: 31,
      });
      const signerAddress = minterAddress().toLowerCase();
      const holders = [];
      for (const owner of response.raw.result) {
        const address = owner.owner_address.toLowerCase();
        if (address !== signerAddress) {
          // Whole tokens as an integer string; the console parses it with int.parse.
          const value = owner.balance_formatted.split(".")[0];
          holders.push({ address, value });
        }
      }
      return holders.slice(0, 30);
    } catch (e) {
      logger.info(e, { structuredData: true });
      throw new HttpsError("unknown", "Could Not Get Top GGMT Holders.");
    }
  },
);

// From mawaroute_token_cloud_functions: step 1 of the NFT flow. Uploads an
// image to IPFS and creates biz_users/{uid}/nfts/{id}; returns the id.
exports.UploadToIPFS = onCall(moralisOptions, async ({ data, auth }) => {
  checkLogin(auth);
  try {
    logger.info("Upload To IPFS!", { structuredData: true });
    const Moralis = await moralis();
    const uid = auth.uid;
    const { imageData, fileName } = data;
    const abi = [
      {
        path: fileName,
        content: Buffer.from(imageData).toString("base64"),
      },
    ];
    const imageFile = await Moralis.EvmApi.ipfs.uploadFolder({ abi });
    const imageURI = imageFile.result[0].path;
    const nftData = await admin.firestore().collection("biz_users").doc(uid).collection("nfts").add({
      image: imageURI, status: STATUS.UPLOADED_IMAGE_TO_IPFS,
    });
    return nftData.id;
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Upload.");
  }
});

// From mawaroute_token_cloud_functions: step 2 of the NFT flow. Stores the
// NFT details, uploads metadata.json to IPFS and returns its URI.
exports.UploadIPFSMetaData = onCall(moralisOptions, async ({ data, auth }) => {
  checkLogin(auth);
  try {
    logger.info("Upload To IPFS Meta data!", { structuredData: true });
    const Moralis = await moralis();
    const uid = auth.uid;
    const {
      id,
      name,
      price,
      description,
      externalLink,
      supply,
      blockchain,
    } = data;
    const nftObj = {
      name: name,
      price: price,
      description: description,
      externalLink: externalLink,
      supply: supply,
      blockchain: blockchain,
      event_id: "",
      status: STATUS.STORING_METADATA_IN_DB,
    };
    const nftDataRef = admin.firestore().collection("biz_users").doc(uid).collection("nfts").doc(id);
    const nftData = await nftDataRef.get();
    if (!nftData.exists) {
      throw new HttpsError("unknown", "Wrong ID Given.");
    }
    await nftDataRef.update(nftObj);
    const abi = [
      {
        path: "metadata.json",
        content: {
          "name": name,
          "image": nftData.data().image,
          "price": price,
          "description": description,
          "externalLink": externalLink,
          "supply": supply,
          "blockchain": blockchain,
        },
      },
    ];
    const metadataFile = await Moralis.EvmApi.ipfs.uploadFolder({ abi });
    const metadataURI = metadataFile.result[0].path;
    await nftDataRef.update({
      metadataURI: metadataURI,
      status: STATUS.UPLOADED_METADATA_TO_IPFS,
    });
    return metadataURI;
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Upload Meta data.");
  }
});
