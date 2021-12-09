//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ACPI.sol";

contract ACPIThree is ACPI {
    uint256 private _bidAmount;

    address[] private _roundBidders;

    // Address => _currentRound => didBet
    mapping(address => mapping(uint16 => bool)) private _hasAlreadyBet;

    constructor() {
        _setupAbstract(msg.sender, 3);
        _roundTime = 60 * 5;
        _totalRound = 10;
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
    function setBidAmount(uint256 newValue) external onlyModerator {
        _bidAmount = newValue;
    }

    /**
     * @dev bid to enter the round {onlyCurrentACPI}
     */
    function bid() external payable onlyCurrentACPI {
        require(_currentRound < _totalRound, "BID: All rounds have been done");
        require(
            msg.value == _bidAmount,
            "Bid value should match exactly bid amount"
        );
        require(
            !_hasAlreadyBet[msg.sender][_currentRound],
            "You already bet this round"
        );

        _roundBidders.push(msg.sender);
        _hasAlreadyBet[msg.sender][_currentRound] = true;

        emit Bid(msg.sender, _bidAmount);
    }

    /**
     * @dev Start round of ACPI ending the last one. {onlyModerator}
     */
    function startRound() external override onlyModerator onlyCurrentACPI {
        require(_currentRound < _totalRound, "All rounds have been done");

        if (_roundBidders.length > 0) {
            _priceHistory.push(_roundBidders.length * _bidAmount);
            for (uint256 i = 0; i < _roundBidders.length; i++) {
                _pendingWins[_roundBidders[i]] +=
                    1 ether /
                    _roundBidders.length;
            }
            delete _roundBidders;

            emit RoundWin(address_roundBidders.length * _bidAmount);
        }
        _currentRound += 1;
        if (_currentRound == _totalRound) setAcpiPrice();
    }
}
