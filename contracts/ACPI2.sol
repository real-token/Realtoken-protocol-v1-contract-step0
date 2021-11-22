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

    constructor() {
        realtERC20 = RealT(msg.sender);
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
    function totalRound() external view override returns (uint256) {}

    /**
     * @dev Returns the amount of blocks per ACPI.
     */
    function roundTime() external pure override returns (uint256) {
        return 16;
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
     * @dev Set pendingReturns and pendingWins to 0
     */
    function resetAccount(address account)
        external
        override
        onlyTokenContract
    {
        pendingReturns[account] = 0;
        pendingWins[account] = 0;
    }
}