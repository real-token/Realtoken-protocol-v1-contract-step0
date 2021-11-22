//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RealT.sol";
import "./IACPI.sol";

contract ACPIOne is IACPI {
    address public highestBidder;
    uint256 public highestBid;

    uint256 public bidIncrement = 250 gwei;

    uint256[] private _priceHistory;

    mapping(address => uint256) public pendingReturns;

    mapping(address => uint256) public pendingWins;

    // Address => currentRound => balance
    mapping(address => mapping(uint256 => uint256)) private _balance;

    uint256 public currentRound;

    uint256 private _roundTime;
    uint256 private _totalRound;

    RealT private realtERC20;

    constructor() {
        realtERC20 = RealT(msg.sender);
        _roundTime = 60 * 60;
        _totalRound = 100;
    }

    modifier onlyAcpiOne() {
        require(realtERC20.getACPI() == 1, "Current ACPI is not ACPI 1");
        _;
    }

    modifier onlyTokenContract() {
        require(realtERC20.hasRole(realtERC20.TOKEN_CONTRACT(), msg.sender));
        _;
    }

    modifier onlyModerator() {
        require(realtERC20.hasRole(realtERC20.ACPI_MODERATOR(), msg.sender));
        _;
    }

    /**
     * @dev Returns the amount of rounds per ACPI.
     */
    function totalRound() public view override returns (uint256) {
        return _totalRound;
    }

    /**
     * @dev Returns the time between two consecutive round in seconds
     */
    function roundTime() external view override returns (uint256) {
        return _roundTime;
    }

    /**
     * @dev Set time between two consecutive round in seconds
     */
    function setRoundTime(uint256 newValue)
        external
        override
        onlyModerator
        returns (uint256)
    {
        return _roundTime = newValue;
    }

    /**
     * @dev Set totalRound value
     */
    function setTotalRound(uint256 newValue)
        external
        override
        onlyModerator
        returns (uint256)
    {
        return _totalRound = newValue;
    }

    /**
     * @dev Set bidIncrement value
     */
    function setBidIncrement(uint256 newValue)
        external
        onlyModerator
        returns (uint256)
    {
        return bidIncrement = newValue;
    }

    /**
     * @dev Start round of ACPI ending the last one.
     */
    function startRound() external override onlyModerator onlyAcpiOne {
        currentRound += 1;
        if (highestBidder != address(0)) {
            // Award Winner
            pendingWins[highestBidder] += 1;
            _priceHistory.push(highestBid);
            emit RoundWin(highestBidder, 1, 1);

            // Reset state
            highestBid = 0;
            highestBidder = address(0);
        }
    }

    function bid() external payable onlyAcpiOne {
        require(currentRound < totalRound(), "BID: All rounds have been done");

        require(
            msg.value + _balance[msg.sender][currentRound] >
                highestBid + bidIncrement,
            "BID: value is to low"
        );
        if (highestBidder != address(0)) {
            // Refund the previously highest bidder.
            pendingReturns[highestBidder] += highestBid;
        }

        if (_balance[msg.sender][currentRound] > 0)
            pendingReturns[msg.sender] -= _balance[msg.sender][currentRound];

        _balance[msg.sender][currentRound] += msg.value;

        highestBid = _balance[msg.sender][currentRound];
        highestBidder = msg.sender;
    }

    function getBet(address account)
        external
        view
        onlyAcpiOne
        returns (uint256)
    {
        return _balance[account][currentRound];
    }

    /**
     * @dev Returns the average value for target ACPI will be 0 until acpi end
     */
    function acpiPrice() public view override returns (uint256) {
        if (realtERC20.getACPI() <= 1 || _priceHistory.length == 0) return 0;
        uint256 sum;
        for (uint256 i; i < _priceHistory.length; i++) {
            sum += _priceHistory[i];
        }
        return sum / _priceHistory.length;
    }

    /**
     * @dev Set pendingReturns and pendingWins to 0 {onlyTokenContract}
     */
    function resetAccount(address account) external override onlyTokenContract {
        pendingReturns[account] = 0;
        pendingWins[account] = 0;
    }

    /**
     * @dev Withdraw native currency {onlyTokenContract}
     */
    function withdraw(address recipient) external override onlyTokenContract {
        payable(recipient).transfer(address(this).balance);
    }
}
