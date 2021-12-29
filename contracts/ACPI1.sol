//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ACPI.sol";
import "./Median.sol";

contract ACPIOne is ACPI {
    address private _highestBidder;
    uint256 private _highestBid;

    uint256 private _bidIncrement = 250 gwei;

    mapping(address => uint256) private _pendingReturns;

    uint256 private _totalReturns;

    // Address => _currentRound => balance
    mapping(address => mapping(uint16 => uint256)) private _balance;

    event RoundWin(address winner, uint256 amount);

    constructor() ACPI(msg.sender, 1) {}

    /**
     * @dev Set bidIncrement value
     */
    function setBidIncrement(uint256 newValue) external onlyModerator returns (bool) {
        _bidIncrement = newValue;
        return true;
    }

    function pendingReturns(address account) external override view returns (uint256) {
        return _pendingReturns[account];
    }

    function totalReturns() external override view returns (uint256) {
        return _totalReturns;
    }

    function highestBid() external view returns (uint256) {
        return _highestBid;
    }

    function highestBidder() external view returns (address) {
        return _highestBidder;
    }

    function bidIncrement() external view returns (uint256) {
        return _bidIncrement;
    }

    /**
     * @dev Start round of ACPI ending the last one.
     */
    function startRound() external override onlyModerator onlyCurrentACPI returns (bool) {
        require(_currentRound < _totalRound, "START: All rounds have been done");

        emit RoundWin(_highestBidder, _highestBid);

        if (_highestBidder != address(0)) {
            // Award Winner
            _pendingWins[_highestBidder] += 1 ether;
            _priceHistory.push(_highestBid);
            _totalWins += 1 ether;
            // Reset state
            _highestBid = 0;
            _highestBidder = address(0);
        }

        _currentRound += 1;
        if (_currentRound == _totalRound) setAcpiPrice();
        return true;
    }

    function setAcpiPrice() internal override {
        if (_priceHistory.length == 0) return;

        _acpiPrice = Median.from(_priceHistory);
    }

    function bid(uint16 targetRound) external override payable onlyCurrentACPI returns (bool) {
        require(_currentRound < _totalRound, "BID: All rounds have been done");
        require(targetRound == _currentRound, "BID: Current round is over");
        require(
            msg.value + _balance[msg.sender][_currentRound] >=
                _highestBid + _bidIncrement,
            "BID: value is too low"
        );

        if (_highestBidder != address(0)) {
            // Refund the previously highest bidder.
            _pendingReturns[_highestBidder] += _highestBid;
            _totalReturns += _highestBid;
        }

        if (_balance[msg.sender][_currentRound] > 0) {
            _pendingReturns[msg.sender] -= _balance[msg.sender][_currentRound];
            _totalReturns -= _balance[msg.sender][_currentRound];
        }

        _balance[msg.sender][_currentRound] += msg.value;

        _highestBid = _balance[msg.sender][_currentRound];
        _highestBidder = msg.sender;

        emit Bid(msg.sender, _highestBid);

        return true;
    }

    function getBid() external view onlyCurrentACPI returns (uint256) {
        return _balance[msg.sender][_currentRound];
    }

    /**
     * @dev Set target user wins to 0 {onlyACPIMaster}
     * note called after a claimTokens from the parent contract
     */
    function resetAccount(address account) external override onlyACPIMaster returns (bool) {
        _pendingReturns[account] = 0;
        _pendingWins[account] = 0;
        return true;
    }
}
