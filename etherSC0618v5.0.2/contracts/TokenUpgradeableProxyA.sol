// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// import {TokenUpgradeable} from "./TokenUpgradeable.sol";

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
// import {IERC1967} from "@openzeppelin/contracts/interfaces/IERC1967.sol";
// import {ERC1967Upgrade} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";

/**
 * @title This is a business expansion contract.
 * @author Asan
 * @notice This is an ERC20-compliant JDSC stablecoin business extension contract.
 * @dev It implements some basic token functions and is upgradable.
 */
contract TokenUpgradeableProxyA  {

// contract TokenUpgradeableProxy is TokenUpgradeable, TransparentUpgradeableProxy {
// 

//     constructor(address _logic, address initialOwner, bytes memory _data) payable TransparentUpgradeableProxy( _logic, initialOwner, _data){
        
//     }

//     // constructor(address _logic, address initialOwner, bytes memory _data) payable ERC1967Proxy(_logic, _data) {
//     //     _admin = address(new ProxyAdmin(initialOwner));
//     //     // Set the storage value and emit an event for ERC-1967 compatibility
//     //     ERC1967Utils.changeAdmin(_proxyAdmin());
//     // }

//    fallback() external payable override virtual {
//         super._fallback();
//     }


    // receive() external payable virtual {
    //     _fallback();
    // }

}
