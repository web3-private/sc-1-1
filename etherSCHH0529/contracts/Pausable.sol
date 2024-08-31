 //SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

abstract contract Pausable {
    event PauserChanged(address indexed newAddress);

    address public pauser;
  
    /**
     * @dev throws if called by any account other than the pauser
     */
    modifier onlyPauser() {
        require(msg.sender == pauser, "Pausable: caller is not the pauser");
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public virtual onlyPauser {
      
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public virtual onlyPauser {
    
    }

    /**
     * @notice Updates the pauser address.
     * @param _newPauser The address of the new pauser.
     */
    function updatePauser(address _newPauser) public virtual {
     
    }
    
}
