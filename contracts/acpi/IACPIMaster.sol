//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the Real Token
 */

import "@openzeppelin/contracts/access/IAccessControl.sol";
import "../reg/IREG.sol";

interface IACPIMaster is IAccessControl {
    event ACPIChanged(uint8 indexed newAcpi);

    function tokenContract() external view returns (address);

    function acpiOneContract() external view returns (address);

    function acpiTwoContract() external view returns (address);

    function acpiThreeContract() external view returns (address);

    function acpiFourContract() external view returns (address);

    function ACPI_MASTER() external view returns (bytes32);

    function ACPI_MODERATOR() external view returns (bytes32);

    function initialTokenPrice() external view returns (uint256);

    function crossChainPrice() external view returns (uint256);

    function getACPI() external view returns (uint8);

    function generateCrossChainPrice(uint256 averageCrossChainPrice) external returns (bool);

    function setACPI(uint8 newACPI) external returns (bool);

    function getACPIWins() external view returns (uint256);

    function getACPIReturns() external view returns (uint256);

    function tokenToClaim() external view returns (uint256);

    function claimTokens() external returns (bool);

    function withdrawTokens(address payable vault, uint256 amount)
        external
        returns (bool);

    function withdrawAll(address payable vault)
        external
        returns (bool);

    function withdraw(address payable vault, uint256[4] calldata amounts)
        external
        returns (bool);

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external returns (bool);

    function setTokenAddress(address tokenAddress) external returns (bool);

    function setACPIOne(address acpiAddress) external returns (bool);

    function setACPITwo(address acpiAddress) external returns (bool);

    function setACPIThree(address acpiAddress) external returns (bool);


    function setACPIFour(address acpiAddress) external returns (bool);
}
