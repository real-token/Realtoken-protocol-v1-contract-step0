//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ACPI.sol";
import "./Median.sol";

contract ACPIFour is ACPI {
    // Address => _currentRound => _currentTurn => didBet
    mapping(address => mapping(uint16 => mapping(uint16 => bool)))
        private _hasAlreadyBet;

    uint8 private _priceIncrease;

    uint16 private _currentTurn;

    uint56 private _rewardPerTurn;
    uint56 private _rewardLeft;

    uint256 private _price;
    uint256 private _lastPrice;
    uint256 private _defaultPrice;

    constructor() {
        _setupAbstract(msg.sender, 4);
        _priceIncrease = 60; // 60% increase
        _defaultPrice = 0.1 ether;
        _roundTime = 60 * 5; // seconds between each turn
        _totalRound = 10;
        _rewardPerTurn = 100;
        _rewardLeft = _rewardPerTurn;
        _price = _defaultPrice;
        _lastPrice = _defaultPrice;
    }

    /**
     * @dev Price per token in native currency
     */
    function setDefaultPrice(uint256 newValue) external onlyModerator {
        _defaultPrice = newValue;
    }

    /**
     * @dev Reward for each turn in number of tokens
     */
    function setReward(uint56 newValue) external onlyModerator {
        _rewardPerTurn = newValue;
        _rewardLeft = newValue;
    }

    /**
     * @dev Price increase between each turn in %
     */
    function setPriceIncrease(uint8 newValue) external onlyModerator {
        _priceIncrease = newValue;
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

    function buy() external payable onlyCurrentACPI {
        require(_currentRound < _totalRound, "BUY: All rounds have been done");

        require(
            !_hasAlreadyBet[msg.sender][_currentRound][_currentTurn],
            "You can only bet once per turn"
        );

        require(msg.value == _price, "BUY: value must match price");

        require(
            _rewardLeft > 0,
            "BUY: All tokens have been sold for this turn"
        );

        _hasAlreadyBet[msg.sender][_currentRound][_currentTurn] = true;
        _pendingWins[msg.sender] += 1 ether;
        _rewardLeft -= 1;

       emit Bid(msg.sender, 4, _price);
    }

    /**
     * @dev Start round of ACPI ending the last one.
     */
    function startRound() external override onlyModerator onlyCurrentACPI {
        require(_currentRound < _totalRound, "All rounds have been done");

        if (_rewardLeft > 0) {
            _priceHistory.push(
                    (_lastPrice * _rewardPerTurn +
                    _price * (_rewardPerTurn - _rewardLeft)) / (2 * _rewardPerTurn - _rewardLeft)
                
            );
            _currentRound += 1;
            _currentTurn = 0;
            _price = _defaultPrice;
            _lastPrice = _defaultPrice;
        } else {
            _lastPrice = _price;
            _currentTurn += 1;
            _price += (_price * _priceIncrease) / 100;
        }

        emit RoundWin(address(0), 4, _price);

        _rewardLeft = _rewardPerTurn;

        if (_currentRound == _totalRound) setAcpiPrice();
    }

    function setAcpiPrice() internal override {
        if (_priceHistory.length == 0) return;

        _acpiPrice = Median.from(_priceHistory);
    }
}
