//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IRealT.sol";

/**
 * @dev Abstract contract of the ACPI standard by realt.co
 */

abstract contract ACPI {
    IRealT internal _realtERC20;
    uint256[] internal _priceHistory;

    // User Address => User balance
    mapping(address => uint256) internal _pendingWins;

    uint16 internal _currentRound;
    uint16 internal _totalRound;
    uint256 internal _roundTime;

    uint256 internal _acpiPrice;

    uint8 internal _acpiNumber;

    modifier onlyCurrentACPI() {
        require(
            _realtERC20.getACPI() == _acpiNumber,
            "Only Current ACPI Method"
        );
        _;
    }

    modifier onlyTokenContract() {
        require(
            _realtERC20.hasRole(_realtERC20.TOKEN_CONTRACT(), msg.sender),
            "Only Token Contract Method"
        );
        _;
    }

    modifier onlyModerator() {
        require(
            _realtERC20.hasRole(_realtERC20.ACPI_MODERATOR(), msg.sender),
            "Only ACPI Moderator Method"
        );
        _;
    }

    /**
     * @dev Setup Abstract contract must be called only in the child contract
     */
    function _setupAbstract(address realtERC20, uint8 acpiNumber)
        internal
        virtual
    {
        _realtERC20 = IRealT(realtERC20);
        _acpiNumber = acpiNumber;
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
    function pendingWins(address account) external view returns (uint256) {
        return _pendingWins[account];
    }

    /**
     * @dev Set totalRound value
     */
    function setTotalRound(uint16 newValue)
        external
        virtual
        onlyModerator
        returns (uint16)
    {
        return _totalRound = newValue;
    }

    /**
     * @dev Set time between two consecutive round in seconds
     */
    function setRoundTime(uint256 newValue)
        external
        virtual
        onlyModerator
        returns (uint256)
    {
        return _roundTime = newValue;
    }

    /**
     * @dev Start round of ACPI ending the last one.
     */
    function startRound() external virtual onlyModerator onlyCurrentACPI {
        _currentRound += 1;

        // Implement ACPI logic

        if (_currentRound == _totalRound) setAcpiPrice();
    }

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
     * @dev Set target user wins to 0 {onlyTokenContract}
     * note called after a claimTokens from the parent contract
     */
    function resetAccount(address account) external virtual;

    /**
     * @dev Emitted when a user win a round of any ACPI
     * `amount` is the amount of Governance Token RealT awarded
     */
    event RoundWin(
        address indexed winner,
        uint8 indexed acpiNumber,
        uint256 amount
    );

    /**
     * @dev Withdraw native currency {onlyTokenContract}
     */
    function withdraw(address recipient) external virtual onlyTokenContract {
        if (address(this).balance > 0 && recipient != address(0))
            payable(recipient).transfer(address(this).balance);
    }
}
