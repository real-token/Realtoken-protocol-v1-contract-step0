//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Interface of the Real Token
 */

interface IRealT is IERC20 {
    function batchTransfer(
        address[] calldata recipient,
        uint256[] calldata amount
    ) external returns (bool);

    function contractTransfer(address recipient, uint256 amount)
        external
        returns (bool);

    function mint(address account, uint256 amount) external returns (bool);

    function batchMint(address[] calldata account, uint256[] calldata amount)
        external
        returns (bool);

    function contractBurn(uint256 amount) external returns (bool);

    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        returns (bool);

    function withdraw(address payable recipient, uint256 amount)
        external
        returns (bool);
}
