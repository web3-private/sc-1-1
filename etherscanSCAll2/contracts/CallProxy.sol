// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract CallProxy {
    uint public unlockTime;
    address payable public owner;
    address private implementation;

    event Delegatecall(bool success, bytes ret, address impl, bytes data);

    constructor(address _implement) {

        implementation = _implement;
    }

    function delecall(address from, address to, uint256 amount) public returns(bool success, bytes memory ret){
      
      string memory funcName = "transfer(address,address,uint256)";
    //   address memory from = "0x971f1C4f13766CD4B09d04D835E441BcCA9EF40D";
    //   address memory to = "0xdFd8fB01d9141c7fAA253Afe81133C6996531Ea7";
      bytes memory selectors = abi.encodeWithSignature(funcName, from, to);
      console.log("selectors is :",string(selectors));
      (bool success, bytes memory ret) = (true, "sd");
    //   (bool success, bytes memory ret) = implementation.delegatecall(abi.encodeWithSignature(funcName, from, to, amount));
      emit Delegatecall(success, ret, implementation, selectors);
     return (success, ret);
    //   return (success, ret);
    }
}
