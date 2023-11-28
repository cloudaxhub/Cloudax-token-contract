import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";

async function main() {
  // const cloudax = await ethers.deployContract("Cloudax", []);
  // await cloudax.waitForDeployment();

  // Deploy CloudaxTresuary  Contract
  const cloudaxTresuary = await ethers.deployContract(
    "CloudaxTresauryVestingWallet",
    ["0x815a44a4dfd4f149bb9e64b16db99f79484e3bce"]
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
