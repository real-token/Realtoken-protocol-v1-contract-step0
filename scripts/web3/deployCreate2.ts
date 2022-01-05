import { ethers, web3, network } from "hardhat";

async function main() {
  const createDeployerFactory = await ethers.getContractFactory(
    "Create2Deployer"
  );

  const web3ChainId = await web3.eth.getChainId();

  if (network.config.chainId !== web3ChainId) {
    return console.log("WEB3 Network doesn't match --network flag");
  }

  const account = await web3.eth.getAccounts();

  const { data } = createDeployerFactory.getDeployTransaction();

  if (!data) return console.log("CREATEDEPLOYER codebyte is undefined");

  const tx = await web3.eth.sendTransaction({
    from: account[0],
    data: data.toString(),
  });

  console.log("Deployer is deployed!");

  console.log(tx.contractAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
