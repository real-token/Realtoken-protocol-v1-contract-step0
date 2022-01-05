import { web3 } from "hardhat";

async function main() {
  const accounts = await web3.eth.getAccounts();

  const tx = await web3.eth.sendTransaction({
    from: accounts[0],
    to: accounts[0],
  });

  const nonce = await web3.eth.getTransactionCount(accounts[0]);

  console.log("Nonce increased !");
  console.log("TX Hash : " + tx.transactionHash);
  console.log("Current nonce : " + nonce);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
