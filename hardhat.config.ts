import * as dotenv from "dotenv";

import { extendEnvironment, HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

import "./type-extensions";

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

extendEnvironment((hre) => {
  hre.symbol = "REG";
  hre.name = "Real Easte Governance";
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
    xdai: {
      url: process.env.XDAI_URL || "",
      accounts:
        process.env.ACPI_MODERATOR !== undefined && process.env.TOKEN_ADMIN_PK
          ? [process.env.TOKEN_ADMIN_PK, process.env.ACPI_MODERATOR]
          : [],
    },
    xdaiTest: {
      url: process.env.XDAITEST_URL || "",
      accounts:
        process.env.ACPI_MODERATOR !== undefined && process.env.TOKEN_ADMIN_PK
          ? [process.env.TOKEN_ADMIN_PK, process.env.ACPI_MODERATOR]
          : [],
    },
    ropsten: {
      url: process.env.ROPSTEN_URL || "",
      accounts:
        process.env.ACPI_MODERATOR !== undefined && process.env.TOKEN_ADMIN_PK
          ? [process.env.TOKEN_ADMIN_PK, process.env.ACPI_MODERATOR]
          : [],
    },
    kovan: {
      url: process.env.KOVAN_URL || "",
      accounts:
        process.env.ACPI_MODERATOR !== undefined && process.env.TOKEN_ADMIN_PK
          ? [process.env.TOKEN_ADMIN_PK, process.env.ACPI_MODERATOR]
          : [],
    },
    rinkeby: {
      url: process.env.RINKEBY_URL || "",
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
