//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./ACPI1.sol";
import "./ACPI2.sol";
import "./ACPI3.sol";
import "./ACPI4.sol";
import "./IACPIMaster.sol";

/// @title ACPIMaster contract
/// @author Bastien Silhol @ Realt.co ~ github.com/chichke
/// @dev ACPIMaster manage 4 children's acpi contracts
contract ACPIMaster is IACPIMaster, AccessControl {
    using SafeERC20 for IERC20;

    uint8 private _currentACPI;

    ACPI private _acpiOne;
    ACPI private _acpiTwo;
    ACPI private _acpiThree;
    ACPI private _acpiFour;

    uint256 private _initialTokenPrice;
    uint256 private _crossChainPrice;
    uint256 private _crossChainPriceUSD;

    bytes32 private constant _ACPI_MODERATOR = keccak256("ACPI_MODERATOR");
    bytes32 private constant _ACPI_MASTER = keccak256("ACPI_MASTER");

    IERC20 private _regToken;

    constructor(address regTokenAddress, address admin, address moderator) {
        _setupRole(_ACPI_MODERATOR, moderator);
        _setupRole(_ACPI_MASTER, address(this));
        _setupRole(DEFAULT_ADMIN_ROLE, admin);

        _regToken = IERC20(regTokenAddress);
    }

    /// @inheritdoc IACPIMaster
    function tokenContract() external view override returns (address) {
        return address(_regToken);
    }

    /// @inheritdoc IACPIMaster
    function acpiOneContract() external view override returns (address) {
        return address(_acpiOne);
    }

    /// @inheritdoc IACPIMaster
    function acpiTwoContract() external view override returns (address) {
        return address(_acpiTwo);
    }

    /// @inheritdoc IACPIMaster
    function acpiThreeContract() external view override returns (address) {
        return address(_acpiThree);
    }

    /// @inheritdoc IACPIMaster
    function acpiFourContract() external view override returns (address) {
        return address(_acpiFour);
    }

    /// @inheritdoc IACPIMaster
    function ACPI_MODERATOR() external pure override returns (bytes32) {
        return _ACPI_MODERATOR;
    }

    /// @inheritdoc IACPIMaster
    function ACPI_MASTER() external pure override returns (bytes32) {
        return _ACPI_MASTER;
    }

    /// @inheritdoc IACPIMaster
    function initialTokenPrice() external view override returns (uint256) {
        return _initialTokenPrice;
    }

    /// @inheritdoc IACPIMaster
    function crossChainPriceUSD() external view override returns (uint256) {
        return _crossChainPriceUSD;
    }

    /// @inheritdoc IACPIMaster
    function crossChainPrice() external view override returns (uint256) {
        return _crossChainPrice;
    }

    /// @inheritdoc IACPIMaster
    function getACPI() external view override returns (uint8) {
        return _currentACPI;
    }

    /// @inheritdoc IACPIMaster
    function generateCrossChainPrice(uint256 crossChainPrice_, uint256 crossChainPriceUSD_)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        require(
            _currentACPI == 5,
            "ACPI event need to be over to set cross chain price"
        );

        _crossChainPrice = crossChainPrice_;
        _crossChainPriceUSD = crossChainPriceUSD_;
        emit CrossChainPrice(crossChainPrice_, crossChainPriceUSD_);
        return true;
    }

    /// @inheritdoc IACPIMaster
    function totalWins() external override view returns (uint256) {
        return
            _acpiOne.totalWins() +
            _acpiTwo.totalWins() +
            _acpiThree.totalWins() +
            _acpiFour.totalWins();
    }

    /// @inheritdoc IACPIMaster
    function totalReturns() external override view returns (uint256) {
        return _acpiOne.totalReturns();
    }

    function _generatePrice() private {
        _initialTokenPrice =
            (((_acpiOne.acpiPrice() * 15) / 100)) +
            (((_acpiTwo.acpiPrice() * 25) / 100)) +
            (((_acpiThree.acpiPrice() * 35) / 100)) +
            (((_acpiFour.acpiPrice() * 25) / 100));

        emit GeneratedPrice(_initialTokenPrice);
    }

    /// @inheritdoc IACPIMaster
    function setACPI(uint8 newACPI)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        require(newACPI < 7, "Allowed value is 0-6");
        _currentACPI = newACPI;
        
        if (newACPI == 1) _acpiOne.setRoundStartedAt(block.timestamp); 
        if (newACPI == 2) _acpiTwo.setRoundStartedAt(block.timestamp); 
        if (newACPI == 3) _acpiThree.setRoundStartedAt(block.timestamp); 
        if (newACPI == 4) _acpiFour.setRoundStartedAt(block.timestamp); 

        if (newACPI == 5) {
            _generatePrice();
        }

        emit ACPIChanged(newACPI);

        return true;
    }

    function _getACPIWins(address account) private view returns (uint256) {
        return
            _acpiOne.pendingWins(account) +
            _acpiTwo.pendingWins(account) +
            _acpiThree.pendingWins(account) +
            _acpiFour.pendingWins(account);
    }

    /// @inheritdoc IACPIMaster
    function getACPIWins() external view override returns (uint256) {
        return _getACPIWins(_msgSender());
    }

    function _getACPIReturns(address account) private view returns (uint256) {
        return _acpiOne.pendingReturns(account);
    }

    /// @inheritdoc IACPIMaster
    function getACPIReturns() external view override returns (uint256) {
        return _getACPIReturns(_msgSender());
    }

    function _tokenToClaim() private view returns (uint256) {
        require(
            _currentACPI == 6,
            "ACPI event need to be over to claim your tokens"
        );

        uint256 userReturns = _getACPIReturns(_msgSender());
        uint256 userWins = _getACPIWins(_msgSender());

        if (userReturns == 0 && userWins == 0) return 0;

        return userWins + (1 ether * userReturns) / _crossChainPrice;
    }

    /// @inheritdoc IACPIMaster
    function tokenToClaim() external view override returns (uint256) {
        return _tokenToClaim();
    }

    /// @inheritdoc IACPIMaster
    function claimTokens() external override returns (bool) {
        uint256 tokenAmount = _tokenToClaim();
        require(tokenAmount > 0, "You don't have any tokens to claim");

        (
            bool successOne,
            bool successTwo,
            bool successThree,
            bool successFour
        ) = (
                _acpiOne.resetAccount(_msgSender()),
                _acpiTwo.resetAccount(_msgSender()),
                _acpiThree.resetAccount(_msgSender()),
                _acpiFour.resetAccount(_msgSender())
            );

        require(successOne && successTwo && successThree && successFour, "Reset function must not fail");

        _regToken.safeTransfer(_msgSender(), tokenAmount);
        return true;
    }

    /// @inheritdoc IACPIMaster
    function withdrawTokens(address payable vault, uint256 amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _regToken.safeTransfer(vault, amount);
        return true;
    }

    /// @inheritdoc IACPIMaster
    function withdraw(address payable vault, uint256[4] calldata amounts)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _acpiOne.withdraw(vault, amounts[0]);
        _acpiTwo.withdraw(vault, amounts[1]);
        _acpiThree.withdraw(vault, amounts[2]);
        _acpiFour.withdraw(vault, amounts[3]);

        return true;
    }

    /// @inheritdoc IACPIMaster
    function withdrawAll(address payable vault)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _acpiOne.withdraw(vault, address(_acpiOne).balance);
        _acpiTwo.withdraw(vault, address(_acpiTwo).balance);
        _acpiThree.withdraw(vault, address(_acpiThree).balance);
        _acpiFour.withdraw(vault, address(_acpiFour).balance);

        return true;
    }

    /// @inheritdoc IACPIMaster
    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        IERC20(tokenAddress).safeTransfer(_msgSender(), tokenAmount);
        return true;
    }

    /// @inheritdoc IACPIMaster
    function setTokenAddress(address tokenAddress)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _regToken = IERC20(tokenAddress);
        return true;
    }

    /// @inheritdoc IACPIMaster
    function setACPIOne(address acpiAddress)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _acpiOne = ACPI(acpiAddress);
        return true;
    }

    /// @inheritdoc IACPIMaster
    function setACPITwo(address acpiAddress)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _acpiTwo = ACPI(acpiAddress);
        return true;
    }

    /// @inheritdoc IACPIMaster
    function setACPIThree(address acpiAddress)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _acpiThree = ACPI(acpiAddress);
        return true;
    }

    /// @inheritdoc IACPIMaster
    function setACPIFour(address acpiAddress)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _acpiFour = ACPI(acpiAddress);
        return true;
    }
}
