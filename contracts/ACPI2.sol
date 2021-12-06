//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ACPI.sol";

contract ACPITwo is ACPI {
    // Address => _currentRound => balance
    mapping(address => mapping(uint16 => uint256)) private _balance;

    address[] private _roundBidders;

    uint256 private _minBid;
    uint256 private _roundPot;
    uint256 private _reward;

    constructor() {
        _setupAbstract(msg.sender, 2);
        _roundTime = 60 * 5;
        _totalRound = 10;
        _minBid = 250 gwei;
        _reward = 1 ether;
    }

    /**
     * @dev bid to enter the round {onlyCurrentACPI}
     */
    function bid() external payable onlyCurrentACPI {
        require(_currentRound < _totalRound, "BID: All rounds have been done");
        require(msg.value >= _minBid, "bid have to be higher than minBid");

        if (_balance[msg.sender][_currentRound] == 0)
            _roundBidders.push(msg.sender);
        _balance[msg.sender][_currentRound] += msg.value;
        _roundPot += msg.value;
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

    function setMinBid(uint256 newValue)
        external
        onlyModerator
        returns (uint256)
    {
        return _minBid = newValue;
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
     * @dev Start round of ACPI ending the last one.
     */
    function startRound() external override onlyModerator onlyCurrentACPI {
        require(_currentRound < _totalRound, "All rounds have been done");

        if (_roundBidders.length > 0) {
            _priceHistory.push(_roundPot);
            for (uint256 i = 0; i < _roundBidders.length; i++) {
                _pendingWins[_roundBidders[i]] +=
                    (_balance[_roundBidders[i]][_currentRound] * _reward) /
                    _roundPot;
            }
            delete _roundBidders;

            _roundPot = 0;

            // TODO Incrementation variable
            _reward += _reward / 100;
        }

        _currentRound += 1;
        if (_currentRound == _totalRound) setAcpiPrice();
    }

    /**
     * @dev Set target user wins to 0 {onlyTokenContract}
     * note called after a claimTokens from the parent contract
     */
    function resetAccount(address account) external override onlyTokenContract {
        _pendingWins[account] = 0;
    }
}
