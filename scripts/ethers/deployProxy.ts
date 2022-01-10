import { ethers, upgrades, run, name, symbol } from "hardhat";

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
  const { TOKEN_ADMIN_PUBLIC } = process.env;
  if (!TOKEN_ADMIN_PUBLIC)
    return console.log(
      "Must have TOKEN_ADMIN_PUBLIC env set, please refer to readme"
    );

  // Deploying
  const regFactory = await ethers.getContractFactory("REG");
  const instance = await upgrades.deployProxy(regFactory, [
    name,
    symbol,
    TOKEN_ADMIN_PUBLIC,
  ]);
  await instance.deployed();

  await minuteSleep();

  try {
    await run("verify:verify", {
      address: instance.address,
      constructorArguments: [],
    });
  } catch (err) {
    console.error(err);
  }

  console.log("Contract has been deployed!");
  console.log("REG is deployed to: ", instance.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
