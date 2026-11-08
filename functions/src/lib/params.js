// Every key and deploy-time setting the functions read. Secrets live in
// Google Secret Manager (`firebase functions:secrets:set NAME`); strings come
// from functions/.env or .env.<project-id> (see .env.example). See README.md.
const {
  defineBoolean,
  defineList,
  defineSecret,
  defineString,
} = require("firebase-functions/params");

// --- Blockchain (Polygon) ---------------------------------------------------
// Private key of the wallet that owns the ERC-20 / NFT contracts and pays gas.
const MINTER_PRIVATE_KEY = defineSecret("MINTER_PRIVATE_KEY");
// JSON-RPC endpoint for the chain (often contains a provider API key).
const RPC_URL = defineSecret("RPC_URL");
const CHAIN_ID = defineString("CHAIN_ID", {
  default: "80002",
  description: "EVM chain id: 80002 = Polygon Amoy testnet, 137 = Polygon mainnet.",
});
const ERC20_TOKEN_ADDRESS = defineString("ERC20_TOKEN_ADDRESS", {
  description: "Address of the deployed ERC20Token contract (contracts/).",
});
const ERC20_TOKEN_SYMBOL = defineString("ERC20_TOKEN_SYMBOL", {
  default: "GGMT",
  description: "Symbol of that token; GetWalletTokenBalances reports this one.",
});
const NFT_CONTRACT_ADDRESS = defineString("NFT_CONTRACT_ADDRESS", {
  description: "Address of the deployed NFT contract (contracts/).",
});

// --- Moralis (wallet balances, NFTs, transfers, token holders, IPFS) --------
const MORALIS_API_KEY = defineSecret("MORALIS_API_KEY");

// --- OpenAI -----------------------------------------------------------------
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");
const OPENAI_MODEL = defineString("OPENAI_MODEL", {
  default: "gpt-4.1",
  description: "Model for the calls that used GPT-4 (tags, chat, avatars).",
});
const OPENAI_FAST_MODEL = defineString("OPENAI_FAST_MODEL", {
  default: "gpt-4.1-mini",
  description: "Model for the calls that used GPT-3.5 / text-davinci-003.",
});

// --- Google -----------------------------------------------------------------
// Places API (text search, photos, place details / reviews).
const GOOGLE_MAPS_API_KEY = defineSecret("GOOGLE_MAPS_API_KEY");
// Cloud Translation API (v2, basic).
const GOOGLE_TRANSLATE_API_KEY = defineSecret("GOOGLE_TRANSLATE_API_KEY");
// Cloud Vision uses the functions' service account; no key needed.

// --- SendGrid ---------------------------------------------------------------
const SENDGRID_API_KEY = defineSecret("SENDGRID_API_KEY");
const SENDGRID_FROM_EMAIL = defineString("SENDGRID_FROM_EMAIL", {
  description: "Verified sender address for shop / place invitation emails.",
});
const SENDGRID_SHOP_TEMPLATE_ID = defineString("SENDGRID_SHOP_TEMPLATE_ID", {
  description: "SendGrid dynamic template id (d-...) for those emails.",
});

// --- Weaviate (avatar recommendations, brands) ------------------------------
const WEAVIATE_HOST = defineString("WEAVIATE_HOST", {
  description: "Weaviate cluster host without scheme, e.g. my-cluster.weaviate.cloud.",
});
const WEAVIATE_API_KEY = defineSecret("WEAVIATE_API_KEY");
// Weaviate's text2vec-cohere module vectorizes with this key.
const COHERE_API_KEY = defineSecret("COHERE_API_KEY");

// --- News push notifications ------------------------------------------------
const NEWS_PUSH_TO_ALL_USERS = defineBoolean("NEWS_PUSH_TO_ALL_USERS", {
  default: false,
  description: "Send news to every stored FCM token (m_users/*/credentials).",
});
const NEWS_PUSH_TEST_TOKENS = defineList("NEWS_PUSH_TEST_TOKENS", {
  default: [],
  description: "FCM tokens that always get news pushes (e.g. a test device).",
});

module.exports = {
  CHAIN_ID,
  COHERE_API_KEY,
  ERC20_TOKEN_ADDRESS,
  ERC20_TOKEN_SYMBOL,
  GOOGLE_MAPS_API_KEY,
  GOOGLE_TRANSLATE_API_KEY,
  MINTER_PRIVATE_KEY,
  MORALIS_API_KEY,
  NEWS_PUSH_TEST_TOKENS,
  NEWS_PUSH_TO_ALL_USERS,
  NFT_CONTRACT_ADDRESS,
  OPENAI_API_KEY,
  OPENAI_FAST_MODEL,
  OPENAI_MODEL,
  RPC_URL,
  SENDGRID_API_KEY,
  SENDGRID_FROM_EMAIL,
  SENDGRID_SHOP_TEMPLATE_ID,
  WEAVIATE_API_KEY,
  WEAVIATE_HOST,
};
