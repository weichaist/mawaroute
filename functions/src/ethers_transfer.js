// ERC-20 token mint / transfer and MATIC (POL) top-ups from the minter wallet.
const admin = require("firebase-admin");
const { logger } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { checkLogin } = require("./lib/auth");
const { loadERC20TokenContract, rpcSigner, toWei } = require("./lib/chain");
const { MINTER_PRIVATE_KEY, RPC_URL } = require("./lib/params");

const chainOptions = { timeoutSeconds: 180, secrets: [MINTER_PRIVATE_KEY, RPC_URL] };

// Amount of the chain's native coin sent by TransferMatic so a new wallet can pay gas.
const MATIC_TOP_UP_AMOUNT = 0.001;

const transferERC20TokenFromUid = async (data) => {
  const { transferredAmount, uid } = data;
  const userDoc = await admin.firestore().collection("m_users").doc(uid).get();

  if (!userDoc.exists) {
    throw new HttpsError("not-found", "User document does not exist.");
  }
  const userData = userDoc.data();
  const transferAddress = userData.public_address;

  try {
    const signer = rpcSigner();
    const erc20Token = loadERC20TokenContract(signer);
    await (await erc20Token.transfer(transferAddress, toWei(transferredAmount))).wait();
  } catch (e) {
    const ref = admin.firestore().collection("transfer_failures");
    await ref.add({
      user: uid,
      transferredAmount: transferredAmount,
      transferAddress: transferAddress,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Transfer ERC20Token from UID during transfer.");
  }
};

exports.TransferERC20TokenFromUidV2 = onCall(chainOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Transfer ERC20Token from UID!", { structuredData: true });
    await transferERC20TokenFromUid(data);
  } catch (error) {
    logger.info(error, { structuredData: true });
    throw new HttpsError("unknown", "Some error is in data of Transfer ERC20Token from UID.");
  }
  return null;
});

exports.TransferERC20TokenFromUid = onCall(chainOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Transfer ERC20Token from UID!", { structuredData: true });
    await transferERC20TokenFromUid(data);
  } catch (error) {
    logger.info(error, { structuredData: true });
    throw new HttpsError("unknown", "Some error is in data of Transfer ERC20Token from UID.");
  }
  return null;
});

exports.TransferMatic = onCall(chainOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Transfer Matic!", { structuredData: true });
    const { transferAddress } = data;
    const transferAmount = MATIC_TOP_UP_AMOUNT;

    try {
      const signer = rpcSigner();
      const transaction = {
        to: transferAddress,
        value: toWei(transferAmount),
      };
      const transactionResponse = await signer.sendTransaction(transaction);
      logger.info(`Transaction hash: ${transactionResponse.hash}`, { structuredData: true });
      const receipt = await transactionResponse.wait();
      logger.info(`Transaction receipt: ${receipt.blockNumber}`, { structuredData: true });
    } catch (e) {
      const ref = admin.firestore().collection("transfer_failures");
      await ref.add({
        user: auth.uid,
        function_name: "TransferMatic",
        transferredAmount: transferAmount,
        transferAddress: transferAddress,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      logger.info(e, { structuredData: true });
      throw new HttpsError("unknown", "Could Not Transfer Matic during transfer.");
    }
  } catch (error) {
    logger.info(error, { structuredData: true });
    throw new HttpsError("unknown", "Some error is in data of Transfer Matic.");
  }
  return null;
});

exports.MintERC20Token = onCall(chainOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Mint ERC20Token!", { structuredData: true });
    const { mintAmount } = data;
    const signer = rpcSigner();
    const erc20Token = loadERC20TokenContract(signer);
    await (await erc20Token.mint(signer.address, toWei(mintAmount))).wait();
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Transfer ERC20Token.");
  }
  return null;
});
