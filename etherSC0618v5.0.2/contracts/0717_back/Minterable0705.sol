// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {AccessManager0705} from "./AccessManager0705.sol";
import {TokenErrors0705} from "./interfaces/TokenErrors0705.sol";

abstract contract Minterable0705 is AccessManager0705, TokenErrors0705 {
    mapping(address spender => uint256) _allowances;

    mapping(address account => mapping(address spender => uint256)) minterAllowed;

    event MinterConfigured(address indexed minter);
    event MinterRemoved(address indexed oldMinter);
    event MasterMinterChanged(address indexed newMasterMinter);

    modifier onlyMinters() {
        require(_accessHasRole(MINTER_ROLE, msg.sender), "Minterable: caller is not a minter");
        _;
    }

    modifier onlyMasterMinter() {
        require(_accessHasRole(MASTER_MINTER_ROLE, msg.sender), "Minterable: caller is not the masterMinter");
        _;
    }

    function isMinter(address account) external view returns (bool) {
        return _accessHasRole(MINTER_ROLE, account);
    }

    // function updateAllowance(address minter, uint256 amount) internal virtual returns (bool);

    function configureMinter(address minter) external virtual returns (bool);

    function removeMinter(address minter) external virtual returns (bool);

    function updateMasterMinter(address _newMasterMinter) public virtual;

    function _approveMint(address spender, uint256 value) internal {
        _approveMint(spender, value, true);
    }

    function _approveMint(address spender, uint256 value, bool emitEvent) internal virtual {
        if (spender == address(0)) {
            revert InvalidSpender(address(0));
        }

        _allowances[spender] = value;
        if (emitEvent) {
            emit ApprovalMint(spender, value);
        }
    }

    function _spendAllowanceMint(address spender, uint256 value) internal virtual {
        uint256 currentAllowance = _allowances[spender];
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approveMint(spender, currentAllowance - value, false);
            }
        }
    }
}
