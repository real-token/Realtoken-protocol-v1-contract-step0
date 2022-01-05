import { web3 } from "hardhat";

async function main() {
  const accounts = await web3.eth.getAccounts();

  const nonce = await web3.eth.getTransactionCount(accounts[0]);

  console.log("Next transaction nonce : " + nonce);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
