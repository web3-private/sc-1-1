// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

import {TokenErrors0710} from "./interfaces/TokenErrors0710.sol";

contract TokenAccessControlUpgradeable is AccessControlEnumerableUpgradeable, TokenErrors0710 {
    using EnumerableSet for EnumerableSet.AddressSet;

    error UnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev Return all accounts that have `role`
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function getRoleMembers(bytes32 role) public view virtual returns (address[] memory) {
        AccessControlEnumerableStorage storage $ = getAccessControlEnumerableStorage();
        return $._roleMembers[role].values();
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.AccessControlEnumerable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant TokenAccessControlEnumerableStorageLocation =
        0xc1f6fe24621ce81ec5827caf0253cadb74709b061630e6b55e82371705932000;

    function getAccessControlEnumerableStorage() private pure returns (AccessControlEnumerableStorage storage $) {
        assembly {
            $.slot := TokenAccessControlEnumerableStorageLocation
        }
    }

    function containAccount(bytes32 role, address account) internal view returns (bool) {
        AccessControlEnumerableStorage storage $ = getAccessControlEnumerableStorage();
        address[] memory roles = $._roleMembers[role].values();
        for (uint256 i = 0; i < roles.length; i++) {
            if (roles[i] == account) {
                return true;
            }
        }
        return false;
    }

    function _checkRoleAccount(bytes32 role, address account) internal view virtual {
        if (!containAccount(role, account)) {
            revert UnauthorizedAccount(account, role);
        }
    }
}
