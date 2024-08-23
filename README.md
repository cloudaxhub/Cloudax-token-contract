# Cloudax Token Contract(CLDX)

## Overview

The Cloudax Token (CLDX) is a custom ERC20 token built on the Arbitrum network, designed with advanced functionalities for managing a token sale, vesting schedules, and blacklisting addresses. This document provides an overview of the tokenomics, features, use cases, and key components of the CLDX smart contract.

## Tokenomics

- **Total Supply**: 200,000,000 CLDX
- **Type**: Arbitrum

### Token Allocation

1. **Seed Sale**: 5% (10,000,000 CLDX)
   - **Vesting Schedule**: 0% at TGE, 30 Days Cliff, 10% vested monthly for 10 months.
  
2. **Public IDO**: 20% (40,000,000 CLDX)
   - **Vesting Schedule**: 30% at TGE (12M CLDX), 70% Vested in ECO Tokens.
  
3. **Ecosystem Growth**: 10% (20,000,000 CLDX)
   - **Vesting Schedule**: 5% at TGE (1M CLDX), 3 Months Cliff, Vested monthly over 5 years.
  
4. **Farming & Staking**: 10% (20,000,000 CLDX)
   - **Vesting Schedule**: 3% at TGE (600k CLDX), Vested monthly over 2 years.
  
5. **Marketing**: 10% (20,000,000 CLDX)
   - **Vesting Schedule**: 5% at TGE (1M CLDX), Vested monthly.
  
6. **Treasury**: 20% (40,000,000 CLDX)
   - **Vesting Schedule**: 0% at TGE, Vested Based on decision from DAO.
  
7. **Liquidity**: 10% (20,000,000 CLDX)
   - **Vesting Schedule**: 30% at TGE (6M CLDX), 4 months vesting to regulate price.
  
8. **Team**: 10% (20,000,000 CLDX)
   - **Vesting Schedule**: 0% at TGE, 6 Months Cliff, Vested monthly over 4 years.
  
9. **Advisor / Partner**: 5% (10,000,000 CLDX)
   - **Vesting Schedule**: 0% at TGE, 6 Months Cliff, Vested monthly over 4 years.

## Contract Features

- **Blacklisting**: Addresses can be blacklisted to prevent them from performing certain transactions.
- **Presale Management**: A designated presale address is authorized to manage token transfers during the presale period.
- **Trading Control**: The contract owner can enable or disable trading of the tokens.
- **Fund Withdrawal**: The contract includes secure methods for withdrawing Ether and tokens.

## Use Cases

- **Initial Token Distribution**: Efficient distribution of tokens after launch.
- **Token Sales & Vesting**: Managed sales with specific vesting schedules to ensure fair distribution.
- **Fraud Prevention**: Blacklisting malicious addresses to prevent fraudulent activities.
- **Secure Fund Management**: Safe and secure withdrawal of funds from the contract.

## Roles & Authorizations

- **Owner**: Full control over the contract, including managing blacklists, enabling trading, and withdrawing funds.
- **Presale Address**: An authorized address that can manage presale transactions.
- **Blacklisted Addresses**: Addresses that are restricted from performing certain transactions due to being blacklisted.

## Contract Components

- **Contract**: The main contract extends ERC20 and Ownable to implement the token and ownership functionalities.
- **Key Functions**:
  - `setupTresuaryAddress`: Sets the address of the CloudaxTresuary contract.
  - `transfer`: Overrides the ERC20 transfer function to include blacklist and trading checks.
  - `transferFrom`: Overrides the ERC20 transferFrom function to include blacklist and trading checks.
  - `setBlacklisted`: Allows the owner to add or remove addresses from the blacklist.
  - `setupPresaleAddress`: Sets the address allowed to participate in presales.
  - `setTradingEnabled`: Toggles the ability to trade tokens.
  - `withdrawTokens`: Withdraws tokens from the contract to the specified recipient.

## State Variables

- **`tresuary`**: The address of the CloudaxTresuary contract.
- **`_isBlacklisted`**: A mapping to check if an address is blacklisted.
- **`presaleAddress`**: The address authorized to manage presales.
- **`_totalSupply`**: The total supply of tokens minted upon deployment.
- **`isTradingEnabled`**: A boolean indicating if trading is enabled.

---


```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```
