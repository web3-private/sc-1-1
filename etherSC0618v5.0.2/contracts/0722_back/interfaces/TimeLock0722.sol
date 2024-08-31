// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "hardhat/console.sol";

abstract contract TimeLock0722 {
    uint256 internal constant MINT_DELAY = 12 seconds;
    mapping(address => uint256) internal lastLockTime;

    bool public timeLockStatus;

    modifier onlyUnlock() {
        _beforeCheck();
        _;
        _afterUpdate();
    }

    function _beforeCheck() internal view virtual {
        if (_timeLockStatus()) {
            console.log("timeLock _timeLockStatus:", _timeLockStatus());
            console.log("timeLock block.timestamp:", block.timestamp);
            console.log("timeLock lastLockTime[msg.sender]:", lastLockTime[msg.sender]);
            console.log("timeLock msg.sender:", msg.sender);
            require(block.timestamp >= lastLockTime[msg.sender] + MINT_DELAY, "TimeLock: Operation not allowed yet");
        }
    }

    function _afterUpdate() internal virtual {
        console.log("timeLock timestamp:", block.timestamp);
        lastLockTime[msg.sender] = block.timestamp;
    }

    function _timeLockStatus() internal view virtual returns (bool);

    function updateTimeLockStatus(bool status) external virtual;
}
