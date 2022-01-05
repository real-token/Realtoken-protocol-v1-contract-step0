// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import {
  ethers,
  name,
  symbol,
  deployerAddress,
  web3,
  artifacts,
} from "hardhat";

import inquirer from "inquirer";

async function main() {
  const [TOKEN_ADMIN, ACPI_MODERATOR] = await ethers.getSigners();

  if (!deployerAddress)
    return console.log("Deployer Address is undefined please set your .env");

  const deployer = await ethers.getContractAt(
    "Create2Deployer",
    deployerAddress
  );

  const web3Contract = new web3.eth.Contract(
    artifacts.readArtifactSync("Create2Deployer").abi,
    deployerAddress
  );

  const regFactory = await ethers.getContractFactory("REG");

  const acpiMasterFactory = await ethers.getContractFactory("ACPIMaster");

  const { data: regData } = regFactory.getDeployTransaction(
    name,
    symbol,
    TOKEN_ADMIN.address
  );

  let salt: string | undefined;

  try {
    const answer = await inquirer.prompt({
      type: "input",
      name: "salt",
      message: "Salt used to generate deployment address",
    });

    if (!answer.salt) return console.log("User aborted deployment");

    salt = answer.salt;
  } catch (reason) {
    console.log(reason);
  }

  if (!salt) return console.log("Invalid salt");
  if (!regData) return console.log("REG codebyte is undefined");

  const regAddress = await deployer.computeAddress(
    ethers.utils.formatBytes32String(salt),
    ethers.utils.keccak256(regData)
  );

  console.log("REG will be deployed at " + regAddress);

  try {
    const { go } = await inquirer.prompt({
      type: "confirm",
      name: "go",
      message: "Do you want to continue?",
    });

    if (!go) return console.log("User aborted deployment");
  } catch (reason) {
    console.log(reason);
  }

  const tx1 = await web3Contract.methods
    .deploy(0, ethers.utils.formatBytes32String(salt), regData)
    .send({ from: TOKEN_ADMIN.address });

  console.log("REG Deployment tx : ", tx1.transactionHash);

  const { data: acpiData } = acpiMasterFactory.getDeployTransaction(
    regAddress,
    TOKEN_ADMIN.address,
    ACPI_MODERATOR.address
  );

  if (!acpiData) return console.log("ACPIMaster codebyte is undefined");

  const acpiAddress = await deployer.computeAddress(
    ethers.utils.formatBytes32String(salt),
    ethers.utils.keccak256(acpiData)
  );

  console.log("ACPI will be deployed at " + acpiAddress);

  try {
    const { go } = await inquirer.prompt({
      type: "confirm",
      name: "go",
      message: "Do you want to continue?",
    });

    if (!go) return console.log("User aborted deployment");
  } catch (reason) {
    console.log(reason);
  }

  const tx2 = await web3Contract.methods
    .deploy(0, ethers.utils.formatBytes32String(salt), acpiData)
    .send({ from: TOKEN_ADMIN.address });
  console.log("ACPI Deployment tx : ", tx2.transactionHash);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
