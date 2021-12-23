//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IRealT.sol";

// @ made by github.com/@chichke

contract RealT is ERC20Votes, AccessControl, IRealT {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) ERC20Permit(name) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _mint(address(this), 1e18 ether);
    }

    function batchTransfer(
        address[] calldata recipient,
        uint256[] calldata amount
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        require(
            recipient.length == amount.length,
            "recipient and amount must have same length"
        );

        require(recipient.length > 0, "can't process empty array");

        for (uint256 index = 0; index < recipient.length; index++) {
            super._transfer(address(this), recipient[index], amount[index]);
        }
        return true;
    }

    function contractTransfer(address recipient, uint256 amount) external override onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
         super._transfer(address(this), recipient, amount);
         return true;
    }

    function mint(address account, uint256 amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        super._mint(account, amount);
        return true;
    }

    function batchMint(address[] calldata account, uint256[] calldata amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        require(
            account.length == amount.length,
            "Account & amount length mismatch"
        );

        require(account.length > 0, "can't process empty array");

        for (uint256 index = 0; index < account.length; index++) {
            super._mint(account[index], amount[index]);
        }
        return true;
    }

    function contractBurn(uint256 amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        super._burn(address(this), amount);
        return true;
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external override onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        IERC20(tokenAddress).transfer(_msgSender(), tokenAmount);
        return true;
    }
}
