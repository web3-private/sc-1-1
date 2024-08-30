 //SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { JDSCOwnable } from "../access/JDSCOwnable.sol";
// import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { Pausable } from "@openzeppelin/contracts/security/Pausable.sol";
// import { Pausable } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.3/contracts/security/Pausable.sol";

// import { Ownable } from "../access/Ownable.sol";
// import { Ownable } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.2/contracts/access/Ownable.sol";


/**
 * @notice Base contract which allows children to implement an emergency stop
 * mechanism
 * @dev Forked from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/feb665136c0dae9912e08397c1a21c4af3651ef3/contracts/lifecycle/Pausable.sol
 * Modifications:
 * 1. Added pauser role, switched pause/unpause to be onlyPauser (6/14/2018)
 * 2. Removed whenNotPause/whenPaused from pause/unpause (6/14/2018)
 * 3. Removed whenPaused (6/14/2018)
 * 4. Switches ownable library to use ZeppelinOS (7/12/18)
 * 5. Remove constructor (7/13/18)
 * 6. Reformat, conform to Solidity 0.6 syntax and add error messages (5/13/20)
 * 7. Make public functions external (5/27/20)
 */
contract JDSCPausable is Pausable, JDSCOwnable {
    event Pause();
    event Unpause();
    event PauserChanged(address indexed newAddress);

    address public pauser;
  
    /**
     * @dev throws if called by any account other than the pauser
     */
    modifier onlyPauser() {
        require(msg.sender == pauser, "JDSCPausable: caller is not the pauser");
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() external onlyPauser {
        _pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() external onlyPauser {
        _unpause();
    }

    /**
     * @notice Updates the pauser address.
     * @param _newPauser The address of the new pauser.
     */
    function updatePauser(address _newPauser) external onlyOwner {
        require(
            _newPauser != address(0),
            "JDSCPausable: new pauser is the zero address"
        );
        pauser = _newPauser;
        emit PauserChanged(pauser);
    }
}
