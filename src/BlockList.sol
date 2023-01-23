// SPDX-License-Identifier: Apache-2.0

pragma solidity 0.8.17;

/// @title BlockList
/// @author transientlabs.xyz

/**
 *     ____        _ __    __   ____  _ ________                     __
 *    / __ )__  __(_) /___/ /  / __ \(_) __/ __/__  ________  ____  / /_
 *   / __  / / / / / / __  /  / / / / / /_/ /_/ _ \/ ___/ _ \/ __ \/ __/
 *  / /_/ / /_/ / / / /_/ /  / /_/ / / __/ __/  __/ /  /  __/ / / / /_
 * /_____/\__,_/_/_/\__,_/  /_____/_/_/ /_/  \___/_/   \___/_/ /_/\__/
 */

import {IBlockListRegistry} from "./IBlockListRegistry.sol";

/// @notice abstract contract that can be inherited to block
///         approvals from non-royalty paying marketplaces
abstract contract BlockList {
    /*//////////////////////////////////////////////////////////////////////////
                                Public State Variables
    //////////////////////////////////////////////////////////////////////////*/

    IBlockListRegistry public blockListRegistry;

    /*//////////////////////////////////////////////////////////////////////////
                                Events
    //////////////////////////////////////////////////////////////////////////*/

    event BlockListRegistryUpdated(address indexed caller, address indexed oldRegistry, address indexed newRegistry);

    /*//////////////////////////////////////////////////////////////////////////
                                Modifiers
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev modifier that can be applied to approval functions in order to block listings on marketplaces
    modifier notBlocked(address operator) {
        if (getBlockListStatus(operator)) {
            revert BlockedOperator();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Constructor
    //////////////////////////////////////////////////////////////////////////*/

    /// @param blockListRegistryAddr - the initial BlockList Registry Address
    constructor(address blockListRegistryAddr) {
        blockListRegistry = IBlockListRegistry(blockListRegistryAddr);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Admin Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice function to transfer ownership of the blockList
    /// @dev requires blockList admin
    /// @dev can be transferred to the ZERO_ADDRESS if desired
    /// @dev BE VERY CAREFUL USING THIS
    /// @param newBlockListRegistry - the address of the new BlockList registry
    function updateBlockListRegistry(address newBlockListRegistry) public {
        if (!isBlockListAdmin(msg.sender)) revert Unauthorized();

        address oldRegistry = address(blockListRegistry);
        blockListRegistry = IBlockListRegistry(newBlockListRegistry);
        emit BlockListRegistryUpdated(msg.sender, oldRegistry, newBlockListRegistry);
    }

    /*//////////////////////////////////////////////////////////////////////////
                          Public Read Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice function to get blocklist status with True meaning that the operator is blocked
    /// @param operator - operator to check against for blocking
    function getBlockListStatus(address operator) public view returns (bool) {
        try blockListRegistry.getBlockListStatus(operator) returns (bool isBlocked) {
            return isBlocked;
        } catch {
            return false;
        }
    }

    /// @notice Abstract function to determine if an address is a blocklist admin.
    /// @param potentialAdmin - the potential admin address to check
    function isBlockListAdmin(address potentialAdmin) public view virtual returns (bool);
}

/*//////////////////////////////////////////////////////////////////////////
                                Custom Errors
//////////////////////////////////////////////////////////////////////////*/

/// @dev blocked operator error
error BlockedOperator();

/// @dev unauthorized to call fn method
error Unauthorized();
