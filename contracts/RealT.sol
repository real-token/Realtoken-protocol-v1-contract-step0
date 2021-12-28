//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IRealT.sol";

// github.com/chichke

contract RealT is ERC20, ERC20Permit, ERC20Votes, AccessControl, IRealT {
    constructor(string memory name, string memory symbol)
        ERC20(name, symbol)
        ERC20Permit(name)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _mint(address(this), 17716752 ether);
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
            super._transfer(_msgSender(), recipient[index], amount[index]);
        }
        return true;
    }

    function contractTransfer(address recipient, uint256 amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _transfer(address(this), recipient, amount);
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
        return IERC20(tokenAddress).transfer(_msgSender(), tokenAmount);
    }

    /**
     * @dev Withdraw native currency {DEFAULT_ADMIN_ROLE}
     */
    function withdraw(address payable recipient, uint256 amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        require(recipient != address(0), "Can't burn token");

        recipient.transfer(amount);
        return true;
    }

    // The functions below are overrides required by Solidity.
    function _mint(address _to, uint256 _amount) internal override(ERC20, ERC20Votes) {
        super._mint(_to, _amount);
    }

    function _burn(address _account, uint256 _amount) internal override(ERC20, ERC20Votes) {
        super._burn(_account, _amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
         _delegate(to, to);
    }

}
