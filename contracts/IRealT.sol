//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";

/**
 * @dev Interface of the Real Token
 */

interface IRealT is IERC20, IAccessControl {
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);

    function ACPI_MODERATOR() external view returns (bytes32);

    function ACPI_CONTRACT() external view returns (bytes32);

    function TOKEN_CONTRACT() external view returns (bytes32);

    function getACPI() external view returns (uint8);

    function setACPI(uint8 currentACPI) external;

    function batchTransfer(
        address[] calldata sender,
        address[] calldata recipient,
        uint256[] calldata amount
    ) external;

    function mint(address account, uint256 amount) external;

    function batchMint(address[] calldata account, uint256[] calldata amount)
        external;

    function burn(address account, uint256 amount) external;

    function batchBurn(address[] calldata account, uint256[] calldata amount)
        external;

    function getACPIWins() external view returns (uint256);

    function getACPIReturns() external view returns (uint256);

    function claimTokens() external;

    function withdraw(address vault) external;
}
