//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ACPI.sol";

contract ACPIFour is ACPI {
    mapping(address => uint256) private _balance;
    uint256 private _acpiPrice;

    mapping(address => uint256) public pendingReturns;

    mapping(address => uint256) public pendingWins;

    constructor() {
        _setupAbstract(msg.sender, 4);
        _roundTime = 60 * 5;
        _totalRound = 10;
    }

    /**
     * @dev Start round of ACPI ending the last one.
     */
    function startRound() external override onlyModerator {
        _currentRound += 1;

        if (_currentRound == _totalRound) setAcpiPrice();
    }

    /**
     * @dev Set target user wins to 0 {onlyTokenContract}
     * note called after a claimTokens from the parent contract
     */
    function resetAccount(address account) external override onlyTokenContract {
        pendingReturns[account] = 0;
        pendingWins[account] = 0;
    }
}
