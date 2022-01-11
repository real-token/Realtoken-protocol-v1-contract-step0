// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, name, symbol, web3, network, run } from "hardhat";

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

  const regToken = "0xe3BEC39D9b08f9672Be1E128880F6747273B1e89";

  const { TOKEN_ADMIN_PUBLIC, ACPI_MODERATOR_PUBLIC } = process.env;
  if (!TOKEN_ADMIN_PUBLIC || !ACPI_MODERATOR_PUBLIC)
    return console.log(
      "Must have TOKEN_ADMIN_PUBLIC and ACPI_MODERATOR_PUBLIC env set, please refer to readme"
    );

  const web3ChainId = await web3.eth.getChainId();

  if (network.config.chainId !== web3ChainId) {
    return console.log("WEB3 Network doesn't match --network flag");
  }

  const account = await web3.eth.getAccounts();

  const acpiMasterFactory = await ethers.getContractFactory("ACPIMaster");

  const { data: acpiData } = acpiMasterFactory.getDeployTransaction(
    regToken,
    TOKEN_ADMIN_PUBLIC,
    ACPI_MODERATOR_PUBLIC
  );

  const tx2 = await web3.eth.sendTransaction({
    from: account[0],
    data: acpiData?.toString(),
  });

  await minuteSleep();

  if (!tx2.contractAddress) return;

  const acpiMaster = await ethers.getContractAt(
    "ACPIMaster",
    tx2.contractAddress
  );

  const acpiOne = await acpiMaster.acpiOneContract();
  // const acpiTwo = await acpiMaster.acpiTwoContract();
  // const acpiThree = await acpiMaster.acpiThreeContract();
  // const acpiFour = await acpiMaster.acpiFourContract();

  try {
    await run("verify:verify", {
      address: acpiOne,
      constructorArguments: [],
    });
  } catch (err) {
    console.error(err);
  }
  // try {
  //   await run("verify:verify", {
  //     address: acpiTwo,
  //     constructorArguments: [],
  //   });
  // } catch (err) {
  //   console.error(err);
  // }
  // try {
  //   await run("verify:verify", {
  //     address: acpiThree,
  //     constructorArguments: [],
  //   });
  // } catch (err) {
  //   console.error(err);
  // }
  // try {
  //   await run("verify:verify", {
  //     address: acpiFour,
  //     constructorArguments: [],
  //   });
  // } catch (err) {
  //   console.error(err);
  // }

  console.log("ACPIMaster is deployed to: ", tx2.contractAddress);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
