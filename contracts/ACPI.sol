//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IRealT.sol";

/**
 * @dev Abstract contract of the ACPI standard by realt.co
 */

abstract contract ACPI {
    IRealT internal _realtERC20;
    uint256[] internal _priceHistory;

    uint256 internal _currentRound;
    uint256 internal _totalRound;
    uint256 internal _roundTime;

    uint256 public acpiPrice;

    uint8 internal _acpiNumber;

   modifier onlyCurrentACPI() {
        require(_realtERC20.getACPI() == _acpiNumber, "Only Current ACPI Method");
        _;
    }

   modifier onlyTokenContract() {
        require(_realtERC20.hasRole(_realtERC20.TOKEN_CONTRACT(), msg.sender), "Only Token Contract Method");
        _;
    }

    modifier onlyModerator() {
        require(_realtERC20.hasRole(_realtERC20.ACPI_MODERATOR(), msg.sender), "Only ACPI Moderator Method");
        _;
    }

    /**
     * @dev Setup Abstract contract must be called only in the child contract
     */
    function _setupAbstract(address realtERC20, uint8 acpiNumber) virtual internal {
        _realtERC20 = IRealT(realtERC20);
        _acpiNumber = acpiNumber;
    }

    /**
     * @dev Returns the current round.
     */
    function currentRound() virtual external view returns (uint256) {
        return _currentRound;
    }

    /**
     * @dev Returns the amount of rounds per ACPI.
     */
    function totalRound() virtual external view returns (uint256) {
        return _totalRound;
    }

    /**
     * @dev Returns the time between two consecutive round in seconds
     */
    function roundTime() external virtual view returns (uint256) {
        return _roundTime;
    }

    /**
     * @dev Set totalRound value
     */
    function setTotalRound(uint256 newValue)
        external
        virtual
        onlyModerator
        returns (uint256)
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
        uint256 sum;
        for (uint256 i; i < _priceHistory.length; i++) {
            sum += _priceHistory[i] / _priceHistory.length;
        }
        acpiPrice = sum;
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
    event RoundWin(address indexed winner, uint8 indexed acpiNumber, uint256 amount);

    /**
     * @dev Withdraw native currency {onlyTokenContract}
     */
    function withdraw(address recipient) external virtual onlyTokenContract {
        payable(recipient).transfer(address(this).balance);
    }
}