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

    ACPIOne public acpiOne;
    ACPITwo public acpiTwo;
    ACPIThree public acpiThree;
    ACPIFour public acpiFour;

    uint256 private _initialTokenPrice;

    bytes32 private constant _ACPI_MODERATOR = keccak256("ACPI_MODERATOR");
    bytes32 private constant _ACPI_MASTER = keccak256("ACPI_MASTER");

    IRealT public realToken;

    constructor(address _realToken, address acpiModerator) {
        _setupRole(_ACPI_MODERATOR, acpiModerator);
        _setupRole(_ACPI_MASTER, address(this));
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        realToken = IRealT(_realToken);
        acpiOne = new ACPIOne();
        acpiTwo = new ACPITwo();
        acpiThree = new ACPIThree();
        acpiFour = new ACPIFour();
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
            (((acpiOne.acpiPrice() * 15) / 100)) +
            (((acpiTwo.acpiPrice() * 25) / 100)) +
            (((acpiThree.acpiPrice() * 35) / 100)) +
            (((acpiFour.acpiPrice() * 25) / 100));
    }

    function setACPI(uint8 newACPI)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(newACPI < 6, "Allowed value is 0-5");
        _currentACPI = newACPI;
        if (newACPI == 5) {
            _generatePrice();
        }

        emit ACPIChanged(newACPI);
    }

    function _getACPIWins(address account) private view returns (uint256) {
        return
            acpiOne.pendingWins(account) +
            acpiTwo.pendingWins(account) +
            acpiThree.pendingWins(account) +
            acpiFour.pendingWins(account);
    }

    function getACPIWins() external view override returns (uint256) {
        return _getACPIWins(_msgSender());
    }

    function _getACPIReturns(address account) private view returns (uint256) {
        return acpiOne.pendingReturns(account);
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

    function claimTokens() external override {
        uint256 tokenAmount = _tokenToClaim();

        // TODO Check for reentrency

        require(tokenAmount > 0, "You don't have any tokens to claim");

        acpiOne.resetAccount(_msgSender());
        acpiTwo.resetAccount(_msgSender());
        acpiThree.resetAccount(_msgSender());
        acpiFour.resetAccount(_msgSender());

        realToken.transfer(_msgSender(), tokenAmount);
    }

    function withdrawAll(address vault)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        acpiOne.withdraw(vault, address(acpiOne).balance);
        acpiTwo.withdraw(vault, address(acpiTwo).balance);
        acpiThree.withdraw(vault, address(acpiThree).balance);
        acpiFour.withdraw(vault, address(acpiFour).balance);
    }

    function withdrawTokens(address vault, uint256 amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        realToken.transfer(vault, amount);
    }

    function withdraw(address vault, uint256[4] calldata amounts)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        acpiOne.withdraw(vault, amounts[0]);
        acpiTwo.withdraw(vault, amounts[1]);
        acpiThree.withdraw(vault, amounts[2]);
        acpiFour.withdraw(vault, amounts[3]);
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(tokenAddress).transfer(_msgSender(), tokenAmount);
    }
}
