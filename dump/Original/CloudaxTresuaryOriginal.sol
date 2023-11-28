// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

struct VestingSchedule {
    // total amount of tokens to be released at the end of the vesting
    uint256 totalAmount;
    // start time of the vesting period
    uint256 startTime;
    // duration of the vesting period in seconds
    uint256 duration;
}

contract CloudaxTresauryVestingWallet is
    Ownable,
    Initializable,
    ReentrancyGuard,
    Pausable
{
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    // using SafeERC20 for IERC20;

    /**
     * @notice Reased event
     * @param beneficiaryAddress address to receive the released tokens.
     * @param amount released amount of tokens
     */
    event Released(address beneficiaryAddress, uint256 amount);
    event BeneficiarySet(
        address oldBeneficiaryAddress,
        address newBeneficiaryAddress
    );
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
        address recipent,
        address admin,
        address burnAddress,
        uint256 amount
    );
    event VestingInitialized(
        uint256 durationInMonths,
        address beneficiary,
        address projectToken,
        uint256 vestingAllocation
    );

    // Originally 30 days, changed to 1 minute for test purposes
    uint256 private constant _RELEASE_TIME_UNIT = 30 days;
    // Originally 12 * 30 days, changed to 1 minute for test purposes
    uint256 private constant _CLIFF_PEROID = 12 * 30 days;
    ERC20 private immutable _token;
    uint256 public ecoWallets;

    uint256 private _startTime;
    address private _beneficiaryAddress;
    mapping(uint256 => VestingSchedule) private _vestingSchedule;
    uint256 private _vestingScheduleCount;
    uint256 private _lastReleasedTime;
    uint256 private _releasedAmount;
    mapping(uint256 => uint256) private _previousTotalVestingAmount;
    mapping(address => uint256) public _swappedForEco;
    mapping(address => uint256) public _swappedForCldx;
    mapping(address => uint256) public ecoApprovalWallet;

    /**
     * @dev Creates a treasury vesting contract.
     * @param token_ address of the BEP20 token contract
     */
    constructor(address token_) {
        require(token_ != address(0), "invalid token address");
        _token = ERC20(token_);
        _pause();
    }

    /**
     * @dev Returns the address of the BEP20 token managed by the vesting contract.
     */
    function getToken() external view returns (address) {
        return address(_token);
    }

    /**
     * @notice Set the beneficiary addresses of vesting schedule.
     * @param beneficiary_ address of the beneficiary.
     */
    function setBeneficiaryAddress(address beneficiary_) external onlyOwner {
        _setBeneficiaryAddress(beneficiary_);
    }

    /**
     * @notice Set the beneficiary addresses of vesting schedule.
     * @param beneficiary_ address of the beneficiary.
     */
    function _setBeneficiaryAddress(address beneficiary_) internal {
        require(
            beneficiary_ != address(0),
            "CloudrVesting: invalid beneficiary address"
        );
        emit BeneficiarySet(_beneficiaryAddress, beneficiary_);
        _beneficiaryAddress = beneficiary_;
    }

    /**
     * @notice Get the beneficiary addresses of vesting schedule.
     * @return beneficiary address of the beneficiary.
     */
    function getBeneficiaryAddress() external view returns (address) {
        return _beneficiaryAddress;
    }

    /**
     * @notice Initialize vesting schedule with start time.
     * @notice start time of vesting schedule is automatically the time this method is called.
     * @param beneficiary_ address of the beneficiary.
     */
    function initialize(
        uint256 months,
        address beneficiary_,
        uint256 vestingAllocation
    ) external initializer onlyOwner {
        _startTime = block.timestamp.add(_CLIFF_PEROID);
        uint256 RELEASE_AMOUNT_UNIT = vestingAllocation.div(100);
        _setBeneficiaryAddress(beneficiary_);
        // _startTime = startTime_.add(_CLIFF_PEROID);

        // 12 months
        if (months == 12) {
            uint8[12] memory vestingSchedule = [
                8,
                8,
                8,
                8,
                8,
                8,
                8,
                8,
                8,
                8,
                10,
                10
            ];

            for (uint256 i = 0; i < 12; i++) {
                _createVestingSchedule(
                    vestingSchedule[i] * RELEASE_AMOUNT_UNIT
                );
            }
        }

        // 24 months
        if (months == 24) {
            uint8[24] memory vestingSchedule = [
                4,
                4,
                4,
                4,
                4,
                4,
                4,
                4,
                4,
                4,
                4,
                4,
                4,
                4,
                4,
                4,
                4,
                4,
                4,
                4,
                5,
                5,
                5,
                5
            ];

            for (uint256 i = 0; i < 24; i++) {
                _createVestingSchedule(
                    vestingSchedule[i] * RELEASE_AMOUNT_UNIT
                );
            }
        }

        // 36 months
        if (months == 36) {
            uint8[36] memory vestingSchedule = [
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3,
                3
            ];

            for (uint256 i = 0; i < 36; i++) {
                _createVestingSchedule(
                    vestingSchedule[i] * RELEASE_AMOUNT_UNIT
                );
            }
        }

        // 48 months
        if (months == 48) {
            uint8[48] memory vestingSchedule = [
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                3,
                3,
                3,
                3
            ];

            for (uint256 i = 0; i < 48; i++) {
                _createVestingSchedule(
                    vestingSchedule[i] * RELEASE_AMOUNT_UNIT
                );
            }
        }

        // 60 months (5 years)
        if (months == 60) {
            uint8[60] memory vestingSchedule = [
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2
            ];

            for (uint256 i = 0; i < 60; i++) {
                _createVestingSchedule(
                    vestingSchedule[i] * RELEASE_AMOUNT_UNIT
                );
            }
        }

        // 72 months (6 years)
        if (months == 72) {
            uint8[72] memory vestingSchedule = [
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2,
                2
            ];

            for (uint256 i = 0; i < 72; i++) {
                _createVestingSchedule(
                    vestingSchedule[i] * RELEASE_AMOUNT_UNIT
                );
            }
        }

        // 7 years
        if (months == 84) {
            uint8[84] memory vestingSchedule = [
                2,
                1,
                1,
                1,
                1,
                1,
                2,
                1,
                1,
                1,
                1,
                1,
                2,
                1,
                1,
                1,
                1,
                1,
                2,
                1,
                1,
                1,
                1,
                1,
                2,
                1,
                1,
                1,
                1,
                1,
                2,
                1,
                1,
                1,
                1,
                1,
                2,
                1,
                1,
                1,
                1,
                1,
                2,
                1,
                1,
                1,
                1,
                1,
                2,
                1,
                1,
                1,
                1,
                1,
                2,
                1,
                1,
                1,
                1,
                1,
                2,
                1,
                1,
                1,
                1,
                1,
                2,
                1,
                1,
                1,
                1,
                1,
                2,
                1,
                1,
                1,
                1,
                1,
                2,
                1,
                1,
                1,
                1,
                3
            ];
            for (uint256 i = 0; i < 84; i++) {
                _createVestingSchedule(
                    vestingSchedule[i] * RELEASE_AMOUNT_UNIT
                );
            }
        }
        _unpause();
        emit VestingInitialized(
            months,
            beneficiary_,
            address(_token),
            vestingAllocation
        );
    }

    /**
     * @notice Pause the vesting release.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause the vesting release.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Creates a new vesting schedule for a beneficiary.
     * @param amount total amount of tokens to be released at the end of the vesting
     */
    function _createVestingSchedule(uint256 amount) internal {
        uint256 scheduleId = _vestingScheduleCount;
        _vestingSchedule[scheduleId].startTime =
            _startTime +
            scheduleId *
            _RELEASE_TIME_UNIT;
        _vestingSchedule[scheduleId].duration = _RELEASE_TIME_UNIT;
        _vestingSchedule[scheduleId].totalAmount = amount;
        uint256 nextScheduleId = scheduleId.add(1);
        _vestingScheduleCount = nextScheduleId;
        _previousTotalVestingAmount[
            nextScheduleId
        ] = _previousTotalVestingAmount[scheduleId].add(amount);
    }

    /**
     * @dev Computes the releasable amount of tokens for a vesting schedule.
     * @param currentTime current timestamp
     * @return releasable the current releasable amount
     * @return released the amount already released to the beneficiary
     * @return total the total amount of token for the beneficiary
     */
    function _computeReleasableAmount(uint256 currentTime)
        internal
        view
        returns (
            uint256 releasable,
            uint256 released,
            uint256 total
        )
    {
        require(
            currentTime >= _startTime,
            "CloudrVesting: no vesting is available now"
        );
        require(
            _vestingScheduleCount == 84,
            "CloudrVesting: vesting schedule is not set"
        );

        uint256 duration = currentTime.sub(_startTime);
        uint256 scheduleCount = duration.div(_RELEASE_TIME_UNIT);
        uint256 remainTime = duration.sub(_RELEASE_TIME_UNIT * scheduleCount);
        uint256 releasableAmountTotal;

        if (scheduleCount > _vestingScheduleCount) {
            releasableAmountTotal = _previousTotalVestingAmount[
                _vestingScheduleCount
            ];
        } else {
            uint256 previousVestingTotal = _previousTotalVestingAmount[
                scheduleCount
            ];
            releasableAmountTotal = previousVestingTotal.add(
                _vestingSchedule[scheduleCount].totalAmount.mul(remainTime).div(
                    _RELEASE_TIME_UNIT
                )
            );
        }

        uint256 releasableAmount = releasableAmountTotal.sub(_releasedAmount);
        return (releasableAmount, _releasedAmount, releasableAmountTotal);
    }

    /**
     * @notice Returns the releasable amount of tokens.
     * @return _releasable the releasable amount
     */
    function getReleasableAmount() external view returns (uint256 _releasable) {
        uint256 currentTime = getCurrentTime();
        (_releasable, , ) = _computeReleasableAmount(currentTime);
    }

    /**
     * @notice Returns the token release info.
     * @return releasable the current releasable amount
     * @return released the amount already released to the beneficiary
     * @return total the total amount of token for the beneficiary
     */
    function getReleaseInfo()
        public
        view
        returns (
            uint256 releasable,
            uint256 released,
            uint256 total
        )
    {
        uint256 currentTime = getCurrentTime();
        (releasable, released, total) = _computeReleasableAmount(currentTime);
    }

    /**
     * @notice Release the releasable amount of tokens.
     * @return the success or failure
     */
    function _release(uint256 currentTime) internal returns (bool) {
        require(
            currentTime >= _startTime,
            "CloudrVesting: vesting schedule is not initialized"
        );
        (uint256 releaseAmount, , ) = _computeReleasableAmount(currentTime);
        _token.transfer(_beneficiaryAddress, releaseAmount);
        _releasedAmount = _releasedAmount.add(releaseAmount);
        emit Released(_beneficiaryAddress, releaseAmount);
        return true;
    }

    /**
     * @notice Release the releasable amount of tokens.
     * @return the success or failure
     */
    function release() external whenNotPaused nonReentrant returns (bool) {
        require(_release(getCurrentTime()), "CloudrVesting: release failed");
        return true;
    }

    // @title a function to allow swapping CLDX to ecoToken.
    // @dev @dev This function helps the oracle swap CLDX to ECO tokens.
    function swapCldxToEco(uint256 amount, address recipent)
        external
        nonReentrant
    {
        require(
            ecoApprovalWallet[msg.sender] != 0,
            "This wallet is not an approved EcoWallet"
        );
        require(amount != 0, "Amount must be greater than Zero");
        // burn CLDX by sending it to a zero address
        require(
            _token.balanceOf(address(this)) >= amount,
            "Not enough cldx in treasury"
        );

        _swappedForEco[recipent] += amount;
        emit TokenSwap(
            address(0x000000000000000000000000000000000000dEaD),
            recipent,
            msg.sender,
            amount,
            "CldxToEco"
        );
        emit TokenBurnt(
            address(this),
            recipent,
            msg.sender,
            address(0x000000000000000000000000000000000000dEaD),
            amount
        );
        _token.transfer(
            address(0x000000000000000000000000000000000000dEaD),
            amount
        );
    }

    // @title a function to allow swapping ecoToken to CLDX.
    // @dev This function helps the oracle swap ECO to CLDX tokens.
    function swapEcoToCldx(uint256 amount, address recipent)
        external
        nonReentrant
    {
        require(
            ecoApprovalWallet[msg.sender] != 0,
            "This wallet is not an approved EcoWallet"
        );
        require(recipent != address(0), "Must not be a zero address");
        require(amount != 0, "Amount must be greater than Zero");
        // burn CLDX by sending it to a zero address
        require(
            _token.balanceOf(address(this)) >= amount,
            "Not enough cldx in treasury"
        );
        _swappedForCldx[recipent] += amount;
        emit TokenSwap(
            address(this),
            recipent,
            msg.sender,
            amount,
            "EcoToCldx"
        );
        _token.transfer(recipent, amount);
    }

    function aproveEcoWallet(address wallet) external onlyOwner {
        require(
            ecoApprovalWallet[wallet] == 0,
            "This wallet is already an approved EcoWallet"
        );
        ecoWallets += 1;
        ecoApprovalWallet[wallet] = ecoWallets;
        emit EcoWalletAdded(wallet, msg.sender);
    }

    function removeEcoWallet(address wallet) external onlyOwner {
        require(
            ecoApprovalWallet[wallet] != 0,
            "This wallet is not an approved EcoWallet"
        );
        ecoApprovalWallet[wallet] = 0;
        emit EcoWalletRemoved(wallet, msg.sender);
    }

    /**
     * @notice Withdraw the specified amount if possible.
     * @param amount the amount to withdraw
     */
    function withdraw(uint256 amount)
        external
        nonReentrant
        onlyOwner
        whenPaused
    {
        require(
            getWithdrawableAmount() >= amount,
            "CloudrVesting: withdraw amount exceeds balance"
        );
        _token.transfer(owner(), amount);
    }

    /**
     * @dev Returns the amount of tokens that can be withdrawn by the owner.
     * @return the amount of tokens
     */
    function getWithdrawableAmount() public view returns (uint256) {
        return _token.balanceOf(address(this));
    }

    /**
     * @dev Returns the number of vesting schedules managed by this contract.
     * @return the number of vesting schedules
     */
    function getVestingSchedulesCount() external view returns (uint256) {
        return _vestingScheduleCount;
    }

    /**
     * @notice Returns the vesting schedule information for a given identifier.
     * @param scheduleId vesting schedule index: 0, 1, 2, ...
     * @return the vesting schedule structure information
     */
    function getVestingSchedule(uint256 scheduleId)
        external
        view
        returns (VestingSchedule memory)
    {
        return _vestingSchedule[scheduleId];
    }

    /**
     * @notice Returns the release start timestamp.
     * @return the block timestamp
     */
    function getStartTime() external view returns (uint256) {
        return _startTime;
    }

    /**
     * @notice Returns the daily releasable amount of tokens for the mining pool.
     * @param currentTime current timestamp
     * @return the amount of token
     */
    function getDailyReleasableAmount(uint256 currentTime)
        external
        view
        whenNotPaused
        returns (uint256)
    {
        require(
            currentTime >= _startTime,
            "CloudrVesting: no vesting is available now"
        );
        require(
            _vestingScheduleCount == 84,
            "CloudrVesting: vesting schedule is not set"
        );

        uint256 duration = currentTime.sub(_startTime);
        uint256 scheduleCount = duration.div(_RELEASE_TIME_UNIT);
        if (scheduleCount > _vestingScheduleCount) return 0;
        return _vestingSchedule[scheduleCount].totalAmount.div(30);
    }

    /**
     * @notice Returns the current timestamp.
     * @return the block timestamp
     */
    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }

    function getCliff() internal view virtual returns (uint256) {
        return _CLIFF_PEROID;
    }

    function burn(uint256 amount) public onlyOwner {
        // burn CLDX by sending it to a zero address
        require(amount != 0, "Amount must be greater than Zero");
        require(
            _token.balanceOf(address(this)) >= amount,
            "Not enough tokens in treasury"
        );
        _token.transfer(
            address(0x000000000000000000000000000000000000dEaD),
            amount
        );

        emit TokenBurnt(
            address(this),
            msg.sender,
            msg.sender,
            address(0x000000000000000000000000000000000000dEaD),
            amount
        );
    }
}
