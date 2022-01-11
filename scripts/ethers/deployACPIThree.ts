import { ethers, run } from "hardhat";

import { minuteSleep } from "../../utils";

async function main() {
  const acpiMaster = "0xf93c133062A8FD52A65051BD121C4AEB192e8b4a";

  const { TOKEN_ADMIN_PUBLIC, ACPI_MODERATOR_PUBLIC } = process.env;
  if (!TOKEN_ADMIN_PUBLIC || !ACPI_MODERATOR_PUBLIC)
    return console.log(
      "Must have TOKEN_ADMIN_PUBLIC and ACPI_MODERATOR_PUBLIC env set, please refer to readme"
    );

  const acpiThreeFactory = await ethers.getContractFactory("ACPIThree");
  const acpiThree = await acpiThreeFactory.deploy(acpiMaster);

  await acpiThree.deployed();

  console.log("Contract has been deployed! : " + acpiThree.address);

  await minuteSleep();

  try {
    await run("verify:verify", {
      address: acpiThree.address,
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
