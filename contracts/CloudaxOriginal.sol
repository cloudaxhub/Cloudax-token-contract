// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract CloudaxOrignal is ERC20, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    mapping(address => bool) public _isBlacklisted;
    address public presaleAddress;

    uint256 private _totalSupply = 200000000 * (10**18);
    bool public isTradingEnabled = false;

    event Blacklisted(address account, bool status);

    constructor() ERC20("Cloudax", "CLDX") {
        _mint(msg.sender, _totalSupply);
    }

    receive() external payable {}

    /* Functions to enable withdrawal of Ether and tokens */

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "can't transfer from zero address");
        require(to != address(0), "can't transfer to a zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "An address is blacklisted");
        if (from != owner() && from != presaleAddress) {
            require(isTradingEnabled, "Trading is not enabled yet");
        }
        super._transfer(from, to, amount);
    }

     function sendTokens(address to, uint256 amount) external {
        _transfer(msg.sender, to, amount);
    }

    function receiveTokens(address from, uint256 amount) external {
        _transfer(from, msg.sender, amount);
    }

    function setBlacklisted(address account, bool status) external onlyOwner {
        _isBlacklisted[account] = status;
        emit Blacklisted(account, status);
    }

    function setupPresaleAddress(address _presaleAddress) external onlyOwner {
        presaleAddress = _presaleAddress;
    }

    function setTradingEnabled(bool _status) external onlyOwner {
        isTradingEnabled = _status;
    }

    function withdrawEther(address recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Can't be a zero address");

        uint256 balance = address(this).balance;

        require(balance >= amount, "CLDX: Insufficient balance");
        (bool success, ) = payable(recipient).call{ value: amount }("");
        if (!success) {
            revert("CLDX: Transfer failed");
        }
    }

    function withdrawTokens(
        address tokenAddress,
        address recipient,
        uint256 amount
    ) external onlyOwner {
        require(recipient != address(0), "Can't be the zero address");
        ERC20 token = ERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        if (amount > balance) {
            amount = balance;
        }
        token.safeTransfer(recipient, amount);
    }
}