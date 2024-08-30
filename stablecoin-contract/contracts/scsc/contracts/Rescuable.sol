// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { IERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import { SafeERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";


contract Rescuable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    address internal _rescuer;

    event RescuerChanged(address indexed newRescuer);

    /**
     * @notice Returns current rescuer
     * @return Rescuer's address
     */
    function rescuer() external view returns (address) {
        return _rescuer;
    }

    /**
     * @notice Revert if called by any account other than the rescuer.
     */
    modifier onlyRescuer() {
        require(msg.sender == _rescuer, "Rescuable: caller is not the rescuer");
        _;
    }

    /**
     * @notice Rescue ERC20 tokens locked up in this contract.
     * @param tokenContract ERC20 token contract address
     * @param to        Recipient address
     * @param amount    Amount to withdraw
     */
    function rescueERC20(
        IERC20Upgradeable tokenContract,
        address to,
        uint256 amount
    ) external onlyRescuer {
        tokenContract.safeTransfer(to, amount);
    }

    /**
     * @notice Updates the rescuer address.
     * @param newRescuer The address of the new rescuer.
     */
    function updateRescuer(address newRescuer) external virtual {
    
    }
    // /**
    //  * @notice Updates the rescuer address.
    //  * @param newRescuer The address of the new rescuer.
    //  */
    // function updateRescuer(address newRescuer) external onlyOwner {
    //     require(
    //         newRescuer != address(0),
    //         "Rescuable: new rescuer is the zero address"
    //     );
    //     _rescuer = newRescuer;
    //     emit RescuerChanged(newRescuer);
    // }
}
