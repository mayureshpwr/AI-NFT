require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    Polygon: {
      url: "",
      chainId: 137,
      accounts: [""], //  private key
    },
  },
  etherscan: {
    apiKey: "", // Hardcoded bsc  API key
  },
};

