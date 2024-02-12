import { ethers } from 'hardhat';
import { expect } from 'chai';
import {
  CloudaxAdvisoryVestingWallet,
  CloudaxAdvisoryVestingWallet__factory,
} from '../typechain-types';

describe('CloudaxTresauryVestingWallet', () => {
  let cloudaxAdvisoryVestingWallet: CloudaxAdvisoryVestingWallet;
  let deployer, john, paul;

  beforeEach(async () => {
    [deployer, john, paul] = await ethers.getSigners();

    // Deploy the contract
    const cloudaxAdvisoryVestingWalletFactory =
      (await ethers.getContractFactory(
        'CloudaxTresauryVestingWallet',
        deployer
      )) as CloudaxAdvisoryVestingWallet__factory;

      cloudaxAdvisoryVestingWallet = await cloudaxAdvisoryVestingWalletFactory.deploy(
      john.address,
      deployer.address
    );

    // Wait for the contract to be mined
    await cloudaxAdvisoryVestingWallet.deployed();
  });

  it('Should deploy the contract', async () => {
    expect(cloudaxAdvisoryVestingWallet.address).to.not.equal(0);
  });

  describe('getToken', function () {
    it('should return the address of the ERC20 token', async function () {
      const tokenAddress = await cloudaxAdvisoryVestingWallet.getToken();
      expect(tokenAddress).to.not.be.null;
      expect(tokenAddress).to.not.be.undefined;
      expect(tokenAddress).to.equal(deployer.address); // Assuming the token address is the same as the deployer's address
    });
  });

  describe('setBeneficiaryAddress', function () {
    it('should set the beneficiary address', async function () {
      const newBeneficiary = paul.address;
      await cloudaxAdvisoryVestingWallet.setBeneficiaryAddress(newBeneficiary);
      const beneficiaryAddress = await cloudaxAdvisoryVestingWallet.getBeneficiaryAddress();
      expect(beneficiaryAddress).to.equal(newBeneficiary);
    });
  });

  describe('initialize', function () {
    it('should initialize the vesting schedule', async function () {
      await cloudaxAdvisoryVestingWallet.initialize(john.address);
      const beneficiaryAddress = await cloudaxAdvisoryVestingWallet.getBeneficiaryAddress();
      expect(beneficiaryAddress).to.equal(john.address);
    });
  });

  describe('pause and unpause', function () {
    it('should pause and unpause the vesting release process', async function () {
      await cloudaxAdvisoryVestingWallet.pause();
      expect(await cloudaxAdvisoryVestingWallet.paused()).to.be.true;

      await cloudaxAdvisoryVestingWallet.unpause();
      expect(await cloudaxAdvisoryVestingWallet.paused()).to.be.false;
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
      await cloudaxAdvisoryVestingWallet._createVestingSchedule(amount);

      const vestingSchedule = await cloudaxAdvisoryVestingWallet.getVestingSchedule(0);
      expect(vestingSchedule.totalAmount).to.equal(amount);
    });
  });

  describe('getReleasableAmount', function () {
    it('should return the releasable amount', async function () {
      const currentTime = await cloudaxAdvisoryVestingWallet.getCurrentTime();
      const releasableAmount = await cloudaxAdvisoryVestingWallet.getReleasableAmount();
      expect(releasableAmount).to.not.be.null;
    });
  });

  describe('release', function () {
    it('should release the releasable amount when not paused and not reentrant', async function () {
      await cloudaxAdvisoryVestingWallet.release();
      // Add assertions based on the expected behavior after a release
    });
  });

  describe('withdraw', function () {
    it('should allow the owner to withdraw tokens when paused', async function () {
      await cloudaxAdvisoryVestingWallet.pause();
      const withdrawAmount = ethers.utils.parseEther('100'); // Replace with the desired amount
      await cloudaxAdvisoryVestingWallet.withdraw(withdrawAmount);

      const withdrawableAmount = await cloudaxAdvisoryVestingWallet.getWithdrawableAmount();
      expect(withdrawableAmount).to.equal(withdrawAmount);
    });

    it('should only allow the owner to withdraw tokens', async function () {
      const nonOwner = john.connect(paul);
      await expect(nonOwner.withdraw(ethers.utils.parseEther('100'))).to.be.revertedWith('Ownable: caller is not the owner');
    });

    it('should revert if the withdraw amount exceeds the balance', async function () {
      const withdrawAmount = ethers.utils.parseEther('10000'); // Assuming a large withdrawal amount
      await expect(cloudaxAdvisoryVestingWallet.withdraw(withdrawAmount)).to.be.revertedWith('CloudrVesting: withdraw amount exceeds balance');
    });
  });
  
});
