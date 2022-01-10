//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ACPI.sol";
import "./Median.sol";

contract ACPIFour is ACPI {
    // Address => _currentRound => _currentTurn => didBet
    mapping(address => mapping(uint16 => mapping(uint16 => bool)))
        private _hasAlreadyBid;

    uint8 private _priceIncrease;

    uint16 private _currentTurn;

    uint56 private _rewardPerTurn;
    uint56 private _rewardLeft;

    uint256 private _price;
    uint256 private _lastPrice;
    uint256 private _defaultPrice;

    constructor() ACPI(msg.sender, 4) {
        _priceIncrease = 60; // 60% increase
        _defaultPrice = 0.1 ether;
        _rewardPerTurn = 50;
        _rewardLeft = _rewardPerTurn;
        _price = _defaultPrice;
        _lastPrice = 0 ether;
        _roundTime = 60 * 10;
        _totalRound = 11;
    }

    /**
     * @dev Price per token in native currency
     */
    function setDefaultPrice(uint256 newValue)
        external
        onlyModerator
        returns (bool)
    {
        _defaultPrice = newValue;
        return true;
    }

    /**
     * @dev Reward for each turn in number of tokens
     */
    function setReward(uint56 newValue) external onlyModerator returns (bool) {
        _rewardPerTurn = newValue;
        _rewardLeft = newValue;
        return true;
    }

    /**
     * @dev Price increase between each turn in %
     */
    function setPriceIncrease(uint8 newValue)
        external
        onlyModerator
        returns (bool)
    {
        _priceIncrease = newValue;
        return true;
    }

    function defaultPrice() external view returns (uint256) {
        return _defaultPrice;
    }

    function price() external view returns (uint256) {
        return _price;
    }

    function priceIncrease() external view returns (uint8) {
        return _priceIncrease;
    }

    function rewardLeft() external view returns (uint256) {
        return _rewardLeft;
    }

    function rewardPerTurn() external view returns (uint256) {
        return _rewardPerTurn;
    }

    function currentTurn() external view returns (uint256) {
        return _currentTurn;
    }

    function hasBid() external view returns (bool) {
        return _hasAlreadyBid[msg.sender][_currentRound][_currentTurn];
    }

    function bid(uint16 targetTurn)
        external
        payable
        override
        onlyCurrentACPI
        returns (bool)
    {
        require(_currentRound < _totalRound, "BID: All rounds have been done");
        require(_currentTurn == targetTurn, "BID: Current round is over");

        require(
            !_hasAlreadyBid[msg.sender][_currentRound][_currentTurn],
            "BID: You can only bet once per turn"
        );

        require(
            msg.value == _price,
            "BID: Amount sent doesn't match expected value"
        );

        require(
            _rewardLeft > 0,
            "BID: All tokens have been sold for this turn"
        );

        _hasAlreadyBid[msg.sender][_currentRound][_currentTurn] = true;
        _pendingWins[msg.sender] += 1 ether;
        _totalWins += 1 ether;
        _rewardLeft -= 1;

        emit Bid(msg.sender, _price);

        return true;
    }

    /**
     * @dev Start round of ACPI ending the last one.
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

        if (_rewardLeft > 0) {
            if (_currentTurn == 0) {
                _priceHistory.push(_price);
            } else if (_rewardPerTurn - _rewardLeft > 0) {
                _priceHistory.push(
                    (_lastPrice *
                        _rewardPerTurn +
                        _price *
                        (_rewardPerTurn - _rewardLeft)) /
                        (2 * _rewardPerTurn - _rewardLeft)
                );
            } else {
                _priceHistory.push(_lastPrice);
            }

            _currentRound += 1;
            _currentTurn = 0;
            _price = _defaultPrice;
            _lastPrice = _defaultPrice;
        } else {
            _lastPrice = _price;
            _currentTurn += 1;
            _price += (_price * _priceIncrease) / 100;
        }

        emit RoundWin(_price);

        _rewardLeft = _rewardPerTurn;

        if (_currentRound == _totalRound) setAcpiPrice();

        return true;
    }

    function setAcpiPrice() internal override {
        _acpiPrice = Median.from(_priceHistory);
    }
}
