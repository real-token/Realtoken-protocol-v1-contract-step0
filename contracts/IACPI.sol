//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ACPI standard by realt.co
 */

interface IACPI {
    /**
     * @dev Returns the amount of rounds per ACPI.
     */
    function totalRound() external view returns (uint256);

    /**
     * @dev Set totalRound value
     */
    function setTotalRound(uint256 newValue) external returns (uint256);

    /**
     * @dev Returns the time between two consecutive round in seconds
     */
    function roundTime() external view returns (uint256);

    /**
     * @dev Set time between two consecutive round in seconds
     */
    function setRoundTime(uint256 newValue) external returns (uint256);

    /**
     * @dev Start round of ACPI ending the last one.
     */
    function startRound() external;

    /**
     * @dev Returns the average value for target ACPI will be 0 until acpi end
     */
    function acpiPrice() external view returns (uint256);

    /**
     * @dev Set pendingReturns and pendingWins to 0 {onlyTokenContract}
     */
    function resetAccount(address account) external;

    /**
     * @dev Withdraw native currency {onlyTokenContract}
     */
    function withdraw(address recipient) external;

    /**
     * @dev Emitted when a user win a round of any ACPI
     * `amount` is the amount of Governance Token RealT awarded
     */
    event RoundWin(address indexed winner, uint8 indexed acpiNumber, uint256 amount);

}
