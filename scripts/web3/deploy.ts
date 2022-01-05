// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, name, symbol, web3, network } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  const web3ChainId = await web3.eth.getChainId();

  if (network.config.chainId !== web3ChainId) {
    return console.log("WEB3 Network doesn't match --network flag");
  }

  const account = await web3.eth.getAccounts();

  const [TOKEN_ADMIN, ACPI_MODERATOR] = await ethers.getSigners();

  const regFactory = await ethers.getContractFactory("REG");

  const { data: regData } = regFactory.getDeployTransaction(
    name,
    symbol,
    TOKEN_ADMIN.address
  );

  const tx1 = await web3.eth.sendTransaction({
    from: account[0],
    data: regData?.toString(),
  });

  const regAddress = tx1.contractAddress;

  if (!regAddress) {
    return console.log("REG Address was undefined ");
  }

  const acpiMasterFactory = await ethers.getContractFactory("ACPIMaster");

  const { data: acpiData } = acpiMasterFactory.getDeployTransaction(
    regAddress,
    TOKEN_ADMIN.address,
    ACPI_MODERATOR.address
  );

  const tx2 = await web3.eth.sendTransaction({
    from: account[0],
    data: acpiData?.toString(),
  });

  console.log("REG is deployed to: ", regAddress);
  console.log("ACPIMaster is deployed to: ", tx2.contractAddress);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
