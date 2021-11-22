//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RealT.sol";
import "./IACPI.sol";

contract ACPITwo is IACPI {
    mapping(address => uint256) private _balance;
    uint256 private _acpiPrice;
    RealT private realtERC20;

    mapping(address => uint256) public pendingReturns;

    mapping(address => uint256) public pendingWins;

    uint256 public currentRound;

    uint256 private _roundTime;
    uint256 private _totalRound;

    constructor() {
        realtERC20 = RealT(msg.sender);
    }

    modifier onlyAcpiTwo() {
        require(realtERC20.getACPI() == 2, "Current ACPI is not ACPI 2");
        _;
    }

    modifier onlyModerator() {
        require(realtERC20.hasRole(realtERC20.ACPI_MODERATOR(), msg.sender));
        _;
    }

    modifier onlyTokenContract() {
        require(realtERC20.hasRole(realtERC20.TOKEN_CONTRACT(), msg.sender));
        _;
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
     * @dev Returns the amount of rounds per ACPI.
     */
    function totalRound() external view override returns (uint256) {
        return _roundTime;
    }

    /**
     * @dev Returns the time between two consecutive round in seconds
     */
    function roundTime() external view override returns (uint256) {
        return _roundTime;
    }

    /**
     * @dev Start round of ACPI ending the last one.
     */
    function startRound() public override onlyModerator {}

    /**
     * @dev Returns the average value for target ACPI will be 0 until acpi end
     */
    function acpiPrice() public view override returns (uint256) {
        return _acpiPrice;
    }

    /**
     * @dev Set pendingReturns and pendingWins to 0 {onlyTokenContract}
     */
    function resetAccount(address account)
        external
        override
        onlyTokenContract
    {
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