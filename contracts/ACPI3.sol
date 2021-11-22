//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RealT.sol";
import "./IACPI.sol";

contract ACPIThree is IACPI {
    mapping(address => uint256) private _balance;
    uint256 private _acpiPrice;
    RealT private realtERC20;

    uint256 public currentRound;

    uint256 private _roundTime;
    uint256 private _totalRound;

    mapping(address => uint256) public pendingReturns;

    mapping(address => uint256) public pendingWins;

    constructor() {
        realtERC20 = RealT(msg.sender);
        _roundTime = 60 * 60;
        _totalRound = 100;
    }

    modifier onlyAcpiThree() {
        require(realtERC20.getACPI() == 3, "Current ACPI is not ACPI 3");
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
     * @dev Returns the amount of rounds per ACPI.
     */
    function totalRound() external view override returns (uint256) {
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
     * @dev Start round of ACPI ending the last one.
     */
    function startRound() public override onlyModerator {}

    /**
     * @dev Returns the average value for target ACPI will be 0 until acpi end
     */
    function acpiPrice() external view override returns (uint256) {
        return _acpiPrice;
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
