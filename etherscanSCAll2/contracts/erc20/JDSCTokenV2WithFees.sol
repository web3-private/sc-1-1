// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0;

// import "./TokenCalcFees.sol";

// contract JDSCTokenV2WithFees is TokenCalcFees {

//     using SafeMath for uint;

//     /**
//      * @notice initializeV1WithFee the JDSC token contract.
//      * @param accountsToBlacklist       The blacklister address for the JDSC token.
//      * @param newSymbol     The symbol of the JDSC token.
//      * @param lostAndFound   The lostAndFound address for the JDSC token
//      */
//     function initializeV1WithFee(
//         address[] calldata accountsToBlacklist,
//         string calldata newSymbol,
//         address lostAndFound
//     ) external {
//         require(_initializedVersion == 1);

//         // Update fiat token symbol
//         symbol = newSymbol;


//         uint256 lockedAmount = _balanceOf(address(this));
//         if (lockedAmount > 0) {
//             _transfer(address(this), lostAndFound, lockedAmount);
//         }

//         // Add previously blacklisted accounts to the new blacklist data structure
//         // and remove them from the old blacklist data structure.
//         for (uint256 i = 0; i < accountsToBlacklist.length; i++) {
//             _blacklist(accountsToBlacklist[i]);
//         }
//         _blacklist(address(this));

//         _initializedVersion = 2;
//     }

//     /**
//      * @notice Execute a transfer with a signed authorization.And deduct the caller fee.
//      * @dev EOA wallet signatures should be packed in the order of r, s, v.
//      * @param feeAccount    Commission address.
//      * @param from          Payer's address (Authorizer)
//      * @param to            Payee's address
//      * @param value         Amount to be transferred
//      * @param validAfter    The time after which this is valid (unix time)
//      * @param validBefore   The time before which this is valid (unix time)
//      * @param nonce         Unique nonce
//      * @param signature     Signature bytes signed by an EOA wallet or a contract wallet
//      */
//     function transferWithAuthorizationFee(
//         address feeAccount, 
//         address from,
//         address to,
//         uint256 value,
//         uint256 validAfter,
//         uint256 validBefore,
//         bytes32 nonce,
//         bytes memory signature
//     ) 
//         external 
//         whenNotPaused
//         isAddressWhitelisted(feeAccount) 
//         isAddressWhitelisted(from)
//     {

//         uint fee = calcFee(value);
//         uint sendAmount = value.sub(fee);

//         transferWithAuthorization(
//             from,
//             to,
//             sendAmount,
//             validAfter,
//             validBefore,
//             nonce,
//             signature
//         );

//         if (fee > 0) {
//           transferWithAuthorization(
//             from,
//             feeAccount,
//             fee,
//             validAfter,
//             validBefore,
//             nonce,
//             signature
//           );
//         }
//     }

//      /**
//      * @notice Execute a transfer with a signed authorization.And deduct the caller fee.
//      * @param feeAccount    Commission address.
//      * @param from          Payer's address (Authorizer)
//      * @param to            Payee's address
//      * @param value         Amount to be transferred
//      * @param validAfter    The time after which this is valid (unix time)
//      * @param validBefore   The time before which this is valid (unix time)
//      * @param nonce         Unique nonce
//      * @param v             v of the signature
//      * @param r             r of the signature
//      * @param s             s of the signature
//      */
//     function transferWithAuthorizationFee(
//         address feeAccount, 
//         address from,
//         address to,
//         uint256 value,
//         uint256 validAfter,
//         uint256 validBefore,
//         bytes32 nonce,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) 
//         external 
//         whenNotPaused 
//         isAddressWhitelisted(feeAccount) 
//         isAddressWhitelisted(from) 
//     {

//         uint fee = calcFee(value);
//         uint sendAmount = value.sub(fee);

//         transferWithAuthorization(
//             from,
//             to,
//             sendAmount,
//             validAfter,
//             validBefore,
//             nonce,
//             v,
//             r,
//             s
//         );

//         if (fee > 0) {
//           _transferWithAuthorization(
//               from,
//               feeAccount,
//               fee,
//               validAfter,
//               validBefore,
//               nonce,
//               v,
//               r,
//               s
//           );
//         }
//     }
// }