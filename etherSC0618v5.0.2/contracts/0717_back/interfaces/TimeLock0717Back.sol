// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

abstract contract TimeLock0717Back {
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
            require(block.timestamp >= lastLockTime[msg.sender] + MINT_DELAY, "TimeLock: Operation not allowed yet");
        }
    }

    function _afterUpdate() internal virtual {
        lastLockTime[msg.sender] = block.timestamp;
    }

    function _timeLockStatus() internal view virtual returns (bool);

    function updateTimeLockStatus(bool status) external virtual returns (bool);
}
