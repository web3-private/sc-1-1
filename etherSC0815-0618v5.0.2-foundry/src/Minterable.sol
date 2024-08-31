// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {AccessManager} from "./AccessManager.sol";
import {TokenErrors} from "./interfaces/TokenErrors.sol";

/**
 * @title Minterable
 * @author Asan
 * @dev Allows the account to be added to the minter role by the "master minter" role,
 * and minter gives the user mint stablecoins.
 */
abstract contract Minterable is AccessManager, TokenErrors {
    /**
     * @dev Record the allowances under the spender account address.
     */
    mapping(address spender => uint256) _allowances;

    /**
     * @dev Defines the mint function approval quota event.
     * @param spender Designated spender address.
     * @param value Specify mint amount.
     */
    event ApprovalMint(address indexed spender, uint256 value);

    /**
     * @dev Define the "minter" modification event.
     * @param minter minter address.
     * @param amount Specify mint amount.
     */
    event ConfigureMinter(address indexed minter, uint256 amount);

    /**
     * @dev Defines the event to remove the minter role.
     * @param oldMinter The minter address before the change.
     */
    event RemoveMinter(address indexed oldMinter);

    /**
     * @dev Define the minter modification event.
     * @param newManager New minter account address.
     */
    event UpdateMasterMinter(address indexed newManager);

    /**
     * @notice The restriction function can only be called by the minter.
     * @dev The restriction function can only be called by the minter.
     * Functions that use this modifier will first execute the _accessHasRole() function.
     */
    modifier onlyMinter() {
        require(_accessHasRole(MINTER_ROLE, msg.sender), "Minterable: caller is not a minter");
        _;
    }

    /**
     * @notice The restriction function can only be called by the master minter.
     * @dev The restriction function can only be called by the master minter.
     * Functions that use this modifier will first execute the _accessHasRole() function.
     */
    modifier onlyMasterMinter() {
        require(_accessHasRole(MASTER_MINTER_ROLE, msg.sender), "Minterable: caller is not the masterMinter");
        _;
    }

    /**
     * @dev Check whether the caller is a minter.
     */
    function isMinter(address account) external view returns (bool) {
        return _accessHasRole(MINTER_ROLE, account);
    }

    /**
     * @dev Add the input address to the minter role and configure the Mintable amount.
     * @param minter  minter address.
     * @param amount  configure the Mintable amount.
     */
    function addMinter(address minter, uint256 amount) external virtual returns (bool);

    /**
     * @dev Delete the minter role whose address is entered.
     * @param minter entered minter address.
     * @return Return delete result.
     */
    function removeMinter(address minter) external virtual returns (bool);

    /**
     * @dev Update the master minter account address.
     * @param _newMasterMinter entered master minter address.
     */
    function updateMasterMinter(address _newMasterMinter) public virtual;

    /**
     * @dev Configure the mint quota for the spender account address.
     * @param spender  spender address.
     * @param value Specify mint amount.
     */
    function _approveMint(address spender, uint256 value) internal {
        _approveMint(spender, value, true);
    }

    /**
     * @dev Configure the mint quota for the spender account address.
     * @param spender  spender address.
     * @param value Specify mint amount.
     * @param emitEvent Whether to enable event sending.
     */
    function _approveMint(address spender, uint256 value, bool emitEvent) internal virtual {
        if (spender == address(0)) {
            revert InvalidSpender(address(0));
        }

        _allowances[spender] = value;
        if (emitEvent) {
            emit ApprovalMint(spender, value);
        }
    }

    /**
     * @dev Reduce the mint limit for spender account addresses.
     * @param spender  spender address.
     * @param value Reduce mint amount.
     */
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
