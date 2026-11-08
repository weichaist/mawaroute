const { HttpsError } = require("firebase-functions/v2/https");

const checkLogin = (auth) => {
  if (auth == null) {
    throw new HttpsError("unknown", "Login required.");
  }
};

module.exports = { checkLogin };
