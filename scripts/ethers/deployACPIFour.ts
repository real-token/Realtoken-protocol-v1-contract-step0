// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, run } from "hardhat";

import { minuteSleep } from "../../utils";

async function main(acpiMasterAddress?: string) {
  const acpiMaster =
    acpiMasterAddress ?? "0xf93c133062A8FD52A65051BD121C4AEB192e8b4a";

  const acpiFourFactory = await ethers.getContractFactory("ACPIFour");
  const acpiFour = await acpiFourFactory.deploy(acpiMaster);

  await acpiFour.deployed();

  console.log("Contract has been deployed! : " + acpiFour.address);

  await minuteSleep();

  try {
    await run("verify:verify", {
      address: acpiFour.address,
      constructorArguments: [acpiMaster],
    });
  } catch (err) {
    console.error(err);
  }

  return acpiFour.address;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

export default main;
