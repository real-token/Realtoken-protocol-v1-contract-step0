import { ethers, run } from "hardhat";

import { minuteSleep } from "../../utils";

async function main(acpiMasterAddress?: string) {
  const acpiMaster =
    acpiMasterAddress ?? "0xb55D5b540EC11cE2515194EF1472c2e103c1e04e";

  const { TOKEN_ADMIN_PUBLIC, ACPI_MODERATOR_PUBLIC } = process.env;
  if (!TOKEN_ADMIN_PUBLIC || !ACPI_MODERATOR_PUBLIC)
    throw new Error(
      "Must have TOKEN_ADMIN_PUBLIC and ACPI_MODERATOR_PUBLIC env set, please refer to readme"
    );

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
