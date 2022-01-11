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

// github.com/chichke

contract ACPIMaster is IACPIMaster, AccessControl {
    using SafeERC20 for IERC20;

    /**
     * @dev currentACPI is 0 before ACPI start
     * @dev currentACPI is 1 on phase 1
     * @dev currentACPI is 2 on phase 2
     * @dev currentACPI is 3 on phase 3
     * @dev currentACPI is 4 on phase 4
     * @dev currentACPI is 5 when ACPI ends, REG Token price will then be calculated
     */
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

    function tokenContract() external view override returns (address) {
        return address(_regToken);
    }

    function acpiOneContract() external view override returns (address) {
        return address(_acpiOne);
    }

    function acpiTwoContract() external view override returns (address) {
        return address(_acpiTwo);
    }

    function acpiThreeContract() external view override returns (address) {
        return address(_acpiThree);
    }

    function acpiFourContract() external view override returns (address) {
        return address(_acpiFour);
    }

    function ACPI_MODERATOR() external pure override returns (bytes32) {
        return _ACPI_MODERATOR;
    }

    function ACPI_MASTER() external pure override returns (bytes32) {
        return _ACPI_MASTER;
    }

    function initialTokenPrice() external view override returns (uint256) {
        return _initialTokenPrice;
    }

    function crossChainPriceUSD() external view override returns (uint256) {
        return _crossChainPriceUSD;
    }

    function crossChainPrice() external view override returns (uint256) {
        return _crossChainPrice;
    }

    function getACPI() external view override returns (uint8) {
        return _currentACPI;
    }

    // Generate average price of ACPIs using the initialTokenPrice on three differents blockchains
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

    function totalWins() external override view returns (uint256) {
        return
            _acpiOne.totalWins() +
            _acpiTwo.totalWins() +
            _acpiThree.totalWins() +
            _acpiFour.totalWins();
    }

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

    function setACPI(uint8 newACPI)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        require(newACPI < 7, "Allowed value is 0-6");
        _currentACPI = newACPI;
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

    function getACPIWins() external view override returns (uint256) {
        return _getACPIWins(_msgSender());
    }

    function _getACPIReturns(address account) private view returns (uint256) {
        return _acpiOne.pendingReturns(account);
    }

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

    function tokenToClaim() external view override returns (uint256) {
        return _tokenToClaim();
    }

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

    function withdrawTokens(address payable vault, uint256 amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _regToken.safeTransfer(vault, amount);
        return true;
    }

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

    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        IERC20(tokenAddress).safeTransfer(_msgSender(), tokenAmount);
        return true;
    }

    function setTokenAddress(address tokenAddress)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _regToken = IERC20(tokenAddress);
        return true;
    }

    function setACPIOne(address acpiAddress)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _acpiOne = ACPI(acpiAddress);
        return true;
    }

    function setACPITwo(address acpiAddress)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _acpiTwo = ACPI(acpiAddress);
        return true;
    }

    function setACPIThree(address acpiAddress)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        _acpiThree = ACPI(acpiAddress);
        return true;
    }

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
