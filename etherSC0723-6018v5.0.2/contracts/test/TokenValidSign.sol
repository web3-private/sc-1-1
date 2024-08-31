//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract TokenValidSign {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    bytes32 public _DEPRECATED_CACHED_DOMAIN_SEPARATOR =
        keccak256(
            abi.encode(
                // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
                0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
                keccak256(bytes("jdscToken")),
                keccak256(bytes("1")),
                uint256(111),
                address(0x42fAd15b13EBc1126BE2318ad876cb8e5f4b1C3E)
            )
        );

    function validSignature(
        address owner,
        address spender,
        uint256 value,
        bytes32 nonce,
        uint256 deadline,
        bytes memory signature
    ) public view {
        bytes32 dataHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));

        bytes32 digest = MessageHashUtils.toTypedDataHash(_DEPRECATED_CACHED_DOMAIN_SEPARATOR, dataHash);
        address signer = ECDSA.recover(digest, signature);
        require(signer == owner, "error signer ");
    }

    function getChainId() public view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}
