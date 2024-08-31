// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/**
 * @title TimeLock
 * @author JD Coinlink
 * @dev Token time-locked stream interface.
 */
abstract contract TimeLock {
    //Traffic limiting interval
    uint256 internal constant MINT_DELAY = 12 seconds;

    //User time lock
    mapping(address => uint256) internal lastLockTime;

    //The time lock is enabled
    bool public timeLockStatus;

    modifier onlyUnlock() {
        _beforeCheck();
        _;
        _afterUpdate();
    }

    function _beforeCheck() internal view virtual {
        if (_timeLockStatus()) {
            require(block.timestamp >= lastLockTime[msg.sender] + MINT_DELAY, "TimeLock: Operation not allowed yet");
        }
    }

    function _afterUpdate() internal virtual {
        lastLockTime[msg.sender] = block.timestamp;
    }

    function _timeLockStatus() internal view returns (bool) {
        return timeLockStatus;
    }

    function updateTimeLockStatus(bool status) external virtual returns (bool) {
        timeLockStatus = status;
        return true;
    }
}
