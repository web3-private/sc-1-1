//SPDX-License-Identifier: Apache-2.0


pragma solidity ^0.8.0;

// import { SignatureChecker } from "../util/SignatureChecker.sol";
import { MessageHashUtils } from "../util/MessageHashUtils.sol";
import { ECRecover } from "../util/ECRecover.sol";

contract JDSCValidSign {
    bytes32 public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH = 0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267;
    bytes32 public _DEPRECATED_CACHED_DOMAIN_SEPARATOR = keccak256(
                abi.encode(
                    // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
                    0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
                    keccak256(bytes("jdscToken")),
                    keccak256(bytes("1")),
                    uint256(111),
                    address(0x42fAd15b13EBc1126BE2318ad876cb8e5f4b1C3E)
                )
            );


    event TransferWithAuthorizationEvent(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes signature);

    event RequireValidSignatureEvent(
        address signer,
        bytes32 dataHash,
        bytes signature,
        bytes32 domain
    );

    // Validates that signature against input data struct
    function validSignature (
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes memory signature

    )  public {
    // )  public view {
         emit TransferWithAuthorizationEvent(from,to, value, validAfter, validBefore, nonce, signature);
         bytes32 dataHash = keccak256(
                abi.encode(
                    TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
                    from,
                    to,
                    value,
                    validAfter,
                    validBefore,
                    nonce
                )
            );

        bytes32 digest = MessageHashUtils.toTypedDataHash(_DEPRECATED_CACHED_DOMAIN_SEPARATOR, dataHash);
        address signer = ECRecover.recover(digest, signature);
        require(signer == from, "error signer ");
        // require(
        //     SignatureChecker.isValidSignatureNow(
        //         from,
        //         MessageHashUtils.toTypedDataHash(_DEPRECATED_CACHED_DOMAIN_SEPARATOR, dataHash),
        //         signature
        //     ),
        //     "JDSCTokenV2: invalid signature"
        // );
    }

    function validDigest(

        address signer,
        bytes32 digest,
        bytes memory signature
    ) 
        public 
        view 
    {

        // bytes32 _DEPRECATED_CACHED_DOMAIN_SEPARATOR = keccak256(
        //         abi.encode(
        //             // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
        //             0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
        //             keccak256(bytes("jdscToken")),
        //             keccak256(bytes("1")),
        //             uint256(111),
        //             address(0x42fAd15b13EBc1126BE2318ad876cb8e5f4b1C3E)
        //         )
        //     );

        // require(
        //     SignatureChecker.isValidSignatureNow(
        //         signer,
        //         MessageHashUtils.toTypedDataHash(_DEPRECATED_CACHED_DOMAIN_SEPARATOR, digest),
        //         signature
        //     ),
        //     "JDSCTokenV2: invalid signature"
        // );
    }


    function getChainId()
        public
        view
        returns (uint256)
    {

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

}
