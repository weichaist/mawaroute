// NFT minting (from the earlier mawaroute_token_cloud_functions backend).
// Flow: UploadToIPFS -> UploadIPFSMetaData -> Mint, tracked in
// biz_users/{uid}/nfts/{nftId}.status (see STATUS in lib/chain.js).
const admin = require("firebase-admin");
const { logger } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { checkLogin } = require("./lib/auth");
const { STATUS, loadNFTContract, rpcSigner } = require("./lib/chain");
const { MINTER_PRIVATE_KEY, RPC_URL } = require("./lib/params");

exports.Mint = onCall(
  { timeoutSeconds: 180, secrets: [MINTER_PRIVATE_KEY, RPC_URL] },
  async ({ data, auth }) => {
    try {
      checkLogin(auth);
      logger.info("Mint!", { structuredData: true });
      const uid = auth.uid;
      const { uri, bizUserId, nftId } = data;
      const signer = rpcSigner();
      const nft = loadNFTContract(signer);
      await (await nft.mint(uri)).wait();
      const nftDataRef = admin.firestore()
        .collection("biz_users").doc(bizUserId)
        .collection("nfts").doc(nftId);
      await nftDataRef.update({
        status: STATUS.MINTED,
        minted_by: uid,
      });
    } catch (e) {
      logger.info(e, { structuredData: true });
      throw new HttpsError("unknown", "Could Not Mint.");
    }
    return null;
  },
);
