import { ethers, run } from "hardhat";

import { minuteSleep } from "../../utils";

async function main(regTokenAddress?: string) {
  const regToken =
    regTokenAddress ?? "0xe3BEC39D9b08f9672Be1E128880F6747273B1e89";

  const { TOKEN_ADMIN_PUBLIC, ACPI_MODERATOR_PUBLIC } = process.env;
  if (!TOKEN_ADMIN_PUBLIC || !ACPI_MODERATOR_PUBLIC)
    throw new Error(
      "Must have TOKEN_ADMIN_PUBLIC and ACPI_MODERATOR_PUBLIC env set, please refer to readme"
    );

  const acpiMasterFactory = await ethers.getContractFactory("ACPIMaster");
  const acpiMaster = await acpiMasterFactory.deploy(
    regToken,
    TOKEN_ADMIN_PUBLIC,
    ACPI_MODERATOR_PUBLIC
  );

  await acpiMaster.deployed();

  console.log("ACPI Master has been deployed! : " + acpiMaster.address);

  await minuteSleep();

  try {
    await run("verify:verify", {
      address: acpiMaster.address,
      constructorArguments: [
        regToken,
        TOKEN_ADMIN_PUBLIC,
        ACPI_MODERATOR_PUBLIC,
      ],
    });
  } catch (err) {
    console.error(err);
  }

  return acpiMaster.address;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

export default main;
