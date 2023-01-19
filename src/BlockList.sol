// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

/**
    ____        _ __    __   ____  _ ________                     __ 
   / __ )__  __(_) /___/ /  / __ \(_) __/ __/__  ________  ____  / /_
  / __  / / / / / / __  /  / / / / / /_/ /_/ _ \/ ___/ _ \/ __ \/ __/
 / /_/ / /_/ / / / /_/ /  / /_/ / / __/ __/  __/ /  /  __/ / / / /_  
/_____/\__,_/_/_/\__,_/  /_____/_/_/ /_/  \___/_/   \___/_/ /_/\__/  
                                                                    
*/

import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {OwnableAccessControlUpgradeable} from "tl-sol-tools/upgradeable/access/OwnableAccessControlUpgradeable.sol";
import {IBlockListRegistry} from "./IBlockListRegistry.sol";

/// @title BlockList
/// @notice abstract contract that can be inherited to block
///         approvals from non-royalty paying marketplaces
/// @author transientlabs.xyz
abstract contract BlockList is Initializable, OwnableAccessControlUpgradeable {

    /*//////////////////////////////////////////////////////////////////////////
                                Public State Variables
    //////////////////////////////////////////////////////////////////////////*/

    IBlockListRegistry public blockListRegistry;

    /*//////////////////////////////////////////////////////////////////////////
                                Events
    //////////////////////////////////////////////////////////////////////////*/

    event BlockListRegistryUpdated(
        address indexed oldRegistry,
        address indexed newRegistry
    );

    /*//////////////////////////////////////////////////////////////////////////
                                Custom Errors
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev blocked operator error
    error BlockedOperator();

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
                                Initializer
    //////////////////////////////////////////////////////////////////////////*/
    
    function __BlockList_init(address blockListRegistryAddr)
        internal
        onlyInitializing
    {
        blockListRegistry = IBlockListRegistry(blockListRegistryAddr);
    }

    /*//////////////////////////////////////////////////////////////////////////
                            Admin Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice function to transfer ownership of the blockList
    /// @dev requires blockList owner
    /// @dev can be transferred to the ZERO_ADDRESS if desired
    /// @dev BE VERY CAREFUL USING THIS
    function updateBlockListRegistry(address newBlockListRegistry)
        public
        onlyOwner
    {
        blockListRegistry = IBlockListRegistry(newBlockListRegistry);
    }

    /*//////////////////////////////////////////////////////////////////////////
                          Public Read Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice function to get blocklist status with True meaning that the operator is blocked
    function getBlockListStatus(address operator) public view returns (bool) {
        try blockListRegistry.getBlockListStatus(operator) returns (bool isBlocked) {
          return isBlocked;
        } catch {
          return false;
        }
    }
}
