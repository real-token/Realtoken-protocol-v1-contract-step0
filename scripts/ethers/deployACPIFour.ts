// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, run } from "hardhat";

import { minuteSleep } from "../../utils";

async function main() {
  const acpiMaster = "0xf93c133062A8FD52A65051BD121C4AEB192e8b4a";

  const { TOKEN_ADMIN_PUBLIC, ACPI_MODERATOR_PUBLIC } = process.env;
  if (!TOKEN_ADMIN_PUBLIC || !ACPI_MODERATOR_PUBLIC)
    return console.log(
      "Must have TOKEN_ADMIN_PUBLIC and ACPI_MODERATOR_PUBLIC env set, please refer to readme"
    );

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
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
