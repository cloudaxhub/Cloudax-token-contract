import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";

async function main() {

  // Deploy Cloudax Contract
  const cloudax = await ethers.deployContract(
    "CloudaxTest",
  );
  await cloudax.waitForDeployment();

  console.log(`cloudaxTest deployed to ${cloudax.getAddress()}`);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
