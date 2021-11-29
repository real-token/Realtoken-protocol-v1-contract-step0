//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ACPI.sol";

contract ACPIOne is ACPI {
    address public highestBidder;
    uint256 public highestBid;

    uint256 public bidIncrement = 250 gwei;

    mapping(address => uint256) public pendingReturns;

    mapping(address => uint256) public pendingWins;

    // Address => _currentRound => balance
    mapping(address => mapping(uint256 => uint256)) private _balance;

    constructor() {
        _setupAbstract(msg.sender, 1);
        _roundTime = 60 * 5;
        _totalRound = 10;
    }

    /**
     * @dev Set bidIncrement value
     */
    function setBidIncrement(uint256 newValue)
        external
        onlyModerator
        returns (uint256)
    {
        return bidIncrement = newValue;
    }

    /**
     * @dev Start round of ACPI ending the last one.
     */
    function startRound() external override onlyModerator onlyCurrentACPI {
        _currentRound += 1;
        if (highestBidder != address(0)) {
            // Award Winner
            pendingWins[highestBidder] += 1;
            _priceHistory.push(highestBid);
            emit RoundWin(highestBidder, 1, 1);

            // Reset state
            highestBid = 0;
            highestBidder = address(0);
        }

        if (_currentRound == _totalRound) setAcpiPrice();
    }

    function bid() external payable onlyCurrentACPI {
        require(_currentRound < _totalRound, "BID: All rounds have been done");

        require(
            msg.value + _balance[msg.sender][_currentRound] >=
                highestBid + bidIncrement,
            "BID: value is to low"
        );
        if (highestBidder != address(0)) {
            // Refund the previously highest bidder.
            pendingReturns[highestBidder] += highestBid;
        }

        if (_balance[msg.sender][_currentRound] > 0)
            pendingReturns[msg.sender] -= _balance[msg.sender][_currentRound];

        _balance[msg.sender][_currentRound] += msg.value;

        highestBid = _balance[msg.sender][_currentRound];
        highestBidder = msg.sender;
    }

    function getBet(address account)
        external
        view
        onlyCurrentACPI
        returns (uint256)
    {
        return _balance[account][_currentRound];
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
