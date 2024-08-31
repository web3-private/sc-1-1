// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract MinterableCopy {
    mapping(address => bool) internal minters;
    bytes32 public constant MASTER_MINTER_ROLE = keccak256("MASTER_MINTER_ROLE");
    address public masterMinter;
    mapping(address => uint256) internal minterAllowed;

    event MinterConfigured(address indexed minter, uint256 minterAllowedAmount);
    event MinterRemoved(address indexed oldMinter);
    event MasterMinterChanged(address indexed newMasterMinter);

    modifier onlyMinters() {
        require(minters[msg.sender], "Minterable: caller is not a minter");
        _;
    }

    modifier onlyMasterMinter() {
        require(msg.sender == masterMinter, "Minterable: caller is not the masterMinter");
        _;
    }

    function minterAllowance(address minter) external view returns (uint256) {
        return minterAllowed[minter];
    }

    function isMinter(address account) external view returns (bool) {
        return minters[account];
    }

    function configureMinter(
        address minter,
        uint256 minterAllowedAmount
    ) external virtual onlyMasterMinter returns (bool) {
        minters[minter] = true;
        minterAllowed[minter] = minterAllowedAmount;
        emit MinterConfigured(minter, minterAllowedAmount);
        return true;
    }

    function removeMinter(address minter) external onlyMasterMinter returns (bool) {
        minters[minter] = false;
        minterAllowed[minter] = 0;
        emit MinterRemoved(minter);
        return true;
    }

    function updateMasterMinter(address _newMasterMinter) public virtual {
        require(_newMasterMinter != address(0), "Minterable: new masterMinter is the zero address");
        masterMinter = _newMasterMinter;
        emit MasterMinterChanged(masterMinter);
    }
}
