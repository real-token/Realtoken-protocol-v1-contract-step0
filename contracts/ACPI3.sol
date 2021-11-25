//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ACPI.sol";

contract ACPIThree is ACPI {
    uint256 public _acpiPrice;

    uint256 private _bidAmount;

    address[] private _roundBidders;

    mapping(address => uint256) public pendingWins;

    // Address => _currentRound => didBet
    mapping(address => mapping(uint256 => bool)) private _hasAlreadyBet;

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
    function setBidAmount(uint256 newValue)
        external
        onlyModerator
        returns (uint256)
    {
        return _bidAmount = newValue;
    }

    /**
     * @dev bid to enter the round {onlyCurrentACPI}
     */
    function bid()
        external
        payable
        onlyCurrentACPI
    {
        require(msg.value == _bidAmount, "Bid value should match exactly bid amount");
        require(!_hasAlreadyBet[msg.sender][_currentRound], "You already bet this round");
        
        _roundBidders.push(msg.sender);
        _hasAlreadyBet[msg.sender][_currentRound] = true;
    }
    /**
     * @dev Start round of ACPI ending the last one. {onlyModerator}
     */
    function startRound() external override onlyModerator onlyCurrentACPI{
        _currentRound += 1;

        if (_roundBidders.length > 0) {
            _priceHistory.push(_roundBidders.length * _bidAmount);
            for (uint256 i; i < _roundBidders.length; i++) {
                pendingWins[_roundBidders[i]] += 1 ether / _roundBidders.length;
            }
            delete _roundBidders;
        }
        if (_currentRound == _totalRound) setAcpiPrice();
    }

    /**
     * @dev Set target user wins to 0 {onlyTokenContract}
     * note called after a claimTokens from the parent contract
     */
    function resetAccount(address account) external override onlyTokenContract {
        pendingWins[account] = 0;
    }
}
