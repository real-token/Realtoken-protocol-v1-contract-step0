//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ACPI1.sol";
import "./ACPI2.sol";
import "./ACPI3.sol";
import "./ACPI4.sol";

// @ made by github.com/@chichke

contract RealT is ERC20, AccessControl {
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

    uint256 public initialTokenPrice;

    bytes32 public constant TOKEN_ADMIN = keccak256("TOKEN_ADMIN");
    bytes32 public constant ACPI_MODERATOR = keccak256("ACPI_MODERATOR");
    bytes32 public constant ACPI_CONTRACT = keccak256("ACPI_CONTRACT");
    bytes32 public constant TOKEN_CONTRACT = keccak256("TOKEN_CONTRACT");

    constructor(
        string memory name,
        string memory symbol,
        address acpiModerator
    ) ERC20(name, symbol) {
        _setupRole(TOKEN_ADMIN, msg.sender);

        acpiOne = new ACPIOne();
        acpiTwo = new ACPITwo();
        acpiThree = new ACPIThree();
        acpiFour = new ACPIFour();

        _setupRole(ACPI_MODERATOR, acpiModerator);

        _setupRole(ACPI_CONTRACT, address(acpiOne));
        _setupRole(ACPI_CONTRACT, address(acpiTwo));
        _setupRole(ACPI_CONTRACT, address(acpiThree));
        _setupRole(ACPI_CONTRACT, address(acpiFour));

        _setupRole(TOKEN_CONTRACT, address(this));

        _mint(address(this), 18 * 1000 * 1000 ether);
    }

    function getACPI() external view returns (uint8) {
        return _currentACPI;
    }

    function setACPI(uint8 currentACPI) external onlyRole(TOKEN_ADMIN) {
        require(currentACPI < 6, "Allowed value is 0-5");
        _currentACPI = currentACPI;
        if (currentACPI == 5) {
            initialTokenPrice =
                acpiOne.acpiPrice() +
                acpiTwo.acpiPrice() +
                acpiThree.acpiPrice() +
                acpiFour.acpiPrice();
        }
    }

    function batchTransfer(
        address[] calldata sender,
        address[] calldata recipient,
        uint256[] calldata amount
    ) external onlyRole(TOKEN_ADMIN) {
        require(
            sender.length == recipient.length &&
                recipient.length == amount.length,
            "sender, recipient and amount must have same length"
        );

        require(sender.length > 0, "can't process empty array");

        for (uint256 index; index < sender.length; index++) {
            _transfer(sender[index], recipient[index], amount[index]);
        }
    }

    function mint(address account, uint256 amount)
        external
        onlyRole(TOKEN_ADMIN)
    {
        _mint(account, amount);
    }

    function batchMint(address[] calldata account, uint256[] calldata amount)
        external
        onlyRole(TOKEN_ADMIN)
    {
        require(
            account.length == amount.length,
            "Account & amount length mismatch"
        );

        require(account.length > 0, "can't process empty array");

        for (uint256 index; index < account.length; index++) {
            _mint(account[index], amount[index]);
        }
    }

    function burn(address account, uint256 amount)
        external
        onlyRole(TOKEN_ADMIN)
    {
        return _burn(account, amount);
    }

    function batchBurn(address[] calldata account, uint256[] calldata amount)
        external
        onlyRole(TOKEN_ADMIN)
    {
        require(
            account.length == amount.length,
            "Account & amount length mismatch"
        );
        require(account.length > 0, "can't process empty array");

        for (uint256 index; index < account.length; index++) {
            _burn(account[index], amount[index]);
        }
    }

    function _getACPIWins(address account) internal view returns (uint256) {
        return
            acpiOne.pendingWins(account) +
            acpiTwo.pendingWins(account) +
            acpiThree.pendingWins(account) +
            acpiFour.pendingWins(account);
    }

    function getACPIWins() external view returns (uint256) {
        return _getACPIWins(msg.sender);
    }

    function _getACPIReturns(address account) internal view returns (uint256) {
        return
            acpiOne.pendingReturns(account) +
            acpiTwo.pendingReturns(account) +
            acpiFour.pendingReturns(account);
    }

    function getACPIReturns() external view returns (uint256) {
        return _getACPIReturns(msg.sender);
    }

    function claimTokens() external {
        require(
            _currentACPI == 5,
            "ACPI phase need to be over to claim your token"
        );

        uint256 totalReturns = _getACPIReturns(msg.sender);
        uint256 totalWins = _getACPIWins(msg.sender);

        require(totalReturns > 0 || totalWins > 0);

        acpiOne.resetAccount(msg.sender);
        acpiTwo.resetAccount(msg.sender);
        acpiThree.resetAccount(msg.sender);
        acpiFour.resetAccount(msg.sender);

        _transfer(
            address(this),
            msg.sender,
            totalWins + totalReturns / initialTokenPrice
        );
    }

    function withdraw(address vault) external onlyRole(TOKEN_ADMIN) {
        acpiOne.withdraw(vault);
        acpiTwo.withdraw(vault);
        acpiThree.withdraw(vault);
        acpiFour.withdraw(vault);
    }
}
