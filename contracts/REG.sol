//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./IREG.sol";

// github.com/chichke

contract REG is ERC20Votes, AccessControl, IREG {
    using SafeERC20 for IERC20;

    constructor(string memory name, string memory symbol, address admin)
        ERC20(name, symbol)
        ERC20Permit(name)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function mint(address account, uint256 amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _mint(account, amount);
        return true;
    }

    function batchTransfer(
        address[] calldata recipient,
        uint256[] calldata amount
    ) external override returns (bool) {
        require(
            recipient.length == amount.length,
            "recipient and amount must have same length"
        );

        require(recipient.length > 0, "can't process empty array");

        for (uint256 index = 0; index < recipient.length; index++) {
            _transfer(_msgSender(), recipient[index], amount[index]);
        }
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
            _mint(account[index], amount[index]);
        }
        return true;
    }

    function contractBurn(uint256 amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _burn(address(this), amount);
        return true;
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        IERC20(tokenAddress).safeTransfer(_msgSender(), tokenAmount);
        return true;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
        if (delegates(to) == address(0))
            _delegate(to, to);
    }

}
