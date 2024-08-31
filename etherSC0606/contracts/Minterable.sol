// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract Minterable {
    mapping(address => bool) internal minters;
    address public masterMinter;
    mapping(address => uint256) internal minterAllowed;

    event MinterConfigured(address indexed minter, uint256 minterAllowedAmount);
    event MinterRemoved(address indexed oldMinter);
    event MasterMinterChanged(address indexed newMasterMinter);

    /**
     * @dev Throws if called by any account other than a minter.
     */
    modifier onlyMinters() {
        require(minters[msg.sender], "Minterable: caller is not a minter");
        _;
    }

    /**
     * @dev Throws if called by any account other than the masterMinter
     */
    modifier onlyMasterMinter() {
        require(msg.sender == masterMinter, "Minterable: caller is not the masterMinter");
        _;
    }

    /**
     * @notice Gets the minter allowance for an account.
     * @param minter The address to check.
     * @return The remaining minter allowance for the account.
     */
    function minterAllowance(address minter) external view returns (uint256) {
        return minterAllowed[minter];
    }

    /**
     * @notice Checks if an account is a minter.
     * @param account The address to check.
     * @return True if the account is a minter, false if the account is not a minter.
     */
    function isMinter(address account) external view returns (bool) {
        return minters[account];
    }

    /**
     * @notice Adds or updates a new minter with a mint allowance.
     * @param minter The address of the minter.
     * @param minterAllowedAmount The minting amount allowed for the minter.
     * @return True if the operation was successful.
     */
    function configureMinter(
        address minter,
        uint256 minterAllowedAmount
    ) external virtual onlyMasterMinter returns (bool) {
        minters[minter] = true;
        minterAllowed[minter] = minterAllowedAmount;
        emit MinterConfigured(minter, minterAllowedAmount);
        return true;
    }

    /**
     * @notice Removes a minter.
     * @param minter The address of the minter to remove.
     * @return True if the operation was successful.
     */
    function removeMinter(address minter) external onlyMasterMinter returns (bool) {
        minters[minter] = false;
        minterAllowed[minter] = 0;
        emit MinterRemoved(minter);
        return true;
    }

    /**
     * @notice Updates the master minter address.
     * @param _newMasterMinter The address of the new master minter.
     */
    function updateMasterMinter(address _newMasterMinter) public virtual {
        require(_newMasterMinter != address(0), "Minterable: new masterMinter is the zero address");
        masterMinter = _newMasterMinter;
        emit MasterMinterChanged(masterMinter);
    }
}
