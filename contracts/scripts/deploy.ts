import { ethers } from "hardhat";

async function main() {
  const SpotBase = await ethers.getContractFactory("SpotBase");
  const contract = await SpotBase.deploy();
  await contract.deploymentTransaction()?.wait();

  console.log("SpotBase deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
