import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";

async function main() {

  // Deploy CloudaxTresuary  Contract
  const cloudaxTresuary = await ethers.deployContract(
    "CloudaxTresauryVestingWallet",
    ["0x675DE4CEc6c8123e1C7D6D801FE5d0C05f815B9a"]
  );
  await cloudaxTresuary.waitForDeployment();

  console.log(`cloudaxTresuary deployed to ${cloudaxTresuary.getAddress()}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
