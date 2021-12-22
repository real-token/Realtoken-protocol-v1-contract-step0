//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ACPI.sol";

contract ACPITwo is ACPI {
    // Address => _currentRound => balance
    mapping(address => mapping(uint16 => uint256)) private _balance;

    uint8 private _rewardMultiplicator;

    address[] private _roundBidders;

    uint256 private _minBid;
    uint256 private _roundPot;
    uint256 private _reward;

    constructor() ACPI(msg.sender, 2) {
        _roundTime = 60 * 5;
        _totalRound = 10;
        _minBid = 250 gwei;
        _reward = 1 ether;
        _rewardMultiplicator = 0;
    }

    /**
     * @dev bid to enter the round {onlyCurrentACPI}
     */
    function bid() external payable onlyCurrentACPI returns (bool) {
        require(_currentRound < _totalRound, "BID: All rounds have been done");
        require(msg.value >= _minBid, "bid have to be higher than minBid");

        if (_balance[msg.sender][_currentRound] == 0)
            _roundBidders.push(msg.sender);
        _balance[msg.sender][_currentRound] += msg.value;
        _roundPot += msg.value;

        emit Bid(msg.sender, _balance[msg.sender][_currentRound]);

        return true;
    }

    function roundPot() external view returns (uint256) {
        return _roundPot;
    }

    function reward() external view returns (uint256) {
        return _reward;
    }

    function minBid() external view returns (uint256) {
        return _minBid;
    }

    /**
     * @dev increase reward between each turn in %
     */
    function setRewardMultiplicator(uint8 newValue) external onlyModerator returns (bool) {
        _rewardMultiplicator = newValue;
        return true;
    }

    function setMinBid(uint256 newValue) external onlyModerator returns (bool) {
        _minBid = newValue;
        return true;
    }

    function getBet() external view onlyCurrentACPI returns (uint256) {
        return _balance[msg.sender][_currentRound];
    }

    /**
     * @dev Start round of ACPI ending the last one.
     */
    function startRound() external override onlyModerator onlyCurrentACPI returns (bool) {
        require(_currentRound < _totalRound, "All rounds have been done");

        if (_roundBidders.length > 0) {
            _priceHistory.push(_roundPot);

            for (uint256 i = 0; i < _roundBidders.length; i++) {
                _pendingWins[_roundBidders[i]] +=
                    (_balance[_roundBidders[i]][_currentRound] * _reward) /
                    _roundPot;
            }
            delete _roundBidders;

            emit RoundWin(_roundPot);

            _roundPot = 0;

            _reward += (_reward * _rewardMultiplicator) / 100;
        }

        _currentRound += 1;
        if (_currentRound == _totalRound) setAcpiPrice();

        return true;
    }
}
