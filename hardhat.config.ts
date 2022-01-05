import * as dotenv from "dotenv";

import {
  extendEnvironment,
  HardhatUserConfig,
  task,
  types,
} from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

import "./type-extensions";

import "@nomiclabs/hardhat-web3";

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("nonce", "Increase the nonce value by sending self transaction")
  .addParam("target", "Target nonce you want to achieve", 0, types.int)
  .setAction(async ({ target }, hre) => {
    const [DEPLOYER] = await hre.ethers.getSigners();
    const nonce = await hre.ethers.provider.getTransactionCount(
      DEPLOYER.address
    );
    if (!target) return console.log("Target can't be 0");
    if (nonce >= target)
      console.log(
        `Your nonce (${nonce}) is superior to target nonce ${target}`
      );

    const todo = target - nonce;

    console.log(`${todo} transaction difference, let's go!`);
    for (let i = 0; i < todo; i++) {
      const tx = await hre.web3.eth.sendTransaction({
        from: DEPLOYER.address,
        to: DEPLOYER.address,
      });
      console.log("Nonce increased! Tx: " + tx.transactionHash);
    }

    const newNonce = await hre.web3.eth.getTransactionCount(DEPLOYER.address);

    console.log("Current nonce is now : " + newNonce);
  });

extendEnvironment((hre) => {
  hre.symbol = "REG";
  hre.name = "Real Estate Governance";
  hre.deployerAddress = process.env.DEPLOYER_ADDRESS;
});

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {
      accounts: {
        count: 110,
      },
    },
    bsc: {
      chainId: 56,
      url: process.env.BSC_URL || "",
      accounts:
        process.env.ACPI_MODERATOR !== undefined && process.env.TOKEN_ADMIN_PK
          ? [process.env.TOKEN_ADMIN_PK, process.env.ACPI_MODERATOR]
          : [],
    },
    bsctest: {
      chainId: 97,
      url: process.env.BSCTEST_URL || "",
      accounts:
        process.env.ACPI_MODERATOR !== undefined && process.env.TOKEN_ADMIN_PK
          ? [process.env.TOKEN_ADMIN_PK, process.env.ACPI_MODERATOR]
          : [],
    },
    polygon: {
      chainId: 137,
      url: process.env.POLYGON_URL || "",
      accounts:
        process.env.ACPI_MODERATOR !== undefined && process.env.TOKEN_ADMIN_PK
          ? [process.env.TOKEN_ADMIN_PK, process.env.ACPI_MODERATOR]
          : [],
    },
    polygontest: {
      chainId: 80001,
      url: process.env.POLYGONTEST_URL || "",
      accounts:
        process.env.ACPI_MODERATOR !== undefined && process.env.TOKEN_ADMIN_PK
          ? [process.env.TOKEN_ADMIN_PK, process.env.ACPI_MODERATOR]
          : [],
    },
    xdai: {
      chainId: 100,
      url: process.env.XDAI_URL || "",
      accounts:
        process.env.ACPI_MODERATOR !== undefined && process.env.TOKEN_ADMIN_PK
          ? [process.env.TOKEN_ADMIN_PK, process.env.ACPI_MODERATOR]
          : [],
    },
    poa: {
      chainId: 77,
      url: process.env.POA_URL || "",
      accounts:
        process.env.ACPI_MODERATOR !== undefined && process.env.TOKEN_ADMIN_PK
          ? [process.env.TOKEN_ADMIN_PK, process.env.ACPI_MODERATOR]
          : [],
    },
    rinkeby: {
      chainId: 4,
      url: process.env.RINKEBY_URL || "",
      accounts:
        process.env.ACPI_MODERATOR !== undefined && process.env.TOKEN_ADMIN_PK
          ? [process.env.TOKEN_ADMIN_PK, process.env.ACPI_MODERATOR]
          : [],
    },
    kovan: {
      chainId: 42,
      url: process.env.KOVAN_URL || "",
      accounts:
        process.env.ACPI_MODERATOR !== undefined && process.env.TOKEN_ADMIN_PK
          ? [process.env.TOKEN_ADMIN_PK, process.env.ACPI_MODERATOR]
          : [],
    },
    goerli: {
      chainId: 420,
      url: process.env.GOERLI_URL || "",
      accounts:
        process.env.ACPI_MODERATOR !== undefined && process.env.TOKEN_ADMIN_PK
          ? [process.env.TOKEN_ADMIN_PK, process.env.ACPI_MODERATOR]
          : [],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    coinmarketcap: process.env.REPORT_GAS,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
