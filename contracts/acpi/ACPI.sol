//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IACPIMaster.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @dev Abstract contract of the ACPI standard
 */

abstract contract ACPI {
    using SafeERC20 for IERC20;

    IACPIMaster internal _acpiMaster;
    uint256[] internal _priceHistory;

    // User Address => User balance
    mapping(address => uint256) internal _pendingWins;

    uint256 internal _totalWins;

    uint16 internal _currentRound;
    uint16 internal _totalRound;
    uint256 internal _roundTime;

    uint256 internal _acpiPrice;

    uint8 internal _acpiNumber;

    /**
     * @dev Setup Abstract contract must be called only in the child contract
     */
    constructor(address acpiMaster, uint8 acpiNumber) {
        _acpiMaster = IACPIMaster(acpiMaster);
        _acpiNumber = acpiNumber;
        _roundTime = 60 * 60;
        _totalRound = 336;
    }

    modifier onlyCurrentACPI() {
        require(
            _acpiMaster.getACPI() == _acpiNumber,
            "Only Current ACPI Method"
        );
        _;
    }

    modifier onlyACPIMaster() {
        require(
            _acpiMaster.hasRole(_acpiMaster.ACPI_MASTER(), msg.sender),
            "Only ACPI Master Method"
        );
        _;
    }

    modifier onlyModerator() {
        require(
            _acpiMaster.hasRole(_acpiMaster.ACPI_MODERATOR(), msg.sender),
            "Only ACPI Moderator Method"
        );
        _;
    }

    /**
     * @dev Returns the current round.
     */
    function currentRound() external view virtual returns (uint16) {
        return _currentRound;
    }

    /**
     * @dev Returns the amount of rounds per ACPI.
     */
    function totalRound() external view virtual returns (uint16) {
        return _totalRound;
    }

    /**
     * @dev Returns the time between two consecutive round in seconds
     */
    function roundTime() external view virtual returns (uint256) {
        return _roundTime;
    }

    /**
     * @dev Returns the price of the current ACPI
     */
    function acpiPrice() external view virtual returns (uint256) {
        return _acpiPrice;
    }

    /**
     * @dev Returns the pendingWins of {account}
     * pendingWins can be withdrawed at the end of all APCIs
     */
    function pendingWins(address account)
        external
        view
        virtual
        returns (uint256)
    {
        return _pendingWins[account];
    }

    /**
     * @dev Returns the totalWins of ACPI
     */
    function totalWins()
        external
        view
        virtual
        returns (uint256)
    {
        return _totalWins;
    }

   function totalReturns()
        external
        view
        virtual
        returns (uint256)
    {}


    /**
     * @dev Set totalRound value
     */
    function setTotalRound(uint16 newValue)
        external
        virtual
        onlyModerator
        returns (bool)
    {
        _totalRound = newValue;
        return true;
    }

    /**
     * @dev Set time between two consecutive round in seconds
     */
    function setRoundTime(uint256 newValue)
        external
        virtual
        onlyModerator
        returns (bool)
    {
        _roundTime = newValue;
        return true;
    }

    function bid(uint16 targetRound) external payable virtual returns (bool);

    /**
     * @dev Start round of ACPI ending the last one.
     */
    function startRound() external virtual returns (bool);

    /**
     * @dev Set the ACPI price when all the rounds have been done
     */
    function setAcpiPrice() internal virtual {
        if (_priceHistory.length == 0) return;
        uint256 sum = 0;
        for (uint256 i = 0; i < _priceHistory.length; i++) {
            sum += _priceHistory[i] / _priceHistory.length;
        }
        _acpiPrice = sum;
    }

    /**
     * @dev Set target user wins to 0 {onlyACPIMaster}
     * note called after a claimTokens from the parent contract
     */
    function resetAccount(address account)
        external
        virtual
        onlyACPIMaster
        returns (bool)
    {
        _pendingWins[account] = 0;
        return true;
    }

    /**
     * @dev Emitted when a user win a round of any ACPI
     * `amount` is the amount of REG Token awarded
     */
    event RoundWin(uint256 amount);

    /**
     * @dev Emitted when a user bid
     */
    event Bid(address user, uint256 amount);

    /**
     * @dev Withdraw native currency {onlyACPIMaster}
     */
    function withdraw(address payable recipient, uint256 amount)
        external
        virtual
        onlyACPIMaster
        returns (bool)
    {
        require(recipient != address(0), "Can't burn token");

        recipient.transfer(amount);
        return true;
    }

    function pendingReturns(address account)
        external
        view
        virtual
        returns (uint256)
    {}

    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        virtual
        onlyACPIMaster
        returns (bool)
    {
        IERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);
        return true;
    }
}
