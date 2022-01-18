//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ACPI.sol";

contract ACPIThree is ACPI {
    uint256 private _bidAmount;

    address[] private _bidders;

    // Address => _currentRound => didBet
    mapping(address => mapping(uint16 => bool)) private _hasAlreadyBid;

    constructor(address acpiMaster) ACPI(acpiMaster, 3) {
        _bidAmount = 250 gwei;
    }

    event LogSetBidAmount(uint256 indexed newValue);

    /**
     * @dev Start round of ACPI ending the last one. {onlyModerator}
     */
    function startRound()
        external
        override
        onlyModerator
        onlyCurrentACPI
        returns (bool)
    {
        require(
            _currentRound < _totalRound,
            "START: All rounds have been done"
        );
        uint256 _bidderLength = _bidders.length;
        if (_bidderLength > 0) {
            _totalWins += 1 ether;
            _priceHistory.push(_bidderLength * _bidAmount);
            for (uint256 i = 0; i < _bidderLength; i++) {
                _pendingWins[_bidders[i]] += 1 ether / _bidderLength;
            }
            delete _bidders;
        }
        _currentRound += 1;
        if (_currentRound == _totalRound) setAcpiPrice();

        emit RoundWin(_bidderLength * _bidAmount);
        return true;
    }

    /**
     * @dev bid to enter the round {onlyCurrentACPI}
     */
    function bid(uint16 targetRound)
        external
        payable
        override
        onlyCurrentACPI
        returns (bool)
    {
        require(_currentRound < _totalRound, "BID: All rounds have been done");
        require(targetRound == _currentRound, "BID: Current round is over");

        require(
            msg.value == _bidAmount,
            "BID: Amount sent doesn't match expected value"
        );
        require(
            !_hasAlreadyBid[msg.sender][_currentRound],
            "BID: You can only bet once per round"
        );

        _bidders.push(msg.sender);
        _hasAlreadyBid[msg.sender][_currentRound] = true;

        emit Bid(msg.sender, _bidAmount);

        return true;
    }

    /**
     * @dev Returns the value each user needs to bet to enter a round.
     */
    function bidAmount() external view returns (uint256) {
        return _bidAmount;
    }

    /**
     * @dev Set the bid amount value {onlyModerator}
     */
    function setBidAmount(uint256 newValue)
        external
        onlyModerator
        returns (bool)
    {
        _bidAmount = newValue;
        emit LogSetBidAmount(newValue);
        return true;
    }

    function getBiddersNumber() external view returns (uint256) {
        return _bidders.length;
    }

    function hasBid() external view returns (bool) {
        return _hasAlreadyBid[msg.sender][_currentRound];
    }
}
