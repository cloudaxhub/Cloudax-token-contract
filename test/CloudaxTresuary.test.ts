import { ethers } from 'hardhat';
import { expect } from "chai";
import {
  CloudaxTresauryVestingWallet,
  CloudaxTresauryVestingWallet__factory,
} from "../typechain-types";

describe("cloudaxTresauryVestingWallet", () => {
  let cloudaxTresauryVestingWallet: CloudaxTresauryVestingWallet;

  beforeEach(async () => {
    const [deployer, john, paul] = await ethers.getSigners();

    // Deploy the contract
    const cloudaxTresauryVestingWalletFactory =
      (await ethers.getContractFactory(
        "CloudaxTresauryVestingWallet",
        deployer
      )) as CloudaxTresauryVestingWallet__factory;

    cloudaxTresauryVestingWallet = await cloudaxTresauryVestingWalletFactory
      .deploy(paul,deployer);

    // Wait for the contract to be mined
    await cloudaxTresauryVestingWallet.waitForDeployment();
  });

  // it("Should deploy the contract", async () => {
  //   expect(cloudaxTresauryVestingWallet.getAddress()).to.not.equal(0);
  // });
  describe("getToken", function () {
    it("should return the address of the ERC20 token", async function () {
      const tokenAddress = await cloudaxTresauryVestingWallet.getToken();
      expect(tokenAddress).to.not.be.null;
      expect(tokenAddress).to.not.be.undefined;
      expect(tokenAddress).to.equal(owner.address); // Assuming the token address is the same as the owner's address
    });
  });

  describe("setBeneficiaryAddress", function () {
    it("should set the beneficiary address", async function () {
      await cloudaxTresauryVestingWallet.connect(owner).setBeneficiaryAddress(addr1.address);
      expect(await cloudaxTresauryVestingWallet.getBeneficiaryAddress()).to.equal(addr1.address);
    });

    it("should revert if called by a non-owner", async function () {
      await expect(cloudaxTresauryVestingWallet.connect(addr1).setBeneficiaryAddress(addr2.address)).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });

  describe("initialize", function () {
    it("should initialize the vesting schedule", async function () {
      // Assuming the token contract is already deployed and the address is known
      const tokenAddress = /* the address of the deployed token contract */;
      const vestingDuration =  12; //  12 months for example
      const vestingAllocation = ethers.utils.parseUnits("1000",  18); //  1000 tokens for example
      const cliffPeriod =  1; //  1 month cliff period for example

      await cloudaxTresauryVestingWallet.connect(owner).initialize(vestingDuration, addr1.address, vestingAllocation, cliffPeriod);
      const beneficiaryAddress = await cloudaxTresauryVestingWallet.getBeneficiaryAddress();
      expect(beneficiaryAddress).to.equal(addr1.address);
      // Additional checks for the vesting schedule initialization can be added here
    });

    it("should revert if called by a non-owner", async function () {
      const tokenAddress = /* the address of the deployed token contract */;
      const vestingDuration =  12; //  12 months for example
      const vestingAllocation = ethers.utils.parseUnits("1000",  18); //  1000 tokens for example
      const cliffPeriod =  1; //  1 month cliff period for example

      await expect(cloudaxTresauryVestingWallet.connect(addr1).initialize(vestingDuration, addr1.address, vestingAllocation, cliffPeriod)).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });
});
