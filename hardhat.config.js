require("@nomiclabs/hardhat-waffle");

const secret = require("./.env/secrets.json");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  paths: {
    sources: "./contracts",
    artifacts: "./src/artifacts",
  },
  defaultNetwork: "hardhat",
  networks: {
    ganache: {
      url: "http://127.0.0.1:7545",
      // accounts: [privateKey1, privateKey2, ...]
    },
  },
  // networks: {
  //   mumbai: {
  //     url: secret.mumbainode,
  //     accounts: [secret.secretKey],
  //   },
  // },
};
