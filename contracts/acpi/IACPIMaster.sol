//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/IAccessControl.sol";

/// @title Interface of the ACPIMaster contract
/// @author Bastien Silhol @ Realt.co ~ github.com/chichke
/// @dev ACPIMaster manage 4 children's acpi contracts
interface IACPIMaster is IAccessControl {
    /**
     * @dev Emitted when admin input other chains price to calculate crosschainprice
     */
    event CrossChainPrice(uint256 indexed crossChainPrice, uint256 indexed crossChainPriceUSD);

    /**
     * @dev Emitted when acpi ends and contract calculate ACPI price
     */
    event GeneratedPrice(uint256 indexed price);

    /**
     * @dev Emitted when acpi changes
     */
    event ACPIChanged(uint8 indexed newAcpi);

    /**
     * @dev Retrieve the REG contract address
     */
    function tokenContract() external view returns (address);

    /**
     * @dev Retrieve the acpi one contract address
     */
    function acpiOneContract() external view returns (address);

    /**
     * @dev Retrieve the acpi two contract address
     */
    function acpiTwoContract() external view returns (address);

    /**
     * @dev Retrieve the acpi tree contract address
     */
    function acpiThreeContract() external view returns (address);

    /**
     * @dev Retrieve the acpi four contract address
     */
    function acpiFourContract() external view returns (address);

    /**
     * @dev Retrieve the ACPI_MASTER role
     */
    function ACPI_MASTER() external view returns (bytes32);

    /**
     * @dev Retrieve the ACPI_MODERATOR role
     */
    function ACPI_MODERATOR() external view returns (bytes32);

    /**
     * @dev Retrieve the initialTokenPrice
     */
    function initialTokenPrice() external view returns (uint256);

    /**
     * @dev Retrieve the crossChainPrice
     */
    function crossChainPrice() external view returns (uint256);

    /**
     * @dev Retrieve the crossChainPriceUSD
     */
    function crossChainPriceUSD() external view returns (uint256);

    /**
     * @notice Retrieve the acpiNumber
     */
    function getACPI() external view returns (uint8);

    /**
     * @notice Generate average price of ACPIs using the initialTokenPrice on three differents blockchains
     * @param crossChainPrice_ Adjusted Price on all chains in blockchain native currency
     * @param crossChainPriceUSD_ Average Price on all chains in $
     * @dev Emits a {CrossChainPrice} event.
     */
    function generateCrossChainPrice(uint256 crossChainPrice_, uint256 crossChainPriceUSD_) external returns (bool);

    /**
     * @notice setACPI, set current ACPI
     * - require {DEFAULT_ADMIN_ROLE}
     * @param newACPI uint8 - Possible value 0-6 included
     * @dev Emits a {ACPIChanged} event.
     * acpiNumber is 0 before ACPI start
     * acpiNumber is 1 on phase 1
     * acpiNumber is 2 on phase 2
     * acpiNumber is 3 on phase 3
     * acpiNumber is 4 on phase 4
     * acpiNumber is 5 when ACPI ends, REG Token price will then be calculated
     * acpiNumber is 6 when users will be able to claim their REG token
     * @return true on success
     */
    function setACPI(uint8 newACPI) external returns (bool);

    /**
     * @dev Retrieve the acpi wins (REG) for caller's address
     */
    function getACPIWins() external view returns (uint256);

    /**
     * @dev Retrieve the acpi returns (REG) for caller's address
     */
    function getACPIReturns() external view returns (uint256);

    /**
     * @dev Retrieve the sum of acpi wins (REG) amongst all the users
     */
    function totalWins() external view returns (uint256);

    /**
     * @dev Retrieve the sum of acpi returns (REG) amongst all the users
     */
    function totalReturns() external view returns (uint256);
    
    /**
     * @dev Retrieve the amount of (REG) caller's address can claim
     */
    function tokenToClaim() external view returns (uint256);

    /**
     * @dev Transfer claimable (REG) from contract to caller's address
     * @return true on success
     */
    function claimTokens() external returns (bool);

    /**
     * @dev Transfer left over (REG) from contract to vault address
     * - require {DEFAULT_ADMIN_ROLE}
     * @param vault address that will receive the tokens
     * @param amount uint256 received by the vault address
     * @return true on success
     */
    function withdrawTokens(address payable vault, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Transfer all the native coin from acpis contract to vault address
     * - require {DEFAULT_ADMIN_ROLE}
     * @param vault address that will receive the native coin
     * @return true on success
     */
    function withdrawAll(address payable vault)
        external
        returns (bool);

    /**
     * @dev Transfer all the native coin from acpis contract to vault address
     * - require {DEFAULT_ADMIN_ROLE}
     * @param vault address that will receive the native coin
     * @param amounts uint256[4], amount[n] withdraw from acpi n + 1 contract, 
     * @return true on success
     */
    function withdraw(address payable vault, uint256[4] calldata amounts)
        external
        returns (bool);

     /**
     * @dev Retrieve ERC20 tokens sent by mistake to the contract
     * - require {DEFAULT_ADMIN_ROLE}s
     * @param tokenAddress address that will receive the native coin
     * @param tokenAmount uint256, token amount from
     * @return true on success
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external returns (bool);

    /**
     * @dev Set REG token contract address
     * - require {DEFAULT_ADMIN_ROLE}
     * @param tokenAddress new address where an ERC20 contract is deployed 
     * @return true on success
     */
    function setTokenAddress(address tokenAddress) external returns (bool);

    /**
     * @dev Set ACPI 1 contract address
     * - require {DEFAULT_ADMIN_ROLE}
     * @param acpiAddress new address where an {ACPI} contract is deployed 
     * @return true on success
     */
    function setACPIOne(address acpiAddress) external returns (bool);

    /**
     * @dev Set ACPI 2 contract address
     * - require {DEFAULT_ADMIN_ROLE}
     * @param acpiAddress new address where an {ACPI} contract is deployed 
     * @return true on success
     */
    function setACPITwo(address acpiAddress) external returns (bool);

    /**
     * @dev Set ACPI 3 contract address
     * - require {DEFAULT_ADMIN_ROLE}
     * @param acpiAddress new address where an {ACPI} contract is deployed 
     * @return true on success
     */
    function setACPIThree(address acpiAddress) external returns (bool);

    /**
     * @dev Set ACPI 4 contract address
     * - require {DEFAULT_ADMIN_ROLE}
     * @param acpiAddress new address where an {ACPI} contract is deployed 
     * @return true on success
     */
    function setACPIFour(address acpiAddress) external returns (bool);
}
