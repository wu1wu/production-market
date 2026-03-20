require("@nomicfoundation/hardhat-toolbox");

// Load .env if available
const fs = require("fs");
const path = require("path");
const envPath = path.join(__dirname, ".env");
let PRIVATE_KEY = "0x" + "0".repeat(64); // placeholder

if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, "utf-8");
  const match = envContent.match(/DEPLOYER_PRIVATE_KEY=(.+)/);
  if (match) PRIVATE_KEY = match[1].trim();
}

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {},
    baseSepolia: {
      url: "https://sepolia.base.org",
      accounts: [PRIVATE_KEY],
      chainId: 84532
    },
    base: {
      url: "https://mainnet.base.org",
      accounts: [PRIVATE_KEY],
      chainId: 8453
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};
