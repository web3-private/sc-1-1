// SPDX-License-Identifier: MIT

        
pragma solidity ^0.8.0;

import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
// import { ECDSA } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.3/contracts/utils/cryptography/ECDSA.sol";
import { ERC20Transferable } from "../erc20/extensions/ERC20Transferable.sol";
import { EIP712Domain } from "../eip/EIP712Domain.sol";
// import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { SignatureChecker } from "../util/SignatureChecker.sol";
import { MessageHashUtils } from "../util/MessageHashUtils.sol";
import { ECRecover } from "../util/ECRecover.sol";
import { LibEIP712 } from "./LibEIP712.sol";
/**
 * @title EIP-3009
 * @notice Provide internal implementation for gas-abstracted transfers
 * @dev Contracts that inherit from this must wrap these with publicly
 * accessible functions, optionally adding modifiers where necessary
 */
contract ValidSignature is EIP712Domain {
  
    constructor() {
        initialize("jdsc","1");
    }

    function initialize(string memory name, string memory version) internal {
        _DEPRECATED_CACHED_DOMAIN_SEPARATOR = LibEIP712.makeDomainSeparator(
            name,
            version
        );
    }

    // keccak256("TransferWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
 bytes32
        public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH = 0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267;

    // keccak256("TransferWithAuthorizationFee(address feeAccount,address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
 bytes32
        public constant TRANSFER_WITH_AUTHORIZATIONFEE_TYPEHASH = 0xf2186bca5887655aea9842bc3b7af9783edb339d7b7b87d9876505703fd4dc67;

    /**
     * @notice Execute a transfer with a signed authorization
     * @dev EOA wallet signatures should be packed in the order of r, s, v.
     * @param from          Payer's address (Authorizer)
     * @param to            Payee's address
     * @param value         Amount to be transferred
     * @param validAfter    The time after which this is valid (unix time)
     * @param validBefore   The time before which this is valid (unix time)
     * @param nonce         Unique nonce
     * @param signature     Signature byte array produced by an EOA wallet or a contract wallet
     */
    function _transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes memory signature
    ) public view {
        _requireValidAuthorization(from, nonce, validAfter, validBefore);
        _requireValidSignature(
            from,
            keccak256(
                abi.encode(
                    TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
                    from,
                    to,
                    value,
                    validAfter,
                    validBefore,
                    nonce
                )
            ),
            signature
        );

    }

// step 1 
  function step1_genAndvalidSignature (
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce
    ) public pure returns(bytes memory, address , bytes32) {
        // _requireValidAuthorization(from, nonce, validAfter, validBefore);
        

    //     _requireValidSignature(
    //         from,
    //         keccak256(
    //             abi.encode(
    //                 TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
    //                 from,
    //                 to,
    //                 value,
    //                 validAfter,
    //                 validBefore,
    //                 nonce
    //             )
    //         ),
    //         signature
    //     );

    // function _requireValidSignature(
    //     address signer,
    //     bytes32 dataHash,
    //     bytes memory signature
    // ) private view {
    //     require(
    //         SignatureChecker.isValidSignatureNow(
    //             signer,
    //             MessageHashUtils.toTypedDataHash(_domainSeparator(), dataHash),
    //             signature
    //         ),
    //         "JDSCTokenV2: invalid signature"
    //     );
    // }

        bytes memory encoded = abi.encode(
                TRANSFER_WITH_AUTHORIZATIONFEE_TYPEHASH,
                from,
                to,
                value,
                validAfter,
                validBefore,
                nonce
            );

        bytes32 dataHash = keccak256(encoded);
        return (encoded, from , dataHash);

    }


    // step 2 
    function signAuthorization(
        address authorizer,
        bytes32 nonce,
        bytes memory _signature
    ) external view {
        // _requireUnusedAuthorization(authorizer, nonce);
        _requireValidSignature(
            authorizer,
            keccak256(
                abi.encode(TRANSFER_WITH_AUTHORIZATIONFEE_TYPEHASH, authorizer, nonce)
            ),
            _signature
        );
    }

    // setp 2
    function step2_digest(
        bytes32 dataHash
    ) external view returns(bytes32){
       bytes32 digest = MessageHashUtils.toTypedDataHash(_domainSeparator(), dataHash);
       return digest;
    }

    //step_3 sign
     function step3_sign(bytes32 digest) public pure returns(bytes memory) {
        // // 构造要签名的数据
        // bytes32 message = keccak256(abi.encode(
        //     address(this),
        //     from,
        //     to,
        //     value,
        //     validAfter,
        //     validBefore,
        //     nonce
        // ));
         
         //加上domain
        //   return ECDSA.toTypedDataHash(digest);
        return abi.encodePacked("\x19Ethereum Signed Message:\n32", digest);
    }

    //step 4
   function step4_verify(bytes32 digest, address signer, bytes memory signature) public pure returns(bool) {
         address _signer = ECRecover.recover(digest, signature);
         return _signer == signer;
    }


    function signatureddd(
        address authorizer,
        bytes32 nonce

    ) external view returns(bytes32){
        bytes32 dataHash = keccak256(abi.encode(TRANSFER_WITH_AUTHORIZATIONFEE_TYPEHASH, authorizer, nonce));
       bytes32 digest = MessageHashUtils.toTypedDataHash(_domainSeparator(), dataHash);
       return digest;
    }

    function isSignature(bytes32 digest, address signer, bytes memory signature) public pure returns(bool) {
         address _signer = ECRecover.recover(digest, signature);
         return _signer == signer;
    }

    /**
     * @notice Validates that signature against input data struct
     * @param signer        Signer's address
     * @param dataHash      Hash of encoded data struct
     * @param signature     Signature byte array produced by an EOA wallet or a contract wallet
     */
    function _requireValidSignature(
        address signer,
        bytes32 dataHash,
        bytes memory signature
    ) private view {
        require(
            SignatureChecker.isValidSignatureNow(
                signer,
                MessageHashUtils.toTypedDataHash(_domainSeparator(), dataHash),
                signature
            ),
            "JDSCTokenV2: invalid signature"
        );
    }

    /**
     * @notice Check that authorization is valid
     * @param authorizer    Authorizer's address
     * @param nonce         Nonce of the authorization
     * @param validAfter    The time after which this is valid (unix time)
     * @param validBefore   The time before which this is valid (unix time)
     */
    function _requireValidAuthorization(
        address authorizer,
        bytes32 nonce,
        uint256 validAfter,
        uint256 validBefore
    ) private view {
        require(
            block.timestamp > validAfter,
            // now > validAfter,
            "JDSCTokenV2: authorization is not yet valid"
        );
        require(block.timestamp < validBefore, "JDSCTokenV2: authorization is expired");
        // // require(now < validBefore, "JDSCTokenV2: authorization is expired");
        // _requireUnusedAuthorization(authorizer, nonce);
    }
}
