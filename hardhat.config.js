require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-ethers");
require('hardhat-contract-sizer');
require('@openzeppelin/hardhat-upgrades');

const { PRIVATE_KEY, ALCHEMY_API_KEY, POLYGONSCAN_API_KEY, ETHERSCAN_API_KEY, SNOWTRACE_API_KEY } = require('./secret.json');

module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    polygon: {
      url: `https://polygon-rpc.com/`,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    polygonMumbai: {
      url: `https://rpc-mumbai.maticvigil.com/`,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161`,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    ropsten: {
      url: `https://ropsten.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161`,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    kovan: {
      url: `https://eth-kovan.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    avalancheFujiTestnet: {
      url: `https://api.avax-test.network/ext/bc/C/rpc`,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: {
      mainnet: `${ETHERSCAN_API_KEY}`,
      ropsten: `${ETHERSCAN_API_KEY}`,
      rinkeby: `${ETHERSCAN_API_KEY}`,
      goerli: `${ETHERSCAN_API_KEY}`,
      kovan: `${ETHERSCAN_API_KEY}`,

      // binance smart chain
      // bsc: "YOUR_BSCSCAN_API_KEY",
      // bscTestnet: "YOUR_BSCSCAN_API_KEY",


      // polygon
      polygon: `${POLYGONSCAN_API_KEY}`,
      polygonMumbai: `${POLYGONSCAN_API_KEY}`,

      
      // avalanche
      avalanche: `${SNOWTRACE_API_KEY}`,
      avalancheFujiTestnet: `${SNOWTRACE_API_KEY}`,
      
      // xdai and sokol don't need an API key, but you still need
      // to specify one; any string placeholder will work
      // xdai: "api-key",
      // sokol: "api-key",
    }
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
  },
};