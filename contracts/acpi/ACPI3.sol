//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ACPI.sol";

contract ACPIThree is ACPI {
    uint256 private _bidAmount;

    address[] private _bidders;

    // Address => _currentRound => didBet
    mapping(address => mapping(uint16 => bool)) private _hasAlreadyBid;

    constructor() ACPI(msg.sender, 3) {
        _bidAmount = 250 gwei;
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
        return true;
    }

    function getBiddersNumber() external view returns (uint256) {
        return _bidders.length;
    }

    function hasBid() external view returns (bool) {
        return _hasAlreadyBid[msg.sender][_currentRound];
    }

    /**
     * @dev bid to enter the round {onlyCurrentACPI}
     */
    function bid(uint16 targetRound) external override payable onlyCurrentACPI returns (bool) {
        require(_currentRound < _totalRound, "BID: All rounds have been done");
        require(
            targetRound == _currentRound,
            "BID: Current round is over"
        );

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
     * @dev Start round of ACPI ending the last one. {onlyModerator}
     */
    function startRound()
        external
        override
        onlyModerator
        onlyCurrentACPI
        returns (bool)
    {
        require(_currentRound < _totalRound, "START: All rounds have been done");

        if (_bidders.length > 0) {
            _totalWins += 1 ether;
            _priceHistory.push(_bidders.length * _bidAmount);
            for (uint256 i = 0; i < _bidders.length; i++) {
                _pendingWins[_bidders[i]] +=
                    1 ether /
                    _bidders.length;
            }
            delete _bidders;

            emit RoundWin(_bidders.length * _bidAmount);
        }
        _currentRound += 1;
        if (_currentRound == _totalRound) setAcpiPrice();

        return true;
    }
}