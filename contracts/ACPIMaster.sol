//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ACPI1.sol";
import "./ACPI2.sol";
import "./ACPI3.sol";
import "./ACPI4.sol";
import "./IACPIMaster.sol";
import "./IRealT.sol";

contract ACPIMaster is IACPIMaster, AccessControl {
    /**
     * @dev currentACPI is 0 before ACPI start
     * @dev currentACPI is 1 on phase 1
     * @dev currentACPI is 2 on phase 2
     * @dev currentACPI is 3 on phase 3
     * @dev currentACPI is 4 on phase 4
     * @dev currentACPI is 5 when ACPI ends, Realt price will then be calculated
     */
    uint8 private _currentACPI;

    ACPIOne private _acpiOne;
    ACPITwo private _acpiTwo;
    ACPIThree private _acpiThree;
    ACPIFour private _acpiFour;

    uint256 private _initialTokenPrice;

    bytes32 private constant _ACPI_MODERATOR = keccak256("ACPI_MODERATOR");
    bytes32 private constant _ACPI_MASTER = keccak256("ACPI_MASTER");

    IRealT private _realToken;

    constructor(address realTokenAddress, address acpiModerator) {
        _setupRole(_ACPI_MODERATOR, acpiModerator);
        _setupRole(_ACPI_MASTER, address(this));
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _realToken = IRealT(realTokenAddress);
        _acpiOne = new ACPIOne();
        _acpiTwo = new ACPITwo();
        _acpiThree = new ACPIThree();
        _acpiFour = new ACPIFour();
    }

    function tokenContract() external view override returns (address) {
        return address(_realToken);
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

    function getACPI() external view override returns (uint8) {
        return _currentACPI;
    }

    function _generatePrice() private {
        _initialTokenPrice =
            (((_acpiOne.acpiPrice() * 15) / 100)) +
            (((_acpiTwo.acpiPrice() * 25) / 100)) +
            (((_acpiThree.acpiPrice() * 35) / 100)) +
            (((_acpiFour.acpiPrice() * 25) / 100));
    }

    function setACPI(uint8 newACPI)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        require(newACPI < 6, "Allowed value is 0-5");
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
            _currentACPI == 5,
            "ACPI event need to be over to claim your tokens"
        );

        uint256 totalReturns = _getACPIReturns(_msgSender());
        uint256 totalWins = _getACPIWins(_msgSender());

        if (totalReturns == 0 && totalWins == 0) return 0;

        return totalWins + (1 ether * totalReturns) / _initialTokenPrice;
    }

    function tokenToClaim() external view override returns (uint256) {
        return _tokenToClaim();
    }

    function claimTokens() external override returns (bool) {
        uint256 tokenAmount = _tokenToClaim();

        // TODO Check for reentrency

        require(tokenAmount > 0, "You don't have any tokens to claim");

        _acpiOne.resetAccount(_msgSender());
        _acpiTwo.resetAccount(_msgSender());
        _acpiThree.resetAccount(_msgSender());
        _acpiFour.resetAccount(_msgSender());

        return _realToken.transfer(_msgSender(), tokenAmount);
    }

    function withdrawTokens(address payable vault, uint256 amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        return _realToken.transfer(vault, amount);
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

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return IERC20(tokenAddress).transfer(_msgSender(), tokenAmount);
    }

    function setTokenAddress(address tokenAddress) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        _realToken = IRealT(tokenAddress);
        return true;
    }

}