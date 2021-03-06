//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./IREG.sol";

/// @title Real Estate Governance Token
/// @author Bastien Silhol @ Realt.co ~ github.com/chichke
/// @notice REG DAO utility token
/// @dev UUPS Proxy contract to fix or implement new functionality
contract REG is UUPSUpgradeable, ERC20VotesUpgradeable, AccessControlUpgradeable, IREG {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /// @dev Initialize function called by the ERC1967 Proxy constructor
    /// @param name string - name of the token
    /// @param symbol string - symbol of the token
    /// @param admin address - that will be granted the {DEFAULT_ADMIN_ROLE}
    function initialize(string memory name, string memory symbol, address admin) external onlyProxy initializer
    {
        __AccessControl_init();
        __ERC20_init(name, symbol);
        __ERC20Permit_init(name);
        __UUPSUpgradeable_init();
        __ERC20Votes_init_unchained();
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function _authorizeUpgrade(address newImplementation) internal view override {
        _checkRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }


    /// @inheritdoc IREG
    function mint(address account, uint256 amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _mint(account, amount);
        return true;
    }

    /// @inheritdoc IREG
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

    /// @inheritdoc IREG
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


    /// @inheritdoc IREG
    function contractBurn(uint256 amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _burn(address(this), amount);
        return true;
    }

    /// @inheritdoc IREG
    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        IERC20Upgradeable(tokenAddress).safeTransfer(_msgSender(), tokenAmount);
        return true;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20VotesUpgradeable) {
        super._afterTokenTransfer(from, to, amount);
        if (delegates(to) == address(0))
            _delegate(to, to);
    }

}
