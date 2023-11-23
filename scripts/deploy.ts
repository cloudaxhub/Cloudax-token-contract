import { ethers } from "hardhat";
import { Contract, ContractFactory } from 'ethers';

async function main() {
  

  const cloudax = await ethers.deployContract("Cloudax");
  await cloudax.waitForDeployment();
  // address=0xf6a1Fd3d603e76A57c0aFBD7eA4C61cD561cAbe4
  // const CloudaxContractName: string = 'Cloudax';
  // const cloudaxFactory: ContractFactory = await ethers.getContractFactory(
  //   CloudaxContractName
  // );
  // const cloudax: Contract = await cloudaxFactory.deploy();
  // await cloudax.deployed();

  console.log(
    `cloudax deployed to ${cloudax}`
  );
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
