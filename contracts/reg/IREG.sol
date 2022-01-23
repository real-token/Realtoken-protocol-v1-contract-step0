//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";


/// @title Interface of the Real Estate Governance Token
/// @author Bastien Silhol @ Realt.co ~ github.com/chichke
/// @notice REG DAO utility token
/// @dev UUPS Proxy contract to fix or implement new functionality

interface IREG is IERC20Upgradeable {
    /// @notice BatchTransfer, execute a lot of transfer in one transaction
    /// @param recipient recipient that will receive the amount associated to their index
    /// @param amount amount[0] will get received by recipient[0] and so on
    /// @return return true on success
    function batchTransfer(
        address[] calldata recipient,
        uint256[] calldata amount
    ) external returns (bool);

    /// @notice Mint function only ADMIN
    /// @dev Mint function
    /// - require {DEFAULT_ADMIN_ROLE}
    /// @param account address - account that will receive created funds
    /// @param amount amount to be minted
    /// @return return true on success
    function mint(address account, uint256 amount) external returns (bool);

    /// @notice BatchMint, execute a lot of mint in one transaction
    /// @dev Mint function
    /// - require {DEFAULT_ADMIN_ROLE}
    /// @param account recipient that will receive the amount associated to their index
    /// @param amount amount[0] will get received by recipient[0] and so on
    /// @return return true on success
    function batchMint(address[] calldata account, uint256[] calldata amount)
        external
        returns (bool);

    /// @notice ContractBurn, Burn tokens that are stored on the contract
    /// @dev Burn function
    /// - require {DEFAULT_ADMIN_ROLE}
    /// @param amount amount that will be burned on the contract
    /// @return return true on success
    function contractBurn(uint256 amount) external returns (bool);

    /// @notice RecoverERC20, Transfer any ERC20 stored on the contract to a wallet, prevent mistakes
    /// @dev recoverERC20 function
    /// - require {DEFAULT_ADMIN_ROLE}
    /// @param tokenAddress address - token address to transfer 
    /// @param tokenAmount token amount to be transfered
    /// @return return true on success
    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        returns (bool);

}
