//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ACPI.sol";
import "./Median.sol";

contract ACPIOne is ACPI {
    address private _highestBidder;
    uint256 private _highestBid;

    uint256 private _bidIncrement = 250 gwei;

    mapping(address => uint256) private _pendingReturns;

    // Address => _currentRound => balance
    mapping(address => mapping(uint16 => uint256)) private _balance;

    constructor() {
        _setupAbstract(msg.sender, 1);
        _roundTime = 60 * 5;
        _totalRound = 10;
    }

    /**
     * @dev Set bidIncrement value
     */
    function setBidIncrement(uint256 newValue) external onlyModerator {
        _bidIncrement = newValue;
    }

    function pendingReturns(address account) external view returns (uint256) {
        return _pendingReturns[account];
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
    function startRound() external override onlyModerator onlyCurrentACPI {
        require(_currentRound < _totalRound, "All rounds have been done");

        if (_highestBidder != address(0)) {
            // Award Winner
            _pendingWins[_highestBidder] += 1 ether;
            _priceHistory.push(_highestBid);
            emit RoundWin(1 ether);

            // Reset state
            _highestBid = 0;
            _highestBidder = address(0);
        }

        _currentRound += 1;
        if (_currentRound == _totalRound) setAcpiPrice();
    }

    function setAcpiPrice() internal override {
        if (_priceHistory.length == 0) return;

        _acpiPrice = Median.from(_priceHistory);
    }

    function bid() external payable onlyCurrentACPI {
        require(_currentRound < _totalRound, "BID: All rounds have been done");

        require(
            msg.value + _balance[msg.sender][_currentRound] >=
                _highestBid + _bidIncrement,
            "BID: value is to low"
        );

        require(_highestBidder != msg.sender, "BID: Sender is already winning");

        if (_highestBidder != address(0)) {
            // Refund the previously highest bidder.
            _pendingReturns[_highestBidder] += _highestBid;
        }

        if (_balance[msg.sender][_currentRound] > 0) {
            _pendingReturns[msg.sender] -= _balance[msg.sender][_currentRound];
        }

        _balance[msg.sender][_currentRound] += msg.value;

        _highestBid = _balance[msg.sender][_currentRound];
        _highestBidder = msg.sender;

        emit Bid(msg.sender, _highestBid);
    }

    function getBet()
        external
        view
        onlyCurrentACPI
        returns (uint256)
    {
        return _balance[msg.sender][_currentRound];
    }

    /**
     * @dev Set target user wins to 0 {onlyTokenContract}
     * note called after a claimTokens from the parent contract
     */
    function resetAccount(address account) external override onlyTokenContract {
        _pendingReturns[account] = 0;
        _pendingWins[account] = 0;
    }
}
