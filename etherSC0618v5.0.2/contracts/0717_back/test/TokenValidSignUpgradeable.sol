//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "hardhat/console.sol";

import {TokenUpgradeable0626} from "../TokenUpgradeable0626-1.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract TokenValidSignUpgradeable is TokenUpgradeable0626 {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    function validSignature(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view {
        // console.logUint(block.chainid);
        // console.log("validSignature:::::start");
        // console.log("account:::::%s", owner);
        // console.log("spender:::::%s", spender);
        // console.log("value:::::%s", value);
        // console.log("nonce:::::%s", nonce);
        // console.log("deadline:::::%s",deadline);
        // console.log("v:::::%s",v);
        // console.logBytes32(r);
        // console.logBytes32(s);
        // console.log("validSignature:::::end");

        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        // _approve(owner, spender, value);
        console.log("hash::::: start");
        console.logBytes32(hash);
        console.log("hash::::: end");
    }
}
