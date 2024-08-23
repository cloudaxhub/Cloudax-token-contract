// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ICloudaxTresuary
 * @dev Interface for the CloudaxTresuary contract.
 */
interface ICloudaxTresuary {

    // Custom errors
    error InvalidTokenAddress();
    error InvalidOracleAddress();
    error InsufficientTokens();
    error NotAnApprovedEcoWallet();
    error AlreadyApproved();
    error ZeroAddress();
    error InsufficientAmount();
    error UnauthorizedAddress();
    error ExceededBurnAllocation();
    error InvalidBurnPercentage();

    // Events
    event OracleSet(address oldOracleAddress, address newOracleAddress);
    event TokenSwap(
        address owner,
        address recipent,
        address admin,
        uint256 amount,
        string assesType
    );
    event EcoWalletAdded(address ecoWallet, address currentContractOwner);
    event EcoWalletRemoved(address ecoWallet, address currentContractOwner);
    event TokenBurnt(
        address owner,
        address admin,
        address burnAddress,
        uint256 amount
    );
    event SwapInitiated(address indexed sender, uint256 amount);

    // Functions
    function getToken() external view returns (address);

    function setOracleAddress(address _oracle) external;

    function setBurnPercentage(uint8 _burnPercentage) external;

    function initiateSwap(uint256 amount, address recipent) external;

    function swapCldxToEco(uint256 amount, address recipent) external;

    function swapEcoToCldx(uint256 amount, address recipent) external;

    function aproveEcoWallet(address wallet) external;

    function removeEcoWallet(address wallet) external;

    function getSwapOperation(address sender) external view returns (SwapStatus, uint256);

    function burn(uint256 amount) external;

    // Enums
    enum SwapStatus { Pending, Completed }
}
