/**
 * SPDX-License-Identifier: Apache-2.0
 *
 * Copyright (c) 2023, Circle Internet Financial, LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity ^0.8.0;

import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import { SafeMath } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.3/contracts//utils/math/SafeMath.sol";

import { AbstractJDSCToken } from "./AbstractJDSCToken.sol";
import { JDSCTokenV1_1 } from "./JDSCTokenV1_1.sol";
import { JDSCOwnable } from "../access/JDSCOwnable.sol";
import { JDSCPausable } from "../security/JDSCPausable.sol";
import { Rescuable } from "../rescue/Rescuable.sol";
import { EIP3009 } from "../eip/EIP3009.sol";
import { EIP2612 } from "../eip/EIP2612.sol";
import { EIP712 } from "../eip/EIP712.sol";
import { EIP712Domain } from "../eip/EIP712Domain.sol"; 

import { Blacklistable } from "../access/blacklist/Blacklistable.sol";
import { Whitelistable } from "../access/whitelist/Whitelistable.sol";


/**
 * @title JDSCToken
 * @dev ERC20 Token backed by JDSC reserves
 */
contract JDSCTokenV1_2 is JDSCTokenV1_1 {
    using SafeMath for uint256;
   

    function initializeV1_2(string memory newName) internal {
        require(initialized && _initializedVersion == 0);
        _DEPRECATED_CACHED_DOMAIN_SEPARATOR = EIP712.makeDomainSeparator(
            newName,
            "1"
        );
        _initializedVersion = 1;
    }

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
    function receiveWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) 
        external 
        whenNotPaused 
        notBlacklisted(from)
        notBlacklisted(to) 
    {
        _receiveWithAuthorization(
            from,
            to,
            value,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
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
     * @param signature     Signature bytes signed by an EOA wallet or a contract wallet
     */
    function receiveWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes memory signature
    ) 
        external 
        whenNotPaused 
        notBlacklisted(from) 
        notBlacklisted(to) 
    {
        _receiveWithAuthorization(
            from,
            to,
            value,
            validAfter,
            validBefore,
            nonce,
            signature
        );
    }

    /**
     * @notice Attempt to cancel an authorization
     * @dev Works only if the authorization is not yet used.
     * @param authorizer    Authorizer's address
     * @param nonce         Nonce of the authorization
     * @param v             v of the signature
     * @param r             r of the signature
     * @param s             s of the signature
     */
    // function cancelAuthorization(
    //     address authorizer,
    //     bytes32 nonce,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s
    // ) 
    //     external 
    //     whenNotPaused 
    // {
    //     _cancelAuthorization(authorizer, nonce, v, r, s);
    // }

    /**
     * @notice Attempt to cancel an authorization
     * @dev Works only if the authorization is not yet used.
     * EOA wallet signatures should be packed in the order of r, s, v.
     * @param authorizer    Authorizer's address
     * @param nonce         Nonce of the authorization
     * @param signature     Signature bytes signed by an EOA wallet or a contract wallet
     */
    // function cancelAuthorization(
    //     address authorizer,
    //     bytes32 nonce,
    //     bytes memory signature
    // ) 
    //     external 
    //     whenNotPaused 
    // {
    //     _cancelAuthorization(authorizer, nonce, signature);
    // }

    /**
     * @notice Update allowance with a signed permit
     * @dev EOA wallet signatures should be packed in the order of r, s, v.
     * @param owner       Token owner's address (Authorizer)
     * @param spender     Spender's address
     * @param value       Amount of allowance
     * @param deadline    The time at which the signature expires (unix time), or max uint256 value to signal no expiration
     * @param signature   Signature bytes signed by an EOA wallet or a contract wallet
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        bytes memory signature
    ) 
        external 
        virtual
        whenNotPaused
        notBlacklisted(owner)
        notBlacklisted(spender)
    {
        _permit(owner, spender, value, deadline, signature);
    }


    /**
     * @notice Update allowance with a signed permit
     * @param owner       Token owner's address (Authorizer)
     * @param spender     Spender's address
     * @param value       Amount of allowance
     * @param deadline    The time at which the signature expires (unix time), or max uint256 value to signal no expiration
     * @param v           v of the signature
     * @param r           r of the signature
     * @param s           s of the signature
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        virtual
        whenNotPaused
        notBlacklisted(owner)
        notBlacklisted(spender)
    {
        _permit(owner, spender, value, deadline, v, r, s);
    }
}
