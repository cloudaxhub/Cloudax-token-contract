import { ethers } from 'hardhat';
import { expect } from 'chai';
import {
  CloudaxFarmingStakingVestingWallet,
  CloudaxFarmingStakingVestingWallet__factory,
} from '../typechain-types';

describe('CloudaxTresauryVestingWallet', () => {
  let cloudaxFarmingStakingVestingWallet: CloudaxFarmingStakingVestingWallet;
  let deployer, john, paul;

  beforeEach(async () => {
    [deployer, john, paul] = await ethers.getSigners();

    // Deploy the contract
    const cloudaxMarketingVestingWalletFactory =
      (await ethers.getContractFactory(
        'CloudaxTeamVestingWallet',
        deployer
      )) as CloudaxFarmingStakingVestingWallet__factory;

      cloudaxFarmingStakingVestingWallet = await cloudaxMarketingVestingWalletFactory.deploy(
      john.address,
      deployer.address
    );

    // Wait for the contract to be mined
    await cloudaxFarmingStakingVestingWallet.deployed();
  });

  it('Should deploy the contract', async () => {
    expect(cloudaxFarmingStakingVestingWallet.address).to.not.equal(0);
  });

  describe('getToken', function () {
    it('should return the address of the ERC20 token', async function () {
      const tokenAddress = await cloudaxFarmingStakingVestingWallet.getToken();
      expect(tokenAddress).to.not.be.null;
      expect(tokenAddress).to.not.be.undefined;
      expect(tokenAddress).to.equal(deployer.address); // Assuming the token address is the same as the deployer's address
    });
  });

  describe('setBeneficiaryAddress', function () {
    it('should set the beneficiary address', async function () {
      const newBeneficiary = paul.address;
      await cloudaxFarmingStakingVestingWallet.setBeneficiaryAddress(newBeneficiary);
      const beneficiaryAddress = await cloudaxFarmingStakingVestingWallet.getBeneficiaryAddress();
      expect(beneficiaryAddress).to.equal(newBeneficiary);
    });
  });

  describe('initialize', function () {
    it('should initialize the vesting schedule', async function () {
      await cloudaxFarmingStakingVestingWallet.initialize(john.address);
      const beneficiaryAddress = await cloudaxFarmingStakingVestingWallet.getBeneficiaryAddress();
      expect(beneficiaryAddress).to.equal(john.address);
    });
  });

  describe('pause and unpause', function () {
    it('should pause and unpause the vesting release process', async function () {
      await cloudaxFarmingStakingVestingWallet.pause();
      expect(await cloudaxFarmingStakingVestingWallet.paused()).to.be.true;

      await cloudaxFarmingStakingVestingWallet.unpause();
      expect(await cloudaxFarmingStakingVestingWallet.paused()).to.be.false;
    });

    it('should only allow the owner to pause and unpause', async function () {
      const nonOwner = john.connect(paul);
      await expect(nonOwner.pause()).to.be.revertedWith('Ownable: caller is not the owner');
      await expect(nonOwner.unpause()).to.be.revertedWith('Ownable: caller is not the owner');
    });
  });

  describe('_createVestingSchedule', function () {
    it('should create a new vesting schedule', async function () {
      const amount = ethers.utils.parseEther('1000'); // Replace with the desired amount
      await cloudaxFarmingStakingVestingWallet._createVestingSchedule(amount);

      const vestingSchedule = await cloudaxFarmingStakingVestingWallet.getVestingSchedule(0);
      expect(vestingSchedule.totalAmount).to.equal(amount);
    });
  });

  describe('getReleasableAmount', function () {
    it('should return the releasable amount', async function () {
      const currentTime = await cloudaxFarmingStakingVestingWallet.getCurrentTime();
      const releasableAmount = await cloudaxFarmingStakingVestingWallet.getReleasableAmount();
      expect(releasableAmount).to.not.be.null;
    });
  });

  describe('release', function () {
    it('should release the releasable amount when not paused and not reentrant', async function () {
      await cloudaxFarmingStakingVestingWallet.release();
      // Add assertions based on the expected behavior after a release
    });
  });

  describe('withdraw', function () {
    it('should allow the owner to withdraw tokens when paused', async function () {
      await cloudaxFarmingStakingVestingWallet.pause();
      const withdrawAmount = ethers.utils.parseEther('100'); // Replace with the desired amount
      await cloudaxFarmingStakingVestingWallet.withdraw(withdrawAmount);

      const withdrawableAmount = await cloudaxFarmingStakingVestingWallet.getWithdrawableAmount();
      expect(withdrawableAmount).to.equal(withdrawAmount);
    });

    it('should only allow the owner to withdraw tokens', async function () {
      const nonOwner = john.connect(paul);
      await expect(nonOwner.withdraw(ethers.utils.parseEther('100'))).to.be.revertedWith('Ownable: caller is not the owner');
    });

    it('should revert if the withdraw amount exceeds the balance', async function () {
      const withdrawAmount = ethers.utils.parseEther('10000'); // Assuming a large withdrawal amount
      await expect(cloudaxFarmingStakingVestingWallet.withdraw(withdrawAmount)).to.be.revertedWith('CloudrVesting: withdraw amount exceeds balance');
    });
  });
  
});
