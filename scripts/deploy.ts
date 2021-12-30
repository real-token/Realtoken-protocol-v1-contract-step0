// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, name, symbol } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  const [, ACPI_MODERATOR] = await ethers.getSigners();

  const regFactory = await ethers.getContractFactory("REG");
  const regToken = await regFactory.deploy(name, symbol, {
    gasLimit: 3500000,
  });

  await regToken.deployed();

  const acpiMasterFactory = await ethers.getContractFactory("ACPIMaster");
  const acpiMaster = await acpiMasterFactory.deploy(
    regToken.address,
    ACPI_MODERATOR.address,
    {
      gasLimit: 8500000,
    }
  );

  await acpiMaster.deployed();

  await regToken.contractTransfer(
    acpiMaster.address,
    ethers.utils.parseUnits("12000", "ether")
  );
  console.log("Contract has been deployed!");

  const acpiOne = await acpiMaster.acpiOneContract();
  const acpiTwo = await acpiMaster.acpiTwoContract();
  const acpiThree = await acpiMaster.acpiThreeContract();
  const acpiFour = await acpiMaster.acpiFourContract();

  console.log("ACPI 1 is deployed to: " + acpiOne);
  console.log("ACPI 2 is deployed to: " + acpiTwo);
  console.log("ACPI 3 is deployed to: " + acpiThree);
  console.log("ACPI 4 is deployed to: " + acpiFour);

  console.log("REG is deployed to: ", regToken.address);
  console.log("ACPIMaster is deployed to: ", acpiMaster.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
