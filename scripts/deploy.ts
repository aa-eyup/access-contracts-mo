import { ethers } from "hardhat";

async function main() {
  const contractName = '';
  const Contract = await ethers.getContractFactory(contractName);
  // pass in constructor arguments
  const contract = await Contract.deploy();

  await contract.deployed();

  console.log(`deployed to ${contract.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
