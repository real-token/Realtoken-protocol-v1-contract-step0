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

    uint256 private _initialTokenPrice;

    bytes32 public constant ACPI_MODERATOR = keccak256("ACPI_MODERATOR");
    bytes32 public constant ACPI_CONTRACT = keccak256("ACPI_CONTRACT");
    bytes32 public constant TOKEN_CONTRACT = keccak256("TOKEN_CONTRACT");

    constructor(
        string memory name,
        string memory symbol,
        address acpiModerator
    ) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

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

    function initialTokenPrice() external view returns (uint256) {
        return _initialTokenPrice;
    }

    function getACPI() external view returns (uint8) {
        return _currentACPI;
    }

    function _generatePrice() private {
        _initialTokenPrice =
            (((acpiOne.acpiPrice() * 15) / 100)) +
            (((acpiTwo.acpiPrice() * 25) / 100)) +
            (((acpiThree.acpiPrice() * 35) / 100)) +
            (((acpiFour.acpiPrice() * 25) / 100));

        // TODO Emit event
    }

    function setACPI(uint8 newACPI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newACPI < 6, "Allowed value is 0-5");
        _currentACPI = newACPI;
        if (newACPI == 5) {
            _generatePrice();
        }
    }

    function batchTransfer(
        address[] calldata sender,
        address[] calldata recipient,
        uint256[] calldata amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            sender.length == recipient.length &&
                recipient.length == amount.length,
            "sender, recipient and amount must have same length"
        );

        require(sender.length > 0, "can't process empty array");

        for (uint256 index = 0; index < sender.length; index++) {
            _transfer(sender[index], recipient[index], amount[index]);
        }
    }

    function mint(address account, uint256 amount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _mint(account, amount);
    }

    function batchMint(address[] calldata account, uint256[] calldata amount)
        external
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
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        return _burn(account, amount);
    }

    function batchBurn(address[] calldata account, uint256[] calldata amount)
        external
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

    function _getACPIWins(address account) private view returns (uint256) {
        return
            acpiOne.pendingWins(account) +
            acpiTwo.pendingWins(account) +
            acpiThree.pendingWins(account) +
            acpiFour.pendingWins(account);
    }

    function getACPIWins() external view returns (uint256) {
        return _getACPIWins(msg.sender);
    }

    function _getACPIReturns(address account) private view returns (uint256) {
        uint256 pendingReturns = acpiOne.pendingReturns(account);

        // TODO Gotta be better than this
        return pendingReturns;
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

        // TODO Check for reentrency

        require(
            totalReturns > 0 || totalWins > 0,
            "You don't have any tokens to claim"
        );

        // TODO Check if totalReturns > initialTokenPrice
        _transfer(
            address(this),
            msg.sender,
            totalWins + totalReturns / _initialTokenPrice
        );

        acpiOne.resetAccount(msg.sender);
        acpiTwo.resetAccount(msg.sender);
        acpiThree.resetAccount(msg.sender);
        acpiFour.resetAccount(msg.sender);
    }

    function withdraw(address vault) external onlyRole(DEFAULT_ADMIN_ROLE) {
        acpiOne.withdraw(vault);
        acpiTwo.withdraw(vault);
        acpiThree.withdraw(vault);
        acpiFour.withdraw(vault);
    }
}
