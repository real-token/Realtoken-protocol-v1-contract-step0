//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ACPI.sol";
import "./Median.sol";

contract ACPIFour is ACPI {
    mapping(address => uint256) public pendingWins;

    // TODO uin256 is a bit overkill for these 3 ?
    uint256 private _currentTurn;
    uint256 private _rewardPerTurn;
    uint256 private _rewardLeft;

    uint256 private _turnTime;
    uint256 private _price;
    uint256 private _lastPrice;

    // TODO Should we make this a setable veriable ?
    uint256 constant private _DEFAULT_PRICE = 0.1 ether;

    constructor() {
        _setupAbstract(msg.sender, 4);
        _roundTime = 60 * 5;
        _turnTime = 10 * 60;
        _totalRound = 10;
        _rewardPerTurn = 100;
        _rewardLeft = _rewardPerTurn;
        _price = _DEFAULT_PRICE;
        _lastPrice = _DEFAULT_PRICE;
    }

    function price() external view returns (uint256) {
        return _price;
    }

    function setPrice(uint256 newValue) external onlyModerator {
        _price = newValue;
    }

    function rewardLeft() external view returns (uint256) {
        return _rewardLeft;
    }

    function rewardPerTurn() external view returns (uint256) {
        return _rewardPerTurn;
    }

    function setReward(uint256 newValue) external onlyModerator {
        _rewardPerTurn = newValue;
        _rewardLeft = newValue;
    }

    function turnTime() external view returns (uint256) {
        return _roundTime;
    }

    function setTurnTime(uint256 newValue) external onlyModerator {
        _turnTime = newValue;
    }

    function currentTurn() external view returns (uint256) {
        return _currentTurn;
    }

    function buy() external payable onlyCurrentACPI {
        require(_currentRound < _totalRound, "BUY: All rounds have been done");

        require(msg.value > _price, "BUY: value is to low");

        require(msg.value % _price == 0, "BUY: value should be an exact multiple of price");

        require(_rewardLeft >= msg.value / _price, "BUY: Too few token to buy this round");
     
        // Multiple after to prevent overflow
        pendingWins[msg.sender] += msg.value / _price * 1 ether;
        _rewardLeft -= msg.value / _price;
    }

    /**
     * @dev Start round of ACPI ending the last one.
     */
    function startRound() external override onlyModerator onlyCurrentACPI {
        if (_rewardLeft > 0) {
            _priceHistory.push(Math.average(_lastPrice * 100, _price * _rewardPerTurn - _rewardLeft));
            _currentRound += 1;
            _currentTurn = 0;
            _price = _DEFAULT_PRICE;
            _lastPrice = _DEFAULT_PRICE;
            _rewardLeft = _rewardPerTurn;
        } else {
            _lastPrice = _price;
            _currentTurn += 1;
            _price += _price * 60 / 100;
            _rewardLeft = _rewardPerTurn;
        }
        if (_currentRound == _totalRound) setAcpiPrice();
    }

    function setAcpiPrice() internal override {
        if (_priceHistory.length == 0) return;

        acpiPrice = Median.from(_priceHistory);
    }

    /**
     * @dev Set target user wins to 0 {onlyTokenContract}
     * note called after a claimTokens from the parent contract
     */
    function resetAccount(address account) external override onlyTokenContract {
        pendingWins[account] = 0;
    }
}
