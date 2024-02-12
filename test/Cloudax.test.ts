import { ethers } from 'hardhat';
import { expect } from 'chai';
import {
  Cloudax,
  Cloudax__factory,
} from '../typechain-types';

describe('Cloudax Token Contract', () => {
  let cloudax: Cloudax;
  let owner, user1, user2;

  beforeEach(async () => {
    [owner, user1, user2] = await ethers.getSigners();

    // Deploy the Cloudax contract
    const cloudaxFactory = (await ethers.getContractFactory(
      'Cloudax',
      owner
    )) as Cloudax__factory;

    cloudax = await cloudaxFactory.deploy(owner.address);

    // Wait for the contract to be mined
    await cloudax.deployed();
  });

  describe('Token Transactions', function () {
    it('Should deploy the contract with the correct total supply', async () => {
      const totalSupply = await cloudax.totalSupply();
      expect(totalSupply).to.equal(200000000 * (10**18));
    });

    it('Should allow users to transfer tokens', async () => {
      const initialBalanceOwner = await cloudax.balanceOf(owner.address);
      const transferAmount = 100;

      // Transfer tokens from owner to user1
      await cloudax.connect(owner).sendTokens(user1.address, transferAmount);

      const finalBalanceOwner = await cloudax.balanceOf(owner.address);
      const finalBalanceUser1 = await cloudax.balanceOf(user1.address);

      expect(finalBalanceOwner).to.equal(initialBalanceOwner - transferAmount);
      expect(finalBalanceUser1).to.equal(transferAmount);
    });
  });

  describe('Blacklisting', function () {
    it('Should allow the owner to blacklist and unblacklist addresses', async () => {
      // Blacklist user1
      await cloudax.connect(owner).setBlacklisted(user1.address, true);

      // Check if user1 is blacklisted
      const isUser1Blacklisted = await cloudax._isBlacklisted(user1.address);
      expect(isUser1Blacklisted).to.be.true;

      // Unblacklist user1
      await cloudax.connect(owner).setBlacklisted(user1.address, false);

      // Check if user1 is unblacklisted
      const isUser1Unblacklisted = await cloudax._isBlacklisted(user1.address);
      expect(isUser1Unblacklisted).to.be.false;
    });
  });

  describe('Trading Control', function () {
    it('Should allow the owner to enable and disable trading', async () => {
      // Disable trading
      await cloudax.connect(owner).setTradingEnabled(false);

      // Attempt a token transfer when trading is disabled
      await expect(cloudax.connect(user1).sendTokens(user2.address, 100))
        .to.be.revertedWith('Trading is not enabled yet');

      // Enable trading
      await cloudax.connect(owner).setTradingEnabled(true);

      // Attempt a token transfer when trading is enabled
      await cloudax.connect(user1).sendTokens(user2.address, 100);
      const balanceUser2 = await cloudax.balanceOf(user2.address);
      expect(balanceUser2).to.equal(100);
    });
  });

  describe('Presale Integration', function () {
    it('Should allow the owner to set the presale address', async () => {
      const newPresaleAddress = user1.address;

      // Set the presale address
      await cloudax.connect(owner).setupPresaleAddress(newPresaleAddress);

      // Check if the presale address is set correctly
      const presaleAddress = await cloudax.presaleAddress();
      expect(presaleAddress).to.equal(newPresaleAddress);
    });
  });

  describe('Withdrawal Functions', function () {
    it('Should allow the owner to withdraw Ether', async () => {
      const initialBalanceOwner = await ethers.provider.getBalance(owner.address);
      const withdrawalAmount = ethers.utils.parseEther('1.0');

      // Withdraw Ether to owner
      await cloudax.connect(owner).withdrawEther(owner.address, withdrawalAmount);

      const finalBalanceOwner = await ethers.provider.getBalance(owner.address);
      expect(finalBalanceOwner).to.equal(initialBalanceOwner.add(withdrawalAmount));
    });

    it('Should allow the owner to withdraw ERC-20 tokens', async () => {
      // Mint additional tokens for testing
      await cloudax.connect(owner).mint(owner.address, 1000);

      const initialBalanceOwner = await cloudax.balanceOf(owner.address);
      const withdrawalAmount = 500;

      // Withdraw Cloudax tokens to owner
      await cloudax.connect(owner).withdrawTokens(cloudax.address, owner.address, withdrawalAmount);

      const finalBalanceOwner = await cloudax.balanceOf(owner.address);
      expect(finalBalanceOwner).to.equal(initialBalanceOwner + withdrawalAmount);
    });
  });
});
