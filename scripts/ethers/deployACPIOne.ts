import { ethers, run } from "hardhat";

import { minuteSleep } from "../../utils";

async function main() {
  const acpiMaster = "0x2Bd2a7Aa5670D62a8Ac8f8Fe9396b28012855AB8";

  const { TOKEN_ADMIN_PUBLIC, ACPI_MODERATOR_PUBLIC } = process.env;
  if (!TOKEN_ADMIN_PUBLIC || !ACPI_MODERATOR_PUBLIC)
    return console.log(
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
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
