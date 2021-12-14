//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the Real Token
 */

import "@openzeppelin/contracts/access/IAccessControl.sol";


interface IACPIMaster is IAccessControl {
    
    event ACPIChanged(uint8 indexed newAcpi);

    function ACPI_MASTER() external view returns (bytes32);

    function ACPI_MODERATOR() external view returns (bytes32);

    function initialTokenPrice() external view returns (uint256);

    function getACPI() external view returns (uint8);

    function setACPI(uint8 newACPI) external;

    function getACPIWins() external view returns (uint256);

    function getACPIReturns() external view returns (uint256);

    function tokenToClaim() external view returns (uint256);

    function claimTokens() external;

    function withdrawAll(address vault) external;

   function withdrawTokens(address vault) external;

   function withdraw(address vault, uint256[4] calldata amounts) external;
}
