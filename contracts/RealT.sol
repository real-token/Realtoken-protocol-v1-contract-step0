//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IRealT.sol";

// @ made by github.com/@chichke

contract RealT is ERC20, AccessControl, IRealT {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _mint(address(this), 18 * 1000 * 1000 ether);
    }

    function batchTransfer(
        address[] calldata recipient,
        uint256[] calldata amount
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            recipient.length == amount.length,
            "recipient and amount must have same length"
        );

        require(recipient.length > 0, "can't process empty array");

        for (uint256 index = 0; index < recipient.length; index++) {
            _transfer(address(this), recipient[index], amount[index]);
        }
    }

    function contractTransfer(address recipient, uint256 amount) external override onlyRole(DEFAULT_ADMIN_ROLE) {
         _transfer(address(this), recipient, amount);
    }

    function mint(address account, uint256 amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _mint(account, amount);
    }

    function batchMint(address[] calldata account, uint256[] calldata amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            account.length == amount.length,
            "Account & amount length mismatch"
        );

        require(account.length > 0, "can't process empty array");

        for (uint256 index = 0; index < account.length; index++) {
            _mint(account[index], amount[index]);
        }
    }

    function burn(address account, uint256 amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        return _burn(account, amount);
    }

    function batchBurn(address[] calldata account, uint256[] calldata amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            account.length == amount.length,
            "Account & amount length mismatch"
        );
        require(account.length > 0, "can't process empty array");

        for (uint256 index = 0; index < account.length; index++) {
            _burn(account[index], amount[index]);
        }
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(tokenAddress).transfer(_msgSender(), tokenAmount);
    }
}
