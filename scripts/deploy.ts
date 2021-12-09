// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, run, name, symbol } from "hardhat";

function sleep(ms: number | undefined) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function minuteSleep() {
  console.log("Waiting for 60s before contracts verifications begins");

  for (let i = 1; i <= 6; i++) {
    await sleep(10 * 1000);
    console.log(i * 10 + "s");
  }

  console.log("Done");
}

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  const [, ACPI_MODERATOR] = await ethers.getSigners();

  const RealtFactory = await ethers.getContractFactory("RealT");
  const realtToken = await RealtFactory.deploy(
    name,
    symbol,
    ACPI_MODERATOR.address,
    { gasLimit: 10000000 }
  );

  await realtToken.deployed();

  console.log("Contract has been deployed!");

  await minuteSleep();

  try {
    await run("verify:verify", {
      address: realtToken.address,
      constructorArguments: [name, symbol, ACPI_MODERATOR.address],
    });
  } catch (err) {
    console.error(err);
  }

  const acpiOne = await realtToken.acpiOne();
  const acpiTwo = await realtToken.acpiTwo();
  const acpiThree = await realtToken.acpiThree();
  const acpiFour = await realtToken.acpiFour();

  console.log("ACPI 1 is deployed to: " + acpiOne);
  console.log("ACPI 2 is deployed to: " + acpiTwo);
  console.log("ACPI 3 is deployed to: " + acpiThree);
  console.log("ACPI 4 is deployed to: " + acpiFour);

  try {
    await run("verify:verify", {
      address: acpiOne,
      constructorArguments: [],
    });
  } catch (err) {
    console.error(err);
  }
  try {
    await run("verify:verify", {
      address: acpiTwo,
      constructorArguments: [],
    });
  } catch (err) {
    console.error(err);
  }
  try {
    await run("verify:verify", {
      address: acpiThree,
      constructorArguments: [],
    });
  } catch (err) {
    console.error(err);
  }
  try {
    await run("verify:verify", {
      address: acpiFour,
      constructorArguments: [],
    });
  } catch (err) {
    console.error(err);
  }
  console.log("RealT is deployed to: ", realtToken.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
