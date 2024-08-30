// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
// import { MessageHashUtils } from "./utils/cryptography/MessageHashUtils.sol";

/**
 * @title EIP-3009
 * @notice Provide internal implementation for gas-abstracted transfers
 * @dev Contracts that inherit from this must wrap these with publicly
 * accessible functions, optionally adding modifiers where necessary
 */
abstract contract Authorizable {
    // keccak256("TransferWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
    bytes32
        public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH = 0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267;
   
//    // keccak256("TransferWithAuthorizationFee(address feeAccount,address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
//     bytes32
//         public constant TRANSFER_WITH_AUTHORIZATIONFEE_TYPEHASH = 0xf2186bca5887655aea9842bc3b7af9783edb339d7b7b87d9876505703fd4dc67;

    // keccak256("ReceiveWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
    bytes32
        public constant RECEIVE_WITH_AUTHORIZATION_TYPEHASH = 0xd099cc98ef71107a616c4f0f941f04c322d8e254fe26b3c6668db87aae413de8;

    // keccak256("CancelAuthorization(address authorizer,bytes32 nonce)")
    bytes32
        public constant CANCEL_AUTHORIZATION_TYPEHASH = 0x158b0a9edf7a828aad02f63cd515c68ef2f50ba807396f6d12842833a1597429;

    /**
     * @dev authorizer address => nonce => bool (true if nonce is used)
     */
    mapping(address => mapping(bytes32 => bool)) private _authorizationStates;

    // event TransferWithAuthorizationEvent(
    //     address from,
    //     address to,
    //     uint256 value,
    //     uint256 validAfter,
    //     uint256 validBefore,
    //     bytes32 nonce,
    //     bytes signature);

    // event RequireValidSignatureEvent(
    //     address signer,
    //     bytes32 dataHash,
    //     bytes signature,
    //     bytes32 domain
    // );

    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
    event AuthorizationCanceled(
        address indexed authorizer,
        bytes32 indexed nonce
    );

    // /**
    //  * @notice Returns the state of an authorization
    //  * @dev Nonces are randomly generated 32-byte data unique to the
    //  * authorizer's address
    //  * @param authorizer    Authorizer's address
    //  * @param nonce         Nonce of the authorization
    //  * @return True if the nonce is used
    //  */
    // function authorizationState(address authorizer, bytes32 nonce)
    //     external
    //     view
    //     returns (bool)
    // {
    //     return _authorizationStates[authorizer][nonce];
    // }

    /**
     * @notice Execute a transfer with a signed authorization
     * @param from          Payer's address (Authorizer)
     * @param to            Payee's address
     * @param value         Amount to be transferred
     * @param validAfter    The time after which this is valid (unix time)
     * @param validBefore   The time before which this is valid (unix time)
     * @param nonce         Unique nonce
     * @param v             v of the signature
     * @param r             r of the signature
     * @param s             s of the signature
     */
    function _transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        _transferWithAuthorization(
            from,
            to,
            value,
            validAfter,
            validBefore,
            nonce,
            abi.encodePacked(r, s, v)
        );
    }

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
    ) internal virtual {
    }

    // /**
    //  * @notice Execute a transfer with a signed authorization
    //  * @dev EOA wallet signatures should be packed in the order of r, s, v.
    //  * @param from          Payer's address (Authorizer)
    //  * @param to            Payee's address
    //  * @param value         Amount to be transferred
    //  * @param validAfter    The time after which this is valid (unix time)
    //  * @param validBefore   The time before which this is valid (unix time)
    //  * @param nonce         Unique nonce
    //  * @param signature     Signature byte array produced by an EOA wallet or a contract wallet
    //  */
    // function _transferWithAuthorization(
    //     address from,
    //     address to,
    //     uint256 value,
    //     uint256 validAfter,
    //     uint256 validBefore,
    //     bytes32 nonce,
    //     bytes memory signature
    // ) internal {
    //     _requireValidAuthorization(from, nonce, validAfter, validBefore);
    //     // bytes32 dataHash = keccak256(
    //     //         abi.encode(
    //     //             TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
    //     //             from,
    //     //             to,
    //     //             value,
    //     //             validAfter,
    //     //             validBefore,
    //     //             nonce
    //     //         )
    //     //     );
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

    //     _transfer(from, to, value);
    // }

    /**
     * @notice Receive a transfer with a signed authorization from the payer
     * @dev This has an additional check to ensure that the payee's address
     * matches the caller of this function to prevent front-running attacks.
     * @param from          Payer's address (Authorizer)
     * @param to            Payee's address
     * @param value         Amount to be transferred
     * @param validAfter    The time after which this is valid (unix time)
     * @param validBefore   The time before which this is valid (unix time)
     * @param nonce         Unique nonce
     * @param v             v of the signature
     * @param r             r of the signature
     * @param s             s of the signature
     */
    function _receiveWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        _receiveWithAuthorization(
            from,
            to,
            value,
            validAfter,
            validBefore,
            nonce,
            abi.encodePacked(r, s, v)
        );
    }


    /**
     * @notice Receive a transfer with a signed authorization from the payer
     * @dev This has an additional check to ensure that the payee's address
     * matches the caller of this function to prevent front-running attacks.
     * EOA wallet signatures should be packed in the order of r, s, v.
     * @param from          Payer's address (Authorizer)
     * @param to            Payee's address
     * @param value         Amount to be transferred
     * @param validAfter    The time after which this is valid (unix time)
     * @param validBefore   The time before which this is valid (unix time)
     * @param nonce         Unique nonce
     * @param signature     Signature byte array produced by an EOA wallet or a contract wallet
     */
    function _receiveWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes memory signature
    ) internal virtual {

    }


    // /**
    //  * @notice Receive a transfer with a signed authorization from the payer
    //  * @dev This has an additional check to ensure that the payee's address
    //  * matches the caller of this function to prevent front-running attacks.
    //  * EOA wallet signatures should be packed in the order of r, s, v.
    //  * @param from          Payer's address (Authorizer)
    //  * @param to            Payee's address
    //  * @param value         Amount to be transferred
    //  * @param validAfter    The time after which this is valid (unix time)
    //  * @param validBefore   The time before which this is valid (unix time)
    //  * @param nonce         Unique nonce
    //  * @param signature     Signature byte array produced by an EOA wallet or a contract wallet
    //  */
    // function _receiveWithAuthorization(
    //     address from,
    //     address to,
    //     uint256 value,
    //     uint256 validAfter,
    //     uint256 validBefore,
    //     bytes32 nonce,
    //     bytes memory signature
    // ) internal {
    //     require(to == msg.sender, "TokenV2: caller must be the payee");
    //     _requireValidAuthorization(from, nonce, validAfter, validBefore);
    //     _requireValidSignature(
    //         from,
    //         keccak256(
    //             abi.encode(
    //                 RECEIVE_WITH_AUTHORIZATION_TYPEHASH,
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

    //     _transfer(from, to, value);
    // }

    /**
     * @notice Attempt to cancel an authorization
     * @param authorizer    Authorizer's address
     * @param nonce         Nonce of the authorization
     * @param v             v of the signature
     * @param r             r of the signature
     * @param s             s of the signature
     */
    // function _cancelAuthorization(
    //     address authorizer,
    //     bytes32 nonce,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s
    // ) internal {
    //     _cancelAuthorization(authorizer, nonce, abi.encodePacked(r, s, v));
    // }

    /**
     * @notice Attempt to cancel an authorization
     * @dev EOA wallet signatures should be packed in the order of r, s, v.
     * @param authorizer    Authorizer's address
     * @param nonce         Nonce of the authorization
     * @param signature     Signature byte array produced by an EOA wallet or a contract wallet
     */
    // function _cancelAuthorization(
    //     address authorizer,
    //     bytes32 nonce,
    //     bytes memory signature
    // ) internal {
    //     _requireUnusedAuthorization(authorizer, nonce);
    //     _requireValidSignature(
    //         authorizer,
    //         keccak256(
    //             abi.encode(CANCEL_AUTHORIZATION_TYPEHASH, authorizer, nonce)
    //         ),
    //         signature
    //     );

    //     // _authorizationStates[authorizer][nonce] = true;
    //     emit AuthorizationCanceled(authorizer, nonce);
    // }

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
    ) internal view virtual {

    }

    // /**
    //  * @notice Validates that signature against input data struct
    //  * @param signer        Signer's address
    //  * @param dataHash      Hash of encoded data struct
    //  * @param signature     Signature byte array produced by an EOA wallet or a contract wallet
    //  */
    // function _requireValidSignature(
    //     address signer,
    //     bytes32 dataHash,
    //     bytes memory signature
    // ) internal view virtual {

    //     // bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));
    //     bytes32 typeHash = _hashTypedDataV4(structHash);
    //     require(
    //         SignatureChecker.isValidSignatureNow(
    //             signer,
    //             MessageHashUtils.toTypedDataHash(_domainSeparator(), dataHash),
    //             signature
    //         ),
    //         "JDSCTokenV2: invalid signature"
    //     );
    // }

    // /**
    //  * @notice Check that an authorization is unused
    //  * @param authorizer    Authorizer's address
    //  * @param nonce         Nonce of the authorization
    //  */
    // function _requireUnusedAuthorization(address authorizer, bytes32 nonce)
    //     private
    //     view
    // {
    //     require(
    //         !_authorizationStates[authorizer][nonce],
    //         "JDSCTokenV2: authorization is used or canceled"
    //     );
    // }

    /**
     * @notice Check that authorization is valid
     * @param validAfter    The time after which this is valid (unix time)
     * @param validBefore   The time before which this is valid (unix time)
     */
    function _requireValidAuthorization(
        // address authorizer,
        // bytes32 nonce,
        uint256 validAfter,
        uint256 validBefore
    ) internal view {
        require(
            block.timestamp > validAfter,
            "JDSCTokenV2: authorization is not yet valid"
        );
        require(block.timestamp < validBefore, "JDSCTokenV2: authorization is expired");
    }

    // /**
    //  * @notice Mark an authorization as used
    //  * @param authorizer    Authorizer's address
    //  * @param nonce         Nonce of the authorization
    //  */
    // function _markAuthorizationAsUsed(address authorizer, bytes32 nonce)
    //     internal
    //     // private
    // {
    //     _authorizationStates[authorizer][nonce] = true;
    //     emit AuthorizationUsed(authorizer, nonce);
    // }
}
