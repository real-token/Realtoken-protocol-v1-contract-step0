// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, run } from "hardhat";

import deployProxy from "./deployProxy";
import deployMaster from "./deployMaster";
import deployAcpiOne from "./deployACPIOne";
import deployAcpiTwo from "./deployACPITwo";
import deployAcpiThree from "./deployACPIThree";
import deployAcpiFour from "./deployACPIFour";

async function main() {
  const proxyREG = await deployProxy();

  if (!proxyREG)
    throw new Error("Something went wrong with Proxy, aborting...");

  const acpiMaster = await deployMaster(proxyREG);

  if (!acpiMaster)
    throw new Error("Something went wrong with ACPIMaster, aborting...");

  await deployAcpiOne(acpiMaster);
  await deployAcpiTwo(acpiMaster);
  await deployAcpiThree(acpiMaster);
  await deployAcpiFour(acpiMaster);

  console.log("Deployment done");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
