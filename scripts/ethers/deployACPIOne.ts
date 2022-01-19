import { ethers, run } from "hardhat";

import { minuteSleep } from "../../utils";

async function main(acpiMasterAddress?: string) {
  const acpiMaster =
    acpiMasterAddress ?? "0xf93c133062A8FD52A65051BD121C4AEB192e8b4a";

  const acpiOneFactory = await ethers.getContractFactory("ACPIOne");
  const acpiOne = await acpiOneFactory.deploy(acpiMaster);

  await acpiOne.deployed();

  console.log("Contract has been deployed! : " + acpiOne.address);

  await minuteSleep();

  try {
    await run("verify:verify", {
      address: acpiOne.address,
      constructorArguments: [acpiMaster],
    });
  } catch (err) {
    console.error(err);
  }

  return acpiOne.address;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

export default main;
