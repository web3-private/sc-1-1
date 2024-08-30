

// // Sources flattened with hardhat v2.22.4 https://hardhat.org

// // SPDX-License-Identifier: Apache-2.0 AND MIT

// // File @openzeppelin/contracts/utils/Context.sol@v4.9.6

// // Original license: SPDX_License_Identifier: MIT
// // OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

// pragma solidity ^0.8.0;

// /**
//  * @dev Provides information about the current execution context, including the
//  * sender of the transaction and its data. While these are generally available
//  * via msg.sender and msg.data, they should not be accessed in such a direct
//  * manner, since when dealing with meta-transactions the account sending and
//  * paying for execution may not be the actual sender (as far as an application
//  * is concerned).
//  *
//  * This contract is only required for intermediate, library-like contracts.
//  */
// abstract contract Context {
//     function _msgSender() internal view virtual returns (address) {
//         return msg.sender;
//     }

//     function _msgData() internal view virtual returns (bytes calldata) {
//         return msg.data;
//     }

//     function _contextSuffixLength() internal view virtual returns (uint256) {
//         return 0;
//     }
// }


// // File @openzeppelin/contracts/access/Ownable.sol@v4.9.6

// // Original license: SPDX_License_Identifier: MIT
// // OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

// pragma solidity ^0.8.0;

// /**
//  * @dev Contract module which provides a basic access control mechanism, where
//  * there is an account (an owner) that can be granted exclusive access to
//  * specific functions.
//  *
//  * By default, the owner account will be the one that deploys the contract. This
//  * can later be changed with {transferOwnership}.
//  *
//  * This module is used through inheritance. It will make available the modifier
//  * `onlyOwner`, which can be applied to your functions to restrict their use to
//  * the owner.
//  */
// abstract contract Ownable is Context {
//     address private _owner;

//     event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

//     /**
//      * @dev Initializes the contract setting the deployer as the initial owner.
//      */
//     constructor() {
//         _transferOwnership(_msgSender());
//     }

//     /**
//      * @dev Throws if called by any account other than the owner.
//      */
//     modifier onlyOwner() {
//         _checkOwner();
//         _;
//     }

//     /**
//      * @dev Returns the address of the current owner.
//      */
//     function owner() public view virtual returns (address) {
//         return _owner;
//     }

//     /**
//      * @dev Throws if the sender is not the owner.
//      */
//     function _checkOwner() internal view virtual {
//         require(owner() == _msgSender(), "Ownable: caller is not the owner");
//     }

//     /**
//      * @dev Leaves the contract without owner. It will not be possible to call
//      * `onlyOwner` functions. Can only be called by the current owner.
//      *
//      * NOTE: Renouncing ownership will leave the contract without an owner,
//      * thereby disabling any functionality that is only available to the owner.
//      */
//     function renounceOwnership() public virtual onlyOwner {
//         _transferOwnership(address(0));
//     }

//     /**
//      * @dev Transfers ownership of the contract to a new account (`newOwner`).
//      * Can only be called by the current owner.
//      */
//     function transferOwnership(address newOwner) public virtual onlyOwner {
//         require(newOwner != address(0), "Ownable: new owner is the zero address");
//         _transferOwnership(newOwner);
//     }

//     /**
//      * @dev Transfers ownership of the contract to a new account (`newOwner`).
//      * Internal function without access restriction.
//      */
//     function _transferOwnership(address newOwner) internal virtual {
//         address oldOwner = _owner;
//         _owner = newOwner;
//         emit OwnershipTransferred(oldOwner, newOwner);
//     }
// }


// // File @openzeppelin/contracts/security/Pausable.sol@v4.9.6

// // Original license: SPDX_License_Identifier: MIT
// // OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

// pragma solidity ^0.8.0;

// /**
//  * @dev Contract module which allows children to implement an emergency stop
//  * mechanism that can be triggered by an authorized account.
//  *
//  * This module is used through inheritance. It will make available the
//  * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
//  * the functions of your contract. Note that they will not be pausable by
//  * simply including this module, only once the modifiers are put in place.
//  */
// abstract contract Pausable is Context {
//     /**
//      * @dev Emitted when the pause is triggered by `account`.
//      */
//     event Paused(address account);

//     /**
//      * @dev Emitted when the pause is lifted by `account`.
//      */
//     event Unpaused(address account);

//     bool private _paused;

//     /**
//      * @dev Initializes the contract in unpaused state.
//      */
//     constructor() {
//         _paused = false;
//     }

//     /**
//      * @dev Modifier to make a function callable only when the contract is not paused.
//      *
//      * Requirements:
//      *
//      * - The contract must not be paused.
//      */
//     modifier whenNotPaused() {
//         _requireNotPaused();
//         _;
//     }

//     /**
//      * @dev Modifier to make a function callable only when the contract is paused.
//      *
//      * Requirements:
//      *
//      * - The contract must be paused.
//      */
//     modifier whenPaused() {
//         _requirePaused();
//         _;
//     }

//     /**
//      * @dev Returns true if the contract is paused, and false otherwise.
//      */
//     function paused() public view virtual returns (bool) {
//         return _paused;
//     }

//     /**
//      * @dev Throws if the contract is paused.
//      */
//     function _requireNotPaused() internal view virtual {
//         require(!paused(), "Pausable: paused");
//     }

//     /**
//      * @dev Throws if the contract is not paused.
//      */
//     function _requirePaused() internal view virtual {
//         require(paused(), "Pausable: not paused");
//     }

//     /**
//      * @dev Triggers stopped state.
//      *
//      * Requirements:
//      *
//      * - The contract must not be paused.
//      */
//     function _pause() internal virtual whenNotPaused {
//         _paused = true;
//         emit Paused(_msgSender());
//     }

//     /**
//      * @dev Returns to normal state.
//      *
//      * Requirements:
//      *
//      * - The contract must be paused.
//      */
//     function _unpause() internal virtual whenPaused {
//         _paused = false;
//         emit Unpaused(_msgSender());
//     }
// }


// // File @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol@v4.9.6

// // Original license: SPDX_License_Identifier: MIT
// // OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

// pragma solidity ^0.8.0;

// /**
//  * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
//  * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
//  *
//  * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
//  * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
//  * need to send a transaction, and thus is not required to hold Ether at all.
//  *
//  * ==== Security Considerations
//  *
//  * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
//  * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
//  * considered as an intention to spend the allowance in any specific way. The second is that because permits have
//  * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
//  * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
//  * generally recommended is:
//  *
//  * ```solidity
//  * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
//  *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
//  *     doThing(..., value);
//  * }
//  *
//  * function doThing(..., uint256 value) public {
//  *     token.safeTransferFrom(msg.sender, address(this), value);
//  *     ...
//  * }
//  * ```
//  *
//  * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
//  * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
//  * {SafeERC20-safeTransferFrom}).
//  *
//  * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
//  * contracts should have entry points that don't rely on permit.
//  */
// interface IERC20Permit {
//     /**
//      * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
//      * given ``owner``'s signed approval.
//      *
//      * IMPORTANT: The same issues {IERC20-approve} has related to transaction
//      * ordering also apply here.
//      *
//      * Emits an {Approval} event.
//      *
//      * Requirements:
//      *
//      * - `spender` cannot be the zero address.
//      * - `deadline` must be a timestamp in the future.
//      * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
//      * over the EIP712-formatted function arguments.
//      * - the signature must use ``owner``'s current nonce (see {nonces}).
//      *
//      * For more information on the signature format, see the
//      * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
//      * section].
//      *
//      * CAUTION: See Security Considerations above.
//      */
//     function permit(
//         address owner,
//         address spender,
//         uint256 value,
//         uint256 deadline,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) external;

//     /**
//      * @dev Returns the current nonce for `owner`. This value must be
//      * included whenever a signature is generated for {permit}.
//      *
//      * Every successful call to {permit} increases ``owner``'s nonce by one. This
//      * prevents a signature from being used multiple times.
//      */
//     function nonces(address owner) external view returns (uint256);

//     /**
//      * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
//      */
//     // solhint-disable-next-line func-name-mixedcase
//     function DOMAIN_SEPARATOR() external view returns (bytes32);
// }


// // File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.6

// // Original license: SPDX_License_Identifier: MIT
// // OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

// pragma solidity ^0.8.0;

// /**
//  * @dev Interface of the ERC20 standard as defined in the EIP.
//  */
// interface IERC20 {
//     /**
//      * @dev Emitted when `value` tokens are moved from one account (`from`) to
//      * another (`to`).
//      *
//      * Note that `value` may be zero.
//      */
//     event Transfer(address indexed from, address indexed to, uint256 value);

//     /**
//      * @dev Emitted when the allowance of a `spender` for an `owner` is set by
//      * a call to {approve}. `value` is the new allowance.
//      */
//     event Approval(address indexed owner, address indexed spender, uint256 value);

//     /**
//      * @dev Returns the amount of tokens in existence.
//      */
//     function totalSupply() external view returns (uint256);

//     /**
//      * @dev Returns the amount of tokens owned by `account`.
//      */
//     function balanceOf(address account) external view returns (uint256);

//     /**
//      * @dev Moves `amount` tokens from the caller's account to `to`.
//      *
//      * Returns a boolean value indicating whether the operation succeeded.
//      *
//      * Emits a {Transfer} event.
//      */
//     function transfer(address to, uint256 amount) external returns (bool);

//     /**
//      * @dev Returns the remaining number of tokens that `spender` will be
//      * allowed to spend on behalf of `owner` through {transferFrom}. This is
//      * zero by default.
//      *
//      * This value changes when {approve} or {transferFrom} are called.
//      */
//     function allowance(address owner, address spender) external view returns (uint256);

//     /**
//      * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
//      *
//      * Returns a boolean value indicating whether the operation succeeded.
//      *
//      * IMPORTANT: Beware that changing an allowance with this method brings the risk
//      * that someone may use both the old and the new allowance by unfortunate
//      * transaction ordering. One possible solution to mitigate this race
//      * condition is to first reduce the spender's allowance to 0 and set the
//      * desired value afterwards:
//      * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
//      *
//      * Emits an {Approval} event.
//      */
//     function approve(address spender, uint256 amount) external returns (bool);

//     /**
//      * @dev Moves `amount` tokens from `from` to `to` using the
//      * allowance mechanism. `amount` is then deducted from the caller's
//      * allowance.
//      *
//      * Returns a boolean value indicating whether the operation succeeded.
//      *
//      * Emits a {Transfer} event.
//      */
//     function transferFrom(address from, address to, uint256 amount) external returns (bool);
// }


// // File @openzeppelin/contracts/utils/Address.sol@v4.9.6

// // Original license: SPDX_License_Identifier: MIT
// // OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

// pragma solidity ^0.8.1;

// /**
//  * @dev Collection of functions related to the address type
//  */
// library Address {
//     /**
//      * @dev Returns true if `account` is a contract.
//      *
//      * [IMPORTANT]
//      * ====
//      * It is unsafe to assume that an address for which this function returns
//      * false is an externally-owned account (EOA) and not a contract.
//      *
//      * Among others, `isContract` will return false for the following
//      * types of addresses:
//      *
//      *  - an externally-owned account
//      *  - a contract in construction
//      *  - an address where a contract will be created
//      *  - an address where a contract lived, but was destroyed
//      *
//      * Furthermore, `isContract` will also return true if the target contract within
//      * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
//      * which only has an effect at the end of a transaction.
//      * ====
//      *
//      * [IMPORTANT]
//      * ====
//      * You shouldn't rely on `isContract` to protect against flash loan attacks!
//      *
//      * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
//      * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
//      * constructor.
//      * ====
//      */
//     function isContract(address account) internal view returns (bool) {
//         // This method relies on extcodesize/address.code.length, which returns 0
//         // for contracts in construction, since the code is only stored at the end
//         // of the constructor execution.

//         return account.code.length > 0;
//     }

//     /**
//      * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
//      * `recipient`, forwarding all available gas and reverting on errors.
//      *
//      * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
//      * of certain opcodes, possibly making contracts go over the 2300 gas limit
//      * imposed by `transfer`, making them unable to receive funds via
//      * `transfer`. {sendValue} removes this limitation.
//      *
//      * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
//      *
//      * IMPORTANT: because control is transferred to `recipient`, care must be
//      * taken to not create reentrancy vulnerabilities. Consider using
//      * {ReentrancyGuard} or the
//      * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
//      */
//     function sendValue(address payable recipient, uint256 amount) internal {
//         require(address(this).balance >= amount, "Address: insufficient balance");

//         (bool success, ) = recipient.call{value: amount}("");
//         require(success, "Address: unable to send value, recipient may have reverted");
//     }

//     /**
//      * @dev Performs a Solidity function call using a low level `call`. A
//      * plain `call` is an unsafe replacement for a function call: use this
//      * function instead.
//      *
//      * If `target` reverts with a revert reason, it is bubbled up by this
//      * function (like regular Solidity function calls).
//      *
//      * Returns the raw returned data. To convert to the expected return value,
//      * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
//      *
//      * Requirements:
//      *
//      * - `target` must be a contract.
//      * - calling `target` with `data` must not revert.
//      *
//      * _Available since v3.1._
//      */
//     function functionCall(address target, bytes memory data) internal returns (bytes memory) {
//         return functionCallWithValue(target, data, 0, "Address: low-level call failed");
//     }

//     /**
//      * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
//      * `errorMessage` as a fallback revert reason when `target` reverts.
//      *
//      * _Available since v3.1._
//      */
//     function functionCall(
//         address target,
//         bytes memory data,
//         string memory errorMessage
//     ) internal returns (bytes memory) {
//         return functionCallWithValue(target, data, 0, errorMessage);
//     }

//     /**
//      * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
//      * but also transferring `value` wei to `target`.
//      *
//      * Requirements:
//      *
//      * - the calling contract must have an ETH balance of at least `value`.
//      * - the called Solidity function must be `payable`.
//      *
//      * _Available since v3.1._
//      */
//     function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
//         return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
//     }

//     /**
//      * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
//      * with `errorMessage` as a fallback revert reason when `target` reverts.
//      *
//      * _Available since v3.1._
//      */
//     function functionCallWithValue(
//         address target,
//         bytes memory data,
//         uint256 value,
//         string memory errorMessage
//     ) internal returns (bytes memory) {
//         require(address(this).balance >= value, "Address: insufficient balance for call");
//         (bool success, bytes memory returndata) = target.call{value: value}(data);
//         return verifyCallResultFromTarget(target, success, returndata, errorMessage);
//     }

//     /**
//      * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
//      * but performing a static call.
//      *
//      * _Available since v3.3._
//      */
//     function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
//         return functionStaticCall(target, data, "Address: low-level static call failed");
//     }

//     /**
//      * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
//      * but performing a static call.
//      *
//      * _Available since v3.3._
//      */
//     function functionStaticCall(
//         address target,
//         bytes memory data,
//         string memory errorMessage
//     ) internal view returns (bytes memory) {
//         (bool success, bytes memory returndata) = target.staticcall(data);
//         return verifyCallResultFromTarget(target, success, returndata, errorMessage);
//     }

//     /**
//      * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
//      * but performing a delegate call.
//      *
//      * _Available since v3.4._
//      */
//     function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
//         return functionDelegateCall(target, data, "Address: low-level delegate call failed");
//     }

//     /**
//      * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
//      * but performing a delegate call.
//      *
//      * _Available since v3.4._
//      */
//     function functionDelegateCall(
//         address target,
//         bytes memory data,
//         string memory errorMessage
//     ) internal returns (bytes memory) {
//         (bool success, bytes memory returndata) = target.delegatecall(data);
//         return verifyCallResultFromTarget(target, success, returndata, errorMessage);
//     }

//     /**
//      * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
//      * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
//      *
//      * _Available since v4.8._
//      */
//     function verifyCallResultFromTarget(
//         address target,
//         bool success,
//         bytes memory returndata,
//         string memory errorMessage
//     ) internal view returns (bytes memory) {
//         if (success) {
//             if (returndata.length == 0) {
//                 // only check isContract if the call was successful and the return data is empty
//                 // otherwise we already know that it was a contract
//                 require(isContract(target), "Address: call to non-contract");
//             }
//             return returndata;
//         } else {
//             _revert(returndata, errorMessage);
//         }
//     }

//     /**
//      * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
//      * revert reason or using the provided one.
//      *
//      * _Available since v4.3._
//      */
//     function verifyCallResult(
//         bool success,
//         bytes memory returndata,
//         string memory errorMessage
//     ) internal pure returns (bytes memory) {
//         if (success) {
//             return returndata;
//         } else {
//             _revert(returndata, errorMessage);
//         }
//     }

//     function _revert(bytes memory returndata, string memory errorMessage) private pure {
//         // Look for revert reason and bubble it up if present
//         if (returndata.length > 0) {
//             // The easiest way to bubble the revert reason is using memory via assembly
//             /// @solidity memory-safe-assembly
//             assembly {
//                 let returndata_size := mload(returndata)
//                 revert(add(32, returndata), returndata_size)
//             }
//         } else {
//             revert(errorMessage);
//         }
//     }
// }


// // File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v4.9.6

// // Original license: SPDX_License_Identifier: MIT
// // OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

// pragma solidity ^0.8.0;



// /**
//  * @title SafeERC20
//  * @dev Wrappers around ERC20 operations that throw on failure (when the token
//  * contract returns false). Tokens that return no value (and instead revert or
//  * throw on failure) are also supported, non-reverting calls are assumed to be
//  * successful.
//  * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
//  * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
//  */
// library SafeERC20 {
//     using Address for address;

//     /**
//      * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
//      * non-reverting calls are assumed to be successful.
//      */
//     function safeTransfer(IERC20 token, address to, uint256 value) internal {
//         _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
//     }

//     /**
//      * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
//      * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
//      */
//     function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
//         _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
//     }

//     /**
//      * @dev Deprecated. This function has issues similar to the ones found in
//      * {IERC20-approve}, and its usage is discouraged.
//      *
//      * Whenever possible, use {safeIncreaseAllowance} and
//      * {safeDecreaseAllowance} instead.
//      */
//     function safeApprove(IERC20 token, address spender, uint256 value) internal {
//         // safeApprove should only be called when setting an initial allowance,
//         // or when resetting it to zero. To increase and decrease it, use
//         // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
//         require(
//             (value == 0) || (token.allowance(address(this), spender) == 0),
//             "SafeERC20: approve from non-zero to non-zero allowance"
//         );
//         _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
//     }

//     /**
//      * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
//      * non-reverting calls are assumed to be successful.
//      */
//     function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
//         uint256 oldAllowance = token.allowance(address(this), spender);
//         _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
//     }

//     /**
//      * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
//      * non-reverting calls are assumed to be successful.
//      */
//     function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
//         unchecked {
//             uint256 oldAllowance = token.allowance(address(this), spender);
//             require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
//             _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
//         }
//     }

//     /**
//      * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
//      * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
//      * to be set to zero before setting it to a non-zero value, such as USDT.
//      */
//     function forceApprove(IERC20 token, address spender, uint256 value) internal {
//         bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

//         if (!_callOptionalReturnBool(token, approvalCall)) {
//             _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
//             _callOptionalReturn(token, approvalCall);
//         }
//     }

//     /**
//      * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
//      * Revert on invalid signature.
//      */
//     function safePermit(
//         IERC20Permit token,
//         address owner,
//         address spender,
//         uint256 value,
//         uint256 deadline,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) internal {
//         uint256 nonceBefore = token.nonces(owner);
//         token.permit(owner, spender, value, deadline, v, r, s);
//         uint256 nonceAfter = token.nonces(owner);
//         require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
//     }

//     /**
//      * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
//      * on the return value: the return value is optional (but if data is returned, it must not be false).
//      * @param token The token targeted by the call.
//      * @param data The call data (encoded using abi.encode or one of its variants).
//      */
//     function _callOptionalReturn(IERC20 token, bytes memory data) private {
//         // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
//         // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
//         // the target address contains contract code and also asserts for success in the low-level call.

//         bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
//         require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
//     }

//     /**
//      * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
//      * on the return value: the return value is optional (but if data is returned, it must not be false).
//      * @param token The token targeted by the call.
//      * @param data The call data (encoded using abi.encode or one of its variants).
//      *
//      * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
//      */
//     function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
//         // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
//         // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
//         // and not revert is the subcall reverts.

//         (bool success, bytes memory returndata) = address(token).call(data);
//         return
//             success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
//     }
// }


// // File access/JDSCOwnable.sol

// /**
//  * SPDX-License-Identifier: MIT
//  *
//  * Copyright (c) 2018 zOS Global Limited.
//  * Copyright (c) 2018-2020 CENTRE SECZ
//  *
//  * Permission is hereby granted, free of charge, to any person obtaining a copy
//  * of this software and associated documentation files (the "Software"), to deal
//  * in the Software without restriction, including without limitation the rights
//  * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  * copies of the Software, and to permit persons to whom the Software is
//  * furnished to do so, subject to the following conditions:
//  *
//  * The above copyright notice and this permission notice shall be included in
//  * copies or substantial portions of the Software.
//  *
//  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  * SOFTWARE.
//  */

// pragma solidity ^0.8.0;

// // import { Ownable } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.3/contracts/access/Ownable.sol";

// abstract contract JDSCOwnable is Ownable {

//     /**
//      * @dev The constructor sets the original owner of the contract to the sender account.
//      */
//     // constructor() {
//     // }

//     constructor() Ownable() {
        
//     }

//     // constructor() Ownable(msg.sender) {
        
//     // }
    
//     /**
//      * @dev Tells the address of the owner
//      * @return the address of the owner
//      */
//     function getOwner() internal view returns (address) {
//         return owner();
//     }

//     /**
//      * @dev Sets a new owner address
//      */
//     function setOwner(address newOwner) internal {
//         require(newOwner != address(0), "JDSCOwnable: new owner is the zero address");
//         _transferOwnership(newOwner);
//     }
// }


// // File access/blacklist/Blacklistable.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;

// /**
//  * @title Blacklistable Token
//  * @dev Allows accounts to be blacklisted by a "blacklister" role
//  */
// abstract contract Blacklistable is JDSCOwnable {
//     address public blacklister;

//     event Blacklisted(address indexed _account);
//     event UnBlacklisted(address indexed _account);
//     event BlacklisterChanged(address indexed newBlacklister);

//     /**
//      * @dev Throws if called by any account other than the blacklister.
//      */
//     modifier onlyBlacklister() {
//         require(
//             msg.sender == blacklister,
//             "Blacklistable: caller is not the blacklister"
//         );
//         _;
//     }

//     /**
//      * @dev Throws if argument account is blacklisted.
//      * @param _account The address to check.
//      */
//     modifier notBlacklisted(address _account) {
//         require(
//             !_isBlacklisted(_account),
//             "Blacklistable: account is blacklisted"
//         );
//         _;
//     }

//     /**
//      * @notice Checks if account is blacklisted.
//      * @param _account The address to check.
//      * @return True if the account is blacklisted, false if the account is not blacklisted.
//      */
//     function isBlacklisted(address _account) external view returns (bool) {
//         return _isBlacklisted(_account);
//     }

//     /**
//      * @notice Adds account to blacklist.
//      * @param _account The address to blacklist.
//      */
//     function blacklist(address _account) external onlyBlacklister {
//         _blacklist(_account);
//         emit Blacklisted(_account);
//     }

//     /**
//      * @notice Removes account from blacklist.
//      * @param _account The address to remove from the blacklist.
//      */
//     function unBlacklist(address _account) external onlyBlacklister {
//         _unBlacklist(_account);
//         emit UnBlacklisted(_account);
//     }

//     /**
//      * @notice Updates the blacklister address.
//      * @param _newBlacklister The address of the new blacklister.
//      */
//     function updateBlacklister(address _newBlacklister) external onlyOwner {
//         require(
//             _newBlacklister != address(0),
//             "Blacklistable: new blacklister is the zero address"
//         );
//         blacklister = _newBlacklister;
//         emit BlacklisterChanged(blacklister);
//     }

//     /**
//      * @dev Checks if account is blacklisted.
//      * @param _account The address to check.
//      * @return true if the account is blacklisted, false otherwise.
//      */
//     function _isBlacklisted(address _account)
//         internal
//         virtual
//         view
//         returns (bool);

//     /**
//      * @dev Helper method that blacklists an account.
//      * @param _account The address to blacklist.
//      */
//     function _blacklist(address _account) internal virtual;

//     /**
//      * @dev Helper method that unblacklists an account.
//      * @param _account The address to unblacklist.
//      */
//     function _unBlacklist(address _account) internal virtual;
// }


// // File access/whitelist/Whitelistable.sol

// /**
//  * SPDX-License-Identifier: MIT
//  *
//  * Copyright (c) 2018 zOS Global Limited.
//  * Copyright (c) 2018-2020 CENTRE SECZ
//  *
//  * Permission is hereby granted, free of charge, to any person obtaining a copy
//  * of this software and associated documentation files (the "Software"), to deal
//  * in the Software without restriction, including without limitation the rights
//  * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  * copies of the Software, and to permit persons to whom the Software is
//  * furnished to do so, subject to the following conditions:
//  *
//  * The above copyright notice and this permission notice shall be included in
//  * copies or substantial portions of the Software.
//  *
//  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  * SOFTWARE.
//  */


// pragma solidity ^0.8.0;

// /**
//  * @title Whitelistable Token
//  * @dev Allows accounts to be whitelisted by a "whitelister" role
//  */
// abstract contract Whitelistable is JDSCOwnable {
//     address public whitelister;
//     // mapping(address => bool) internal _deprecatedWhitelisted;

//     event Whitelisted(address indexed _account);
//     event UnWhitelisted(address indexed _account);
//     event WhitelisterChanged(address indexed newWhitelister);

//     /**
//      * @dev Throws if called by any account other than the whitelister.
//      */
//     modifier onlyWhitelister() {
//         require(
//             msg.sender == whitelister,
//             "Whitelistable: caller is not the whitelister"
//         );
//         _;
//     }

//     /**
//      * @dev Throws if argument account is whitelister.
//      * @param _account The address to check.
//      */
//     modifier notWhitelisted(address _account) {
//         require(
//             !_isWhitelisted(_account),
//             "Whitelistable: account is whitelisted"
//         );
//         _;
//     }

//     /**
//      * @dev Throws if argument account is whitelister.
//      * @param _account The address to check.
//      */
//     modifier isAddressWhitelisted(address _account) {
//         require(
//             _isWhitelisted(_account),
//             "Whitelistable: account is not the whitelisted"
//         );
//         _;
//     }

//     /**
//      * @notice Checks if account is whitelisted.
//      * @param _account The address to check.
//      * @return True if the account is whitelisted, false if the account is not whitelisted.
//      */
//     function isWhitelisted(address _account) external view returns (bool) {
//         return _isWhitelisted(_account);
//     }

//     /**
//      * @notice Adds account to whitelist.
//      * @param _account The address to whitelist.
//      */
//     function whitelist(address _account) external onlyWhitelister {
//         _whitelist(_account);
//         emit Whitelisted(_account);
//     }

//     /**
//      * @notice Removes account from whitelist.
//      * @param _account The address to remove from the whitelist.
//      */
//     function unWhitelist(address _account) external onlyWhitelister {
//         _unWhitelist(_account);
//         emit UnWhitelisted(_account);
//     }

//     /**
//      * @notice Updates the whitelister address.
//      * @param _newWhitelister The address of the new whitelister.
//      */
//     function updateWhitelister(address _newWhitelister) external onlyOwner {
//         require(
//             _newWhitelister != address(0),
//             "Whitelistable: new whitelister is the zero address"
//         );
//         whitelister = _newWhitelister;
//         emit WhitelisterChanged(whitelister);
//     }

//     /**
//      * @dev Checks if account is whitelisted.
//      * @param _account The address to check.
//      * @return true if the account is whitelisted, false otherwise.
//      */
//     function _isWhitelisted(address _account)
//         internal
//         virtual
//         view
//         returns (bool);

//     /**
//      * @dev Helper method that whitelists an account.
//      * @param _account The address to whitelist.
//      */
//     function _whitelist(address _account) internal virtual;

//     /**
//      * @dev Helper method that unwhitelists an account.
//      * @param _account The address to unwhitelist.
//      */
//     function _unWhitelist(address _account) internal virtual;
// }


// // File eip/EIP712Domain.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;

// // solhint-disable func-name-mixedcase

// /**
//  * @title EIP712 Domain
//  */
// contract EIP712Domain {
//     // was originally DOMAIN_SEPARATOR
//     // but that has been moved to a method so we can override it in V2_2+
//     // bytes32 public _DEPRECATED_CACHED_DOMAIN_SEPARATOR;
//     bytes32 internal _DEPRECATED_CACHED_DOMAIN_SEPARATOR;

//     /**
//      * @notice Get the EIP712 Domain Separator.
//      * @return The bytes32 EIP712 domain separator.
//      */
//     function DOMAIN_SEPARATOR() external view returns (bytes32) {
//         return _domainSeparator();
//     }

//     /**
//      * @dev Internal method to get the EIP712 Domain Separator.
//      * @return The bytes32 EIP712 domain separator.
//      */
//     function _domainSeparator() internal virtual view returns (bytes32) {
//         return _DEPRECATED_CACHED_DOMAIN_SEPARATOR;
//     }
// }


// // File erc20/extensions/ERC20Approve.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;

// // import { IERC20 } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.3/contracts/token/ERC20/IERC20.sol";


// abstract contract ERC20Approve is IERC20 {
//     function _approve(
//         address owner,
//         address spender,
//         uint256 value
//     ) internal virtual;
// }


// // File util/MessageHashUtils.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;

// /**
//  * @dev Signature message hash utilities for producing digests to be consumed by {ECDSA} recovery or signing.
//  *
//  * The library provides methods for generating a hash of a message that conforms to the
//  * https://eips.ethereum.org/EIPS/eip-191[EIP 191] and https://eips.ethereum.org/EIPS/eip-712[EIP 712]
//  * specifications.
//  */
// library MessageHashUtils {
//     /**
//      * @dev Returns the keccak256 digest of an EIP-712 typed data (EIP-191 version `0x01`).
//      * Adapted from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/21bb89ef5bfc789b9333eb05e3ba2b7b284ac77c/contracts/utils/cryptography/MessageHashUtils.sol
//      *
//      * The digest is calculated from a `domainSeparator` and a `structHash`, by prefixing them with
//      * `\x19\x01` and hashing the result. It corresponds to the hash signed by the
//      * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] JSON-RPC method as part of EIP-712.
//      *
//      * @param domainSeparator    Domain separator
//      * @param structHash         Hashed EIP-712 data struct
//      * @return digest            The keccak256 digest of an EIP-712 typed data
//      */
//     function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash)
//         internal
//         pure
//         returns (bytes32 digest)
//     {
//         assembly {
//             let ptr := mload(0x40)
//             mstore(ptr, "\x19\x01")
//             mstore(add(ptr, 0x02), domainSeparator)
//             mstore(add(ptr, 0x22), structHash)
//             digest := keccak256(ptr, 0x42)
//         }
//     }
// }


// // File interface/IERC1271.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;

// /**
//  * @dev Interface of the ERC1271 standard signature validation method for
//  * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
//  */
// interface IERC1271 {
//     /**
//      * @dev Should return whether the signature provided is valid for the provided data
//      * @param hash          Hash of the data to be signed
//      * @param signature     Signature byte array associated with the provided data hash
//      * @return magicValue   bytes4 magic value 0x1626ba7e when function passes
//      */
//     function isValidSignature(bytes32 hash, bytes memory signature)
//         external
//         view
//         returns (bytes4 magicValue);
// }


// // File util/ECRecover.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;

// /**
//  * @title ECRecover
//  * @notice A library that provides a safe ECDSA recovery function
//  */
// library ECRecover {
//     /**
//      * @notice Recover signer's address from a signed message
//      * @dev Adapted from: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/65e4ffde586ec89af3b7e9140bdc9235d1254853/contracts/cryptography/ECDSA.sol
//      * Modifications: Accept v, r, and s as separate arguments
//      * @param digest    Keccak-256 hash digest of the signed message
//      * @param v         v of the signature
//      * @param r         r of the signature
//      * @param s         s of the signature
//      * @return Signer address
//      */
//     function recover(
//         bytes32 digest,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) internal pure returns (address) {
//         // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
//         // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
//         // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
//         // signatures from current libraries generate a unique signature with an s-value in the lower half order.
//         //
//         // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
//         // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
//         // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
//         // these malleable signatures as well.
//         if (
//             uint256(s) >
//             0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
//         ) {
//             revert("ECRecover: invalid signature 's' value");
//         }

//         if (v != 27 && v != 28) {
//             revert("ECRecover: invalid signature 'v' value");
//         }

//         // If the signature is valid (and not malleable), return the signer address
//         address signer = ecrecover(digest, v, r, s);
//         require(signer != address(0), "ECRecover: invalid signature");

//         return signer;
//     }

//     /**
//      * @notice Recover signer's address from a signed message
//      * @dev Adapted from: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/0053ee040a7ff1dbc39691c9e67a69f564930a88/contracts/utils/cryptography/ECDSA.sol
//      * @param digest    Keccak-256 hash digest of the signed message
//      * @param signature Signature byte array associated with hash
//      * @return Signer address
//      */
//     function recover(bytes32 digest, bytes memory signature)
//         internal
//         pure
//         returns (address)
//     {
//         require(signature.length == 65, "ECRecover: invalid signature length");

//         bytes32 r;
//         bytes32 s;
//         uint8 v;

//         // ecrecover takes the signature parameters, and the only way to get them
//         // currently is to use assembly.
//         /// @solidity memory-safe-assembly
//         assembly {
//             r := mload(add(signature, 0x20))
//             s := mload(add(signature, 0x40))
//             v := byte(0, mload(add(signature, 0x60)))
//         }
//         return recover(digest, v, r, s);
//     }
// }


// // File util/SignatureChecker.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;


// /**
//  * @dev Signature verification helper that can be used instead of `ECRecover.recover` to seamlessly support both ECDSA
//  * signatures from externally owned accounts (EOAs) as well as ERC1271 signatures from smart contract wallets.
//  *
//  * Adapted from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/21bb89ef5bfc789b9333eb05e3ba2b7b284ac77c/contracts/utils/cryptography/SignatureChecker.sol
//  */
// library SignatureChecker {
//     /**
//      * @dev Checks if a signature is valid for a given signer and data hash. If the signer is a smart contract, the
//      * signature is validated against that smart contract using ERC1271, otherwise it's validated using `ECRecover.recover`.
//      * @param signer        Address of the claimed signer
//      * @param digest        Keccak-256 hash digest of the signed message
//      * @param signature     Signature byte array associated with hash
//      */
//     function isValidSignatureNow(
//         address signer,
//         bytes32 digest,
//         bytes memory signature
//     ) external view returns (bool) {
//         if (!isContract(signer)) {
//             return ECRecover.recover(digest, signature) == signer;
//         }
//         return isValidERC1271SignatureNow(signer, digest, signature);
//     }

//     /**
//      * @dev Checks if a signature is valid for a given signer and data hash. The signature is validated
//      * against the signer smart contract using ERC1271.
//      * @param signer        Address of the claimed signer
//      * @param digest        Keccak-256 hash digest of the signed message
//      * @param signature     Signature byte array associated with hash
//      *
//      * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
//      * change through time. It could return true at block N and false at block N+1 (or the opposite).
//      */
//     function isValidERC1271SignatureNow(
//         address signer,
//         bytes32 digest,
//         bytes memory signature
//     ) internal view returns (bool) {
//         (bool success, bytes memory result) = signer.staticcall(
//             abi.encodeWithSelector(
//                 IERC1271.isValidSignature.selector,
//                 digest,
//                 signature
//             )
//         );
//         return (success &&
//             result.length >= 32 &&
//             abi.decode(result, (bytes32)) ==
//             bytes32(IERC1271.isValidSignature.selector));
//     }

//     /**
//      * @dev Checks if the input address is a smart contract.
//      */
//     function isContract(address addr) internal view returns (bool) {
//         uint256 size;
//         assembly {
//             size := extcodesize(addr)
//         }
//         return size > 0;
//     }
// }


// // File eip/EIP2612.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;



// // import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

// /**
//  * @title EIP-2612
//  * @notice Provide internal implementation for gas-abstracted approvals
//  */
// abstract contract EIP2612 is ERC20Approve, EIP712Domain {
// // abstract contract EIP2612 is AbstractJDSCTokenV2, EIP712Domain {
//     // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")
//     bytes32
//         public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

//     mapping(address => uint256) private _permitNonces;

//     /**
//      * @notice Nonces for permit
//      * @param owner Token owner's address (Authorizer)
//      * @return Next nonce
//      */
//     function nonces(address owner) external view returns (uint256) {
//         return _permitNonces[owner];
//     }

//     /**
//      * @notice Verify a signed approval permit and execute if valid
//      * @param owner     Token owner's address (Authorizer)
//      * @param spender   Spender's address
//      * @param value     Amount of allowance
//      * @param deadline  The time at which the signature expires (unix time), or max uint256 value to signal no expiration
//      * @param v         v of the signature
//      * @param r         r of the signature
//      * @param s         s of the signature
//      */
//     function _permit(
//         address owner,
//         address spender,
//         uint256 value,
//         uint256 deadline,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) internal {
//         _permit(owner, spender, value, deadline, abi.encodePacked(r, s, v));
//     }

//     /**
//      * @notice Verify a signed approval permit and execute if valid
//      * @dev EOA wallet signatures should be packed in the order of r, s, v.
//      * @param owner      Token owner's address (Authorizer)
//      * @param spender    Spender's address
//      * @param value      Amount of allowance
//      * @param deadline   The time at which the signature expires (unix time), or max uint256 value to signal no expiration
//      * @param signature  Signature byte array signed by an EOA wallet or a contract wallet
//      */
//     function _permit(
//         address owner,
//         address spender,
//         uint256 value,
//         uint256 deadline,
//         bytes memory signature
//     ) internal {
//         require(
//             deadline == type(uint256).max || deadline >= block.timestamp,
//             // deadline == type(uint256).max || deadline >= now,
//             "JDSCTokenV2: permit is expired"
//         );

//         bytes32 typedDataHash = MessageHashUtils.toTypedDataHash(
//             _domainSeparator(),
//             keccak256(
//                 abi.encode(
//                     PERMIT_TYPEHASH,
//                     owner,
//                     spender,
//                     value,
//                     _permitNonces[owner]++,
//                     deadline
//                 )
//             )
//         );
//         require(
//             SignatureChecker.isValidSignatureNow(
//                 owner,
//                 typedDataHash,
//                 signature
//             ),
//             "EIP2612: invalid signature"
//         );

//         _approve(owner, spender, value);
//     }
// }


// // File erc20/extensions/ERC20Transferable.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;

// // import { IERC20 } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.3/contracts/token/ERC20/IERC20.sol";


// abstract contract ERC20Transferable is IERC20 {
//     function _transfer(
//         address from,
//         address to,
//         uint256 value
//     ) internal virtual;
// }


// // File eip/EIP3009.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;


// // import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";


// /**
//  * @title EIP-3009
//  * @notice Provide internal implementation for gas-abstracted transfers
//  * @dev Contracts that inherit from this must wrap these with publicly
//  * accessible functions, optionally adding modifiers where necessary
//  */
// abstract contract EIP3009 is ERC20Transferable, EIP712Domain {
// // abstract contract EIP3009 is AbstractJDSCTokenV2, EIP712Domain {
//     // keccak256("TransferWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
//     bytes32
//         public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH = 0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267;
   
// //    // keccak256("TransferWithAuthorizationFee(address feeAccount,address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
// //     bytes32
// //         public constant TRANSFER_WITH_AUTHORIZATIONFEE_TYPEHASH = 0xf2186bca5887655aea9842bc3b7af9783edb339d7b7b87d9876505703fd4dc67;

//     // keccak256("ReceiveWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
//     bytes32
//         public constant RECEIVE_WITH_AUTHORIZATION_TYPEHASH = 0xd099cc98ef71107a616c4f0f941f04c322d8e254fe26b3c6668db87aae413de8;

//     // keccak256("CancelAuthorization(address authorizer,bytes32 nonce)")
//     bytes32
//         public constant CANCEL_AUTHORIZATION_TYPEHASH = 0x158b0a9edf7a828aad02f63cd515c68ef2f50ba807396f6d12842833a1597429;

//     /**
//      * @dev authorizer address => nonce => bool (true if nonce is used)
//      */
//     mapping(address => mapping(bytes32 => bool)) private _authorizationStates;

//     // event TransferWithAuthorizationEvent(
//     //     address from,
//     //     address to,
//     //     uint256 value,
//     //     uint256 validAfter,
//     //     uint256 validBefore,
//     //     bytes32 nonce,
//     //     bytes signature);

//     // event RequireValidSignatureEvent(
//     //     address signer,
//     //     bytes32 dataHash,
//     //     bytes signature,
//     //     bytes32 domain
//     // );

//     event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
//     event AuthorizationCanceled(
//         address indexed authorizer,
//         bytes32 indexed nonce
//     );

//     // /**
//     //  * @notice Returns the state of an authorization
//     //  * @dev Nonces are randomly generated 32-byte data unique to the
//     //  * authorizer's address
//     //  * @param authorizer    Authorizer's address
//     //  * @param nonce         Nonce of the authorization
//     //  * @return True if the nonce is used
//     //  */
//     // function authorizationState(address authorizer, bytes32 nonce)
//     //     external
//     //     view
//     //     returns (bool)
//     // {
//     //     return _authorizationStates[authorizer][nonce];
//     // }

//     /**
//      * @notice Execute a transfer with a signed authorization
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
//     function _transferWithAuthorization(
//         address from,
//         address to,
//         uint256 value,
//         uint256 validAfter,
//         uint256 validBefore,
//         bytes32 nonce,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) internal {
//         _transferWithAuthorization(
//             from,
//             to,
//             value,
//             validAfter,
//             validBefore,
//             nonce,
//             abi.encodePacked(r, s, v)
//         );
//     }

//     /**
//      * @notice Execute a transfer with a signed authorization
//      * @dev EOA wallet signatures should be packed in the order of r, s, v.
//      * @param from          Payer's address (Authorizer)
//      * @param to            Payee's address
//      * @param value         Amount to be transferred
//      * @param validAfter    The time after which this is valid (unix time)
//      * @param validBefore   The time before which this is valid (unix time)
//      * @param nonce         Unique nonce
//      * @param signature     Signature byte array produced by an EOA wallet or a contract wallet
//      */
//     function _transferWithAuthorization(
//         address from,
//         address to,
//         uint256 value,
//         uint256 validAfter,
//         uint256 validBefore,
//         bytes32 nonce,
//         bytes memory signature
//     ) internal {
//         // emit TransferWithAuthorizationEvent(from,to, value, validAfter, validBefore, nonce, signature);
//         _requireValidAuthorization(from, nonce, validAfter, validBefore);
//         _requireValidSignature(
//             from,
//             keccak256(
//                 abi.encode(
//                     TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
//                     from,
//                     to,
//                     value,
//                     validAfter,
//                     validBefore,
//                     nonce
//                 )
//             ),
//             signature
//         );

//         // _markAuthorizationAsUsed(from, nonce);
//         _transfer(from, to, value);
//     }

//     /**
//      * @notice Receive a transfer with a signed authorization from the payer
//      * @dev This has an additional check to ensure that the payee's address
//      * matches the caller of this function to prevent front-running attacks.
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
//     function _receiveWithAuthorization(
//         address from,
//         address to,
//         uint256 value,
//         uint256 validAfter,
//         uint256 validBefore,
//         bytes32 nonce,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) internal {
//         _receiveWithAuthorization(
//             from,
//             to,
//             value,
//             validAfter,
//             validBefore,
//             nonce,
//             abi.encodePacked(r, s, v)
//         );
//     }

//     /**
//      * @notice Receive a transfer with a signed authorization from the payer
//      * @dev This has an additional check to ensure that the payee's address
//      * matches the caller of this function to prevent front-running attacks.
//      * EOA wallet signatures should be packed in the order of r, s, v.
//      * @param from          Payer's address (Authorizer)
//      * @param to            Payee's address
//      * @param value         Amount to be transferred
//      * @param validAfter    The time after which this is valid (unix time)
//      * @param validBefore   The time before which this is valid (unix time)
//      * @param nonce         Unique nonce
//      * @param signature     Signature byte array produced by an EOA wallet or a contract wallet
//      */
//     function _receiveWithAuthorization(
//         address from,
//         address to,
//         uint256 value,
//         uint256 validAfter,
//         uint256 validBefore,
//         bytes32 nonce,
//         bytes memory signature
//     ) internal {
//         require(to == msg.sender, "TokenV2: caller must be the payee");
//         _requireValidAuthorization(from, nonce, validAfter, validBefore);
//         _requireValidSignature(
//             from,
//             keccak256(
//                 abi.encode(
//                     RECEIVE_WITH_AUTHORIZATION_TYPEHASH,
//                     from,
//                     to,
//                     value,
//                     validAfter,
//                     validBefore,
//                     nonce
//                 )
//             ),
//             signature
//         );

//         // _markAuthorizationAsUsed(from, nonce);
//         _transfer(from, to, value);
//     }

//     /**
//      * @notice Attempt to cancel an authorization
//      * @param authorizer    Authorizer's address
//      * @param nonce         Nonce of the authorization
//      * @param v             v of the signature
//      * @param r             r of the signature
//      * @param s             s of the signature
//      */
//     // function _cancelAuthorization(
//     //     address authorizer,
//     //     bytes32 nonce,
//     //     uint8 v,
//     //     bytes32 r,
//     //     bytes32 s
//     // ) internal {
//     //     _cancelAuthorization(authorizer, nonce, abi.encodePacked(r, s, v));
//     // }

//     /**
//      * @notice Attempt to cancel an authorization
//      * @dev EOA wallet signatures should be packed in the order of r, s, v.
//      * @param authorizer    Authorizer's address
//      * @param nonce         Nonce of the authorization
//      * @param signature     Signature byte array produced by an EOA wallet or a contract wallet
//      */
//     // function _cancelAuthorization(
//     //     address authorizer,
//     //     bytes32 nonce,
//     //     bytes memory signature
//     // ) internal {
//     //     _requireUnusedAuthorization(authorizer, nonce);
//     //     _requireValidSignature(
//     //         authorizer,
//     //         keccak256(
//     //             abi.encode(CANCEL_AUTHORIZATION_TYPEHASH, authorizer, nonce)
//     //         ),
//     //         signature
//     //     );

//     //     // _authorizationStates[authorizer][nonce] = true;
//     //     emit AuthorizationCanceled(authorizer, nonce);
//     // }

//     /**
//      * @notice Validates that signature against input data struct
//      * @param signer        Signer's address
//      * @param dataHash      Hash of encoded data struct
//      * @param signature     Signature byte array produced by an EOA wallet or a contract wallet
//      */
//     function _requireValidSignature(
//         address signer,
//         bytes32 dataHash,
//         bytes memory signature
//     // ) private {
//     ) internal view {
//     // ) private view {
//         // bytes32 domain = _domainSeparator();
//         // emit RequireValidSignatureEvent(signer, dataHash, signature, _domainSeparator());
//         require(
//             SignatureChecker.isValidSignatureNow(
//                 signer,
//                 MessageHashUtils.toTypedDataHash(_domainSeparator(), dataHash),
//                 signature
//             ),
//             "JDSCTokenV2: invalid signature"
//         );
//     }

//     // /**
//     //  * @notice Check that an authorization is unused
//     //  * @param authorizer    Authorizer's address
//     //  * @param nonce         Nonce of the authorization
//     //  */
//     // function _requireUnusedAuthorization(address authorizer, bytes32 nonce)
//     //     private
//     //     view
//     // {
//     //     require(
//     //         !_authorizationStates[authorizer][nonce],
//     //         "JDSCTokenV2: authorization is used or canceled"
//     //     );
//     // }

//     /**
//      * @notice Check that authorization is valid
//      * @param authorizer    Authorizer's address
//      * @param nonce         Nonce of the authorization
//      * @param validAfter    The time after which this is valid (unix time)
//      * @param validBefore   The time before which this is valid (unix time)
//      */
//     function _requireValidAuthorization(
//         address authorizer,
//         bytes32 nonce,
//         uint256 validAfter,
//         uint256 validBefore
//     ) internal view {
//     // ) private view {
//         require(
//             block.timestamp > validAfter,
//             // now > validAfter,
//             "JDSCTokenV2: authorization is not yet valid"
//         );
//         require(block.timestamp < validBefore, "JDSCTokenV2: authorization is expired");
//         // require(now < validBefore, "JDSCTokenV2: authorization is expired");
//         // _requireUnusedAuthorization(authorizer, nonce);
//     }

//     // /**
//     //  * @notice Mark an authorization as used
//     //  * @param authorizer    Authorizer's address
//     //  * @param nonce         Nonce of the authorization
//     //  */
//     // function _markAuthorizationAsUsed(address authorizer, bytes32 nonce)
//     //     internal
//     //     // private
//     // {
//     //     _authorizationStates[authorizer][nonce] = true;
//     //     emit AuthorizationUsed(authorizer, nonce);
//     // }
// }


// // File erc20/extensions/ERC20Allowable.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;

// // import { IERC20 } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.3/contracts/token/ERC20/IERC20.sol";


// abstract contract ERC20Allowable is IERC20 {
//     function _increaseAllowance(
//         address owner,
//         address spender,
//         uint256 increment
//     ) internal virtual;

//     function _decreaseAllowance(
//         address owner,
//         address spender,
//         uint256 decrement
//     ) internal virtual;
// }


// // File erc20/AbstractJDSCToken.sol

// // Original license: SPDX_License_Identifier: Apache-2.0


// pragma solidity ^0.8.0;



// abstract contract AbstractJDSCToken is ERC20Allowable, ERC20Approve, ERC20Transferable {
    
// }


// // File @openzeppelin/contracts/utils/math/SafeMath.sol@v4.9.6

// // Original license: SPDX_License_Identifier: MIT
// // OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

// pragma solidity ^0.8.0;

// // CAUTION
// // This version of SafeMath should only be used with Solidity 0.8 or later,
// // because it relies on the compiler's built in overflow checks.

// /**
//  * @dev Wrappers over Solidity's arithmetic operations.
//  *
//  * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
//  * now has built in overflow checking.
//  */
// library SafeMath {
//     /**
//      * @dev Returns the addition of two unsigned integers, with an overflow flag.
//      *
//      * _Available since v3.4._
//      */
//     function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
//         unchecked {
//             uint256 c = a + b;
//             if (c < a) return (false, 0);
//             return (true, c);
//         }
//     }

//     /**
//      * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
//      *
//      * _Available since v3.4._
//      */
//     function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
//         unchecked {
//             if (b > a) return (false, 0);
//             return (true, a - b);
//         }
//     }

//     /**
//      * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
//      *
//      * _Available since v3.4._
//      */
//     function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
//         unchecked {
//             // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
//             // benefit is lost if 'b' is also tested.
//             // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
//             if (a == 0) return (true, 0);
//             uint256 c = a * b;
//             if (c / a != b) return (false, 0);
//             return (true, c);
//         }
//     }

//     /**
//      * @dev Returns the division of two unsigned integers, with a division by zero flag.
//      *
//      * _Available since v3.4._
//      */
//     function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
//         unchecked {
//             if (b == 0) return (false, 0);
//             return (true, a / b);
//         }
//     }

//     /**
//      * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
//      *
//      * _Available since v3.4._
//      */
//     function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
//         unchecked {
//             if (b == 0) return (false, 0);
//             return (true, a % b);
//         }
//     }

//     /**
//      * @dev Returns the addition of two unsigned integers, reverting on
//      * overflow.
//      *
//      * Counterpart to Solidity's `+` operator.
//      *
//      * Requirements:
//      *
//      * - Addition cannot overflow.
//      */
//     function add(uint256 a, uint256 b) internal pure returns (uint256) {
//         return a + b;
//     }

//     /**
//      * @dev Returns the subtraction of two unsigned integers, reverting on
//      * overflow (when the result is negative).
//      *
//      * Counterpart to Solidity's `-` operator.
//      *
//      * Requirements:
//      *
//      * - Subtraction cannot overflow.
//      */
//     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
//         return a - b;
//     }

//     /**
//      * @dev Returns the multiplication of two unsigned integers, reverting on
//      * overflow.
//      *
//      * Counterpart to Solidity's `*` operator.
//      *
//      * Requirements:
//      *
//      * - Multiplication cannot overflow.
//      */
//     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
//         return a * b;
//     }

//     /**
//      * @dev Returns the integer division of two unsigned integers, reverting on
//      * division by zero. The result is rounded towards zero.
//      *
//      * Counterpart to Solidity's `/` operator.
//      *
//      * Requirements:
//      *
//      * - The divisor cannot be zero.
//      */
//     function div(uint256 a, uint256 b) internal pure returns (uint256) {
//         return a / b;
//     }

//     /**
//      * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
//      * reverting when dividing by zero.
//      *
//      * Counterpart to Solidity's `%` operator. This function uses a `revert`
//      * opcode (which leaves remaining gas untouched) while Solidity uses an
//      * invalid opcode to revert (consuming all remaining gas).
//      *
//      * Requirements:
//      *
//      * - The divisor cannot be zero.
//      */
//     function mod(uint256 a, uint256 b) internal pure returns (uint256) {
//         return a % b;
//     }

//     /**
//      * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
//      * overflow (when the result is negative).
//      *
//      * CAUTION: This function is deprecated because it requires allocating memory for the error
//      * message unnecessarily. For custom revert reasons use {trySub}.
//      *
//      * Counterpart to Solidity's `-` operator.
//      *
//      * Requirements:
//      *
//      * - Subtraction cannot overflow.
//      */
//     function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
//         unchecked {
//             require(b <= a, errorMessage);
//             return a - b;
//         }
//     }

//     /**
//      * @dev Returns the integer division of two unsigned integers, reverting with custom message on
//      * division by zero. The result is rounded towards zero.
//      *
//      * Counterpart to Solidity's `/` operator. Note: this function uses a
//      * `revert` opcode (which leaves remaining gas untouched) while Solidity
//      * uses an invalid opcode to revert (consuming all remaining gas).
//      *
//      * Requirements:
//      *
//      * - The divisor cannot be zero.
//      */
//     function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
//         unchecked {
//             require(b > 0, errorMessage);
//             return a / b;
//         }
//     }

//     /**
//      * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
//      * reverting with custom message when dividing by zero.
//      *
//      * CAUTION: This function is deprecated because it requires allocating memory for the error
//      * message unnecessarily. For custom revert reasons use {tryMod}.
//      *
//      * Counterpart to Solidity's `%` operator. This function uses a `revert`
//      * opcode (which leaves remaining gas untouched) while Solidity uses an
//      * invalid opcode to revert (consuming all remaining gas).
//      *
//      * Requirements:
//      *
//      * - The divisor cannot be zero.
//      */
//     function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
//         unchecked {
//             require(b > 0, errorMessage);
//             return a % b;
//         }
//     }
// }


// // File eip/EIP712.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;

// /**
//  * @title EIP712
//  * @notice A library that provides EIP712 helper functions
//  */
// library EIP712 {
//     /**
//      * @notice Make EIP712 domain separator
//      * @param name      Contract name
//      * @param version   Contract version
//      * @param chainId   Blockchain ID
//      * @return Domain separator
//      */
//     function makeDomainSeparator(
//         string memory name,
//         string memory version,
//         uint256 chainId
//     ) internal view returns (bytes32) {
//         return
//             keccak256(
//                 abi.encode(
//                     // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
//                     0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
//                     keccak256(bytes(name)),
//                     keccak256(bytes(version)),
//                     chainId,
//                     address(this)
//                 )
//             );
//     }

//     /**
//      * @notice Make EIP712 domain separator
//      * @param name      Contract name
//      * @param version   Contract version
//      * @return Domain separator
//      */
//     function makeDomainSeparator(string memory name, string memory version)
//         internal
//         view
//         returns (bytes32)
//     {
//         uint256 chainId;
//         assembly {
//             chainId := chainid()
//         }
//         return makeDomainSeparator(name, version, chainId);
//     }


//     // function PudomainSeparator() internal virtual view returns (bytes32) {
//     //     return makeDomainSeparator(
//     //         "jdscToken",
//     //         "1"
//     //     );
//     // }
// }


// // File erc20/AbstractJDSCTokenFee.sol

// // Original license: SPDX_License_Identifier: Apache-2.0


// pragma solidity ^0.8.0;


// abstract contract AbstractJDSCTokenFee {

//     // Additional variables for use if transaction fees ever became necessary
//     uint256 public basisPointsRate = 0;
//     uint256 public maximumFee = 0;
//     uint256 constant MAX_SETTABLE_BASIS_POINTS = 20;
//     uint256 constant MAX_SETTABLE_FEE = 5000 * 1e2;

//     uint public constant MAX_UINT = 2**256 - 1;

//     mapping(address => uint256) public feeAccounts;

//     mapping(address => uint256) public feeRateAccounts;

//     address[] public feeAccountKeys;

//     event Params(uint feeBasisPoints, uint maxFee);

//     event TransferFee(address indexed from,address indexed to,uint256 value,bytes orderId);

//     event TransferWithSign(address indexed from,address indexed to,bytes32 indexed nonce,bytes orderId,uint256 value,uint256 validAfter,uint256 validBefore);

//     event TransferWithRSV(address indexed from,address indexed to,bytes32 indexed nonce,bytes orderId,uint256 value,uint256 validAfter,uint256 validBefore);
    
//     struct TransferAuthStruct {
//         address feeAccount;
//         address from;
//         address to;
//         bytes32 nonce;
//         uint256 value;
//         uint256 validAfter;
//         uint256 validBefore;
//         bytes signature;
//         bytes orderId;
//     }

//     struct TransferWithAuthorizationFeeRSV {
//         address feeAccount;
//         address from;
//         address to;
//         bytes32 nonce;
//         bytes orderId;
//         uint256 value;
//         uint256 validAfter;
//         uint256 validBefore;
//         uint8 v;
//         bytes32 r;
//         bytes32 s;
//     }

//     struct SendAmountFeeStruct {
//         uint256 balance;
//         uint256 value;
//         uint256 fee;
//     }

//     function setParams(uint newBasisPoints, uint newMaxFee) external virtual returns (bool);

//     function calcCommonFee(uint256 _value) external virtual view returns (uint256);

//     function calcFee(address account, uint256 _value) external virtual view returns (uint256);
    
//     // function calcSendAmount(uint256 _balance, uint256 _fee, uint256 _value) public virtual pure returns (uint256 amount, uint256 fee);
    
//     function totalFee(address _account) external virtual view returns (uint256);

//     function addFeeAccount(address account) public {
//         uint256 amount = 0;
//         feeAccounts[account] = amount;

//         uint256 newBasisPoints =  0;
//         feeRateAccounts[account] = newBasisPoints;
//         if (!contains(account)) {
//             feeAccountKeys.push(account);
//         }
//     }

//     function contains(address account) internal view returns (bool) {
//         for (uint256 i = 0; i < feeAccountKeys.length; i++) {
//             if (feeAccountKeys[i] == account) {
//                 return true;
//             }
//         }
//         return false;
//     }

//     function updateFeeAccountAmount(address account, uint256 amount) public {
//         uint256 oldAmount = feeAccounts[account];
//         uint256 newAmount = oldAmount + amount;
//         feeAccounts[account] = newAmount;
//     }

//     function removeFeeAccount(address account) public {
//         delete feeAccounts[account];
//         for (uint256 i = 0; i < feeAccountKeys.length; i++) {
//             if (feeAccountKeys[i] == account) {
//                 delete feeAccountKeys[i];
//                 break;
//             }
//         }
//     }

//     function getFeeAccounts() external view returns (address[] memory) {
//         return feeAccountKeys;
//     }


//     function setAccountBasisPointsRate(address account ,uint newBasisPoints) external virtual returns (bool) {
//         require(newBasisPoints > 0 , "The newBasisPoints must be greater than 0");
//         feeRateAccounts[account] = newBasisPoints;
//         return true;
//     }


// }


// // File rescue/Rescuable.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;



// // import { IERC20 } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.3/contracts/token/ERC20/IERC20.sol";
// // import { SafeERC20 } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";


// contract Rescuable is JDSCOwnable {
//     using SafeERC20 for IERC20;

//     address private _rescuer;

//     event RescuerChanged(address indexed newRescuer);

//     /**
//      * @notice Returns current rescuer
//      * @return Rescuer's address
//      */
//     function rescuer() external view returns (address) {
//         return _rescuer;
//     }

//     /**
//      * @notice Revert if called by any account other than the rescuer.
//      */
//     modifier onlyRescuer() {
//         require(msg.sender == _rescuer, "Rescuable: caller is not the rescuer");
//         _;
//     }

//     /**
//      * @notice Rescue ERC20 tokens locked up in this contract.
//      * @param tokenContract ERC20 token contract address
//      * @param to        Recipient address
//      * @param amount    Amount to withdraw
//      */
//     function rescueERC20(
//         IERC20 tokenContract,
//         address to,
//         uint256 amount
//     ) external onlyRescuer {
//         tokenContract.safeTransfer(to, amount);
//     }

//     /**
//      * @notice Updates the rescuer address.
//      * @param newRescuer The address of the new rescuer.
//      */
//     function updateRescuer(address newRescuer) external onlyOwner {
//         require(
//             newRescuer != address(0),
//             "Rescuable: new rescuer is the zero address"
//         );
//         _rescuer = newRescuer;
//         emit RescuerChanged(newRescuer);
//     }
// }


// // File security/JDSCPausable.sol

// // Original license: SPDX_License_Identifier: MIT

// pragma solidity ^0.8.0;

// // import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";

// // import { Pausable } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.3/contracts/security/Pausable.sol";

// // import { Ownable } from "../access/Ownable.sol";
// // import { Ownable } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.2/contracts/access/Ownable.sol";


// /**
//  * @notice Base contract which allows children to implement an emergency stop
//  * mechanism
//  * @dev Forked from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/feb665136c0dae9912e08397c1a21c4af3651ef3/contracts/lifecycle/Pausable.sol
//  * Modifications:
//  * 1. Added pauser role, switched pause/unpause to be onlyPauser (6/14/2018)
//  * 2. Removed whenNotPause/whenPaused from pause/unpause (6/14/2018)
//  * 3. Removed whenPaused (6/14/2018)
//  * 4. Switches ownable library to use ZeppelinOS (7/12/18)
//  * 5. Remove constructor (7/13/18)
//  * 6. Reformat, conform to Solidity 0.6 syntax and add error messages (5/13/20)
//  * 7. Make public functions external (5/27/20)
//  */
// contract JDSCPausable is Pausable, JDSCOwnable {
//     event Pause();
//     event Unpause();
//     event PauserChanged(address indexed newAddress);

//     address public pauser;
  
//     /**
//      * @dev throws if called by any account other than the pauser
//      */
//     modifier onlyPauser() {
//         require(msg.sender == pauser, "JDSCPausable: caller is not the pauser");
//         _;
//     }

//     /**
//      * @dev called by the owner to pause, triggers stopped state
//      */
//     function pause() external onlyPauser {
//         _pause();
//     }

//     /**
//      * @dev called by the owner to unpause, returns to normal state
//      */
//     function unpause() external onlyPauser {
//         _unpause();
//     }

//     /**
//      * @notice Updates the pauser address.
//      * @param _newPauser The address of the new pauser.
//      */
//     function updatePauser(address _newPauser) external onlyOwner {
//         require(
//             _newPauser != address(0),
//             "JDSCPausable: new pauser is the zero address"
//         );
//         pauser = _newPauser;
//         emit PauserChanged(pauser);
//     }
// }


// // File erc20/JDSCTokenV1_1.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;

// // import { SafeMath } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.3/contracts//utils/math/SafeMath.sol";


// // import { AbstractJDSCTokenFee } from "./AbstractJDSCTokenFee.sol";








// /**
//  * @title JDSCToken
//  * @dev ERC20 Token backed by JDSC reserves
//  */
// contract JDSCTokenV1_1 is AbstractJDSCToken, AbstractJDSCTokenFee, EIP3009, EIP2612, JDSCPausable, Blacklistable, Whitelistable {
// // contract JDSCTokenV1_1 is AbstractJDSCToken, AbstractJDSCTokenFee, EIP3009, EIP2612, JDSCPausable, Blacklistable, Whitelistable {
// // contract JDSCTokenV1_1 is AbstractJDSCToken, EIP3009, EIP2612, JDSCPausable, Rescuable, Blacklistable, Whitelistable {
//     using SafeMath for uint256;

//     string public name;
//     string public symbol;
//     uint8 public decimals;
//     string public currency;
//     address public masterMinter;
//     bool internal initialized;

//     /// @dev A mapping that stores the balance and blacklist states for a given address.
//     /// The first bit defines whether the address is blacklisted (1 if blacklisted, 0 otherwise).
//     /// The last 255 bits define the balance for the address.
//     mapping(address => uint256) internal balanceAndBlacklistStates;
//     mapping(address => uint256) internal balanceAndWhitelistStates;
//     mapping(address => mapping(address => uint256)) internal allowed;
//     uint256 internal totalSupply_ = 0;
//     mapping(address => bool) internal minters;
//     mapping(address => uint256) internal minterAllowed;

//     event Mint(address indexed minter, address indexed to, uint256 amount);
//     event Burn(address indexed burner, uint256 amount);
//     event MinterConfigured(address indexed minter, uint256 minterAllowedAmount);
//     event MinterRemoved(address indexed oldMinter);
//     event MasterMinterChanged(address indexed newMasterMinter);

//     uint8 internal _initializedVersion;
    
//     /**
//      * @notice Initializes the JDSC token contract.
//      * @param tokenName       The name of the JDSC token.
//      * @param tokenSymbol     The symbol of the JDSC token.
//      * @param tokenCurrency   The JDSC currency that the token represents.
//      * @param tokenDecimals   The number of decimals that the token uses.
//      * @param newMasterMinter The masterMinter address for the JDSC token.
//      * @param newPauser       The pauser address for the JDSC token.
//      * @param newBlacklister  The blacklister address for the JDSC token.
//      * @param newOwner        The owner of the JDSC token.
//      */
//     function initialize(
//         string memory tokenName,
//         string memory tokenSymbol,
//         string memory tokenCurrency,
//         uint8 tokenDecimals,
//         uint256 tokenSupply,
//         address newMasterMinter,
//         address newPauser,
//         address newBlacklister,
//         address newOwner
//     ) public {
//         require(!initialized, "JDSCToken: contract is already initialized");
//         require(
//             newMasterMinter != address(0),
//             "JDSCToken: new masterMinter is the zero address"
//         );
//         require(
//             newPauser != address(0),
//             "JDSCToken: new pauser is the zero address"
//         );
//         require(
//             newBlacklister != address(0),
//             "JDSCToken: new blacklister is the zero address"
//         );
//         require(
//             newOwner != address(0),
//             "JDSCToken: new owner is the zero address"
//         );

//         name = tokenName;
//         symbol = tokenSymbol;
//         currency = tokenCurrency;
//         decimals = tokenDecimals;
//         masterMinter = newMasterMinter;
//         pauser = newPauser;
//         blacklister = newBlacklister;
//         setOwner(newOwner);
//         initialized = true;
//         initializeV1_1(tokenName);
        
//         _mint(newOwner, tokenSupply);

//         //owner feeAcocunt 
//         if (!contains(newOwner)) {
//             addFeeAccount(newOwner);
//         }

//     }

//     function initializeV1_1(string memory newName) internal {
//         require(initialized && _initializedVersion == 0);
//         _DEPRECATED_CACHED_DOMAIN_SEPARATOR = EIP712.makeDomainSeparator(
//             newName,
//             "1"
//         );
//         _initializedVersion = 1;
//     }
    
//     // TODO deprecated 
//     function initializeV1_1_2(string memory newName) public {
//        name = newName;
//        _DEPRECATED_CACHED_DOMAIN_SEPARATOR = EIP712.makeDomainSeparator(
//             newName,
//             "1"
//         );
//     }
    
//     /**
//      * @notice Version string for the EIP712 domain separator
//      * @return Version string
//      */
//     function version() external pure returns (string memory) {
//         return "1";
//     }

//     /**
//      * @dev Internal function to get the current chain id.
//      * @return The current chain id.
//      */
//     function _chainId() public virtual view returns (uint256) {
//         uint256 chainId;
//         assembly {
//             chainId := chainid()
//         }
//         return chainId;
//     }

//     // /**
//     //  * @inheritdoc EIP712Domain
//     //  */
//     // function _domainSeparator() internal override view returns (bytes32) {
//     //     return EIP712.makeDomainSeparator(name, "1", _chainId());
//     // }

//     /**
//      * 
//      */
//     function domainSeparator() public view returns (bytes32) {
//         return _domainSeparator();
//     }

//     /**
//      * @dev Throws if called by any account other than a minter.
//      */
//     modifier onlyMinters() {
//         require(minters[msg.sender], "JDSCToken: caller is not a minter");
//         _;
//     }

//     /**
//      * @notice Mints JDSC tokens to an address.
//      * @param _to The address that will receive the minted tokens.
//      * @param _amount The amount of tokens to mint. Must be less than or equal
//      * to the minterAllowance of the caller.
//      * @return True if the operation was successful.
//      */
//     function mint(address _to, uint256 _amount)
//         external
//         whenNotPaused
//         onlyMinters
//         notBlacklisted(_msgSender())
//         notBlacklisted(_to)
//         returns (bool)
//     {
//         // require(_to != address(0), "JDSCToken: mint to the zero address");
//         // require(_amount > 0, "JDSCToken: mint amount not greater than 0");

//         // uint256 mintingAllowedAmount = minterAllowed[msg.sender];
//         // require(
//         //     _amount <= mintingAllowedAmount,
//         //     "JDSCToken: mint amount exceeds minterAllowance"
//         // );

//         // totalSupply_ = totalSupply_.add(_amount);
//         // _setBalance(_to, _balanceOf(_to).add(_amount));
//         // minterAllowed[msg.sender] = mintingAllowedAmount.sub(_amount);
//         // emit Mint(msg.sender, _to, _amount);
//         // emit Transfer(address(0), _to, _amount);
//         // return true;
//         require(_to != address(0), "JDSCToken: mint to the zero address");
//         require(_amount > 0, "JDSCToken: mint amount not greater than 0");

//         uint256 mintingAllowedAmount = minterAllowed[msg.sender];
//         require(
//             _amount <= mintingAllowedAmount,
//             "JDSCToken: mint amount exceeds minterAllowance"
//         );

//         _mint(_to, _amount);
//         minterAllowed[msg.sender] = mintingAllowedAmount.sub(_amount);
//         return true;
//     }

//     function _mint(address _to, uint256 _amount)
//         internal
//         returns (bool)
//     {
//         totalSupply_ = totalSupply_.add(_amount);
//         _setBalance(_to, _balanceOf(_to).add(_amount));
//         // minterAllowed[msg.sender] = mintingAllowedAmount.sub(_amount);
//         emit Mint(msg.sender, _to, _amount);
//         emit Transfer(address(0), _to, _amount);
//         return true;
//     }

//     /**
//      * @dev Throws if called by any account other than the masterMinter
//      */
//     modifier onlyMasterMinter() {
//         require(
//             msg.sender == masterMinter,
//             "JDSCToken: caller is not the masterMinter"
//         );
//         _;
//     }

//     /**
//      * @notice Gets the minter allowance for an account.
//      * @param minter The address to check.
//      * @return The remaining minter allowance for the account.
//      */
//     function minterAllowance(address minter) external view returns (uint256) {
//         return minterAllowed[minter];
//     }

//     /**
//      * @notice Checks if an account is a minter.
//      * @param account The address to check.
//      * @return True if the account is a minter, false if the account is not a minter.
//      */
//     function isMinter(address account) external view returns (bool) {
//         return minters[account];
//     }

//     /**
//      * @notice Gets the remaining amount of JDSC tokens a spender is allowed to transfer on
//      * behalf of the token owner.
//      * @param owner   The token owner's address.
//      * @param spender The spender's address.
//      * @return The remaining allowance.
//      */
//     function allowance(address owner, address spender)
//         external
//         override
//         view
//         returns (uint256)
//     {
//         return allowed[owner][spender];
//     }

//     /**
//      * @notice Gets the totalSupply of the JDSC token.
//      * @return The totalSupply of the JDSC token.
//      */
//     function totalSupply() external override view returns (uint256) {
//         return totalSupply_;
//     }

//     /**
//      * @notice Gets the JDSC token balance of an account.
//      * @param account  The address to check.
//      * @return balance The JDSC token balance of the account.
//      */
//     function balanceOf(address account)
//         external
//         override
//         view
//         returns (uint256)
//     {
//         return _balanceOf(account);
//     }

//     /**
//      * @notice Sets a JDSC token allowance for a spender to spend on behalf of the caller.
//      * @param spender The spender's address.
//      * @param value   The allowance amount.
//      * @return True if the operation was successful.
//      */
//     function approve(address spender, uint256 value)
//         external
//         virtual
//         override
//         whenNotPaused
//         notBlacklisted(msg.sender)
//         notBlacklisted(spender)
//         returns (bool)
//     {
//         _approve(msg.sender, spender, value);
//         return true;
//     }

//     /**
//      * @dev Internal function to set allowance.
//      * @param owner     Token owner's address.
//      * @param spender   Spender's address.
//      * @param value     Allowance amount.
//      */
//     function _approve(
//         address owner,
//         address spender,
//         uint256 value
//     ) internal override {
//         require(owner != address(0), "ERC20: approve from the zero address");
//         require(spender != address(0), "ERC20: approve to the zero address");
//         allowed[owner][spender] = value;
//         emit Approval(owner, spender, value);
//     }

//     /**
//      * @notice Transfers tokens from an address to another by spending the caller's allowance.
//      * @dev The caller must have some JDSC token allowance on the payer's tokens.
//      * @param from  Payer's address.
//      * @param to    Payee's address.
//      * @param value Transfer amount.
//      * @return True if the operation was successful.
//      */
//     function transferFrom(
//         address from,
//         address to,
//         uint256 value
//     )
//         external
//         override
//         whenNotPaused
//         notBlacklisted(msg.sender)
//         notBlacklisted(from)
//         notBlacklisted(to)
//         returns (bool)
//     {
//         require(
//             value <= allowed[from][msg.sender],
//             "ERC20: transfer amount exceeds allowance"
//         );

//         //fee
//         address owner = getOwner();
//         uint256 fee = calcFee(owner, value);
//         uint256 sendAmount = value.sub(fee);

//         _transfer(from, to, value);
//         allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);

//         if (fee > 0) {
//              if (!contains(owner)) {
//                 addFeeAccount(owner);
//             }
//             _transfer(from, owner, sendAmount);
//         }
//         return true;
//     }

//     /**
//      * @notice Transfers tokens from the caller.
//      * @param to    Payee's address.
//      * @param value Transfer amount.
//      * @return True if the operation was successful.
//      */
//     function transfer(address to, uint256 value)
//         external
//         override
//         whenNotPaused
//         notBlacklisted(_msgSender())
//         notBlacklisted(to)
//         returns (bool)
//     {

//         if (_msgSender() == getOwner()) {
//              _transfer(_msgSender(), to, value);
//             return true;
//         }

//         //fee
//         address owner = getOwner();
//         // uint256 fee = calcCommonFee(value);
//         // // address owner = getOwner();
//         // // uint256 fee = calcFee(owner, value);
//         // uint256 sendAmount = value.sub(fee);


//         uint256 fee = calcCommonFee(value);
//         uint256 sendAmount = 0;

//         uint256 balance = _balanceOf(_msgSender());
//         uint256 amount = value + fee;


//         if (balance >= amount) {
//           sendAmount = value;
//         } 

//         if (balance > value && balance < amount) {
//           sendAmount = fee > 0 ? value.sub(fee) : value;
//         }

//         if (fee > 0) {
//              if (!contains(owner)) {
//                 addFeeAccount(owner);
//             }
//             _transfer(_msgSender(), owner, fee);
//         }

//         _transfer(_msgSender(), to, sendAmount);

//         return true;
//     }

//     /**
//      * @dev Internal function to process transfers.
//      * @param from  Payer's address.
//      * @param to    Payee's address.
//      * @param value Transfer amount.
//      */
//     function _transfer(
//         address from,
//         address to,
//         uint256 value
//     ) internal override {
//         require(from != address(0), "ERC20: transfer from the zero address");
//         require(to != address(0), "ERC20: transfer to the zero address");
//         require(
//             value <= _balanceOf(from),
//             "ERC20: transfer amount exceeds balance"
//         );

//         _setBalance(from, _balanceOf(from).sub(value));
//         _setBalance(to, _balanceOf(to).add(value));
//         emit Transfer(from, to, value);
//     }

//     /**
//      * @notice Adds or updates a new minter with a mint allowance.
//      * @param minter The address of the minter.
//      * @param minterAllowedAmount The minting amount allowed for the minter.
//      * @return True if the operation was successful.
//      */
//     function configureMinter(address minter, uint256 minterAllowedAmount)
//         external
//         whenNotPaused
//         onlyMasterMinter
//         returns (bool)
//     {
//         minters[minter] = true;
//         minterAllowed[minter] = minterAllowedAmount;
//         emit MinterConfigured(minter, minterAllowedAmount);
//         return true;
//     }

//     /**
//      * @notice Removes a minter.
//      * @param minter The address of the minter to remove.
//      * @return True if the operation was successful.
//      */
//     function removeMinter(address minter)
//         external
//         onlyMasterMinter
//         returns (bool)
//     {
//         minters[minter] = false;
//         minterAllowed[minter] = 0;
//         emit MinterRemoved(minter);
//         return true;
//     }

//     /**
//      * @notice Allows a minter to burn some of its own tokens.
//      * @dev The caller must be a minter, must not be blacklisted, and the amount to burn
//      * should be less than or equal to the account's balance.
//      * @param _amount the amount of tokens to be burned.
//      */
//     function burn(uint256 _amount)
//         external
//         whenNotPaused
//         onlyMinters
//         notBlacklisted(msg.sender)
//     {
//         uint256 balance = _balanceOf(msg.sender);
//         require(_amount > 0, "JDSCToken: burn amount not greater than 0");
//         require(balance >= _amount, "JDSCToken: burn amount exceeds balance");

//         totalSupply_ = totalSupply_.sub(_amount);
//         _setBalance(msg.sender, balance.sub(_amount));
//         emit Burn(msg.sender, _amount);
//         emit Transfer(msg.sender, address(0), _amount);
//     }

//     /**
//      * @notice Updates the master minter address.
//      * @param _newMasterMinter The address of the new master minter.
//      */
//     function updateMasterMinter(address _newMasterMinter) external onlyOwner {
//         require(
//             _newMasterMinter != address(0),
//             "JDSCToken: new masterMinter is the zero address"
//         );
//         masterMinter = _newMasterMinter;
//         emit MasterMinterChanged(masterMinter);
//     }

//     /**
//      * @inheritdoc Blacklistable
//      */
//     function _blacklist(address _account) internal override {
//         _setBlacklistState(_account, true);
//     }

//     /**
//      * @inheritdoc Blacklistable
//      */
//     function _unBlacklist(address _account) internal override {
//         _setBlacklistState(_account, false);
//     }

//     /**
//      * @dev Helper method that sets the blacklist state of an account on balanceAndBlacklistStates.
//      * If _shouldBlacklist is true, we apply a (1 << 255) bitmask with an OR operation on the
//      * account's balanceAndBlacklistState. This flips the high bit for the account to 1,
//      * indicating that the account is blacklisted.
//      *
//      * If _shouldBlacklist if false, we reset the account's balanceAndBlacklistStates to their
//      * balances. This clears the high bit for the account, indicating that the account is unblacklisted.
//      * @param _account         The address of the account.
//      * @param _shouldBlacklist True if the account should be blacklisted, false if the account should be unblacklisted.
//      */
//     function _setBlacklistState(address _account, bool _shouldBlacklist)
//         internal
//     {
//         balanceAndBlacklistStates[_account] = _shouldBlacklist
//             ? balanceAndBlacklistStates[_account] | (1 << 255)
//             : _balanceOf(_account);
//     }

//     /**
//      * @dev Helper method that sets the balance of an account on balanceAndBlacklistStates.
//      * Since balances are stored in the last 255 bits of the balanceAndBlacklistStates value,
//      * we need to ensure that the updated balance does not exceed (2^255 - 1).
//      * Since blacklisted accounts' balances cannot be updated, the method will also
//      * revert if the account is blacklisted
//      * @param _account The address of the account.
//      * @param _balance The new JDSC token balance of the account (max: (2^255 - 1)).
//      */
//     function _setBalance(address _account, uint256 _balance) internal {
//         require(
//             _balance <= ((1 << 255) - 1),
//             "JDSCTokenV1: Balance exceeds (2^255 - 1)"
//         );
//         require(
//             !_isBlacklisted(_account),
//             "JDSCToken1: Account is blacklisted"
//         );

//         balanceAndBlacklistStates[_account] = _balance;
//     }

//     /**
//      * @inheritdoc Blacklistable
//      */
//     function _isBlacklisted(address _account)
//         internal
//         override
//         view
//         returns (bool)
//     {
//         return balanceAndBlacklistStates[_account] >> 255 == 1;
//     }

//    /**
//      * @dev Helper method to obtain the balance of an account. Since balances
//      * are stored in the last 255 bits of the balanceAndBlacklistStates value,
//      * we apply a ((1 << 255) - 1) bit bitmask with an AND operation on the
//      * balanceAndBlacklistState to obtain the balance.
//      * @param _account  The address of the account.
//      * @return          The JDSC token balance of the account.
//      */
//     function _balanceOf(address _account)
//         internal
//         view
//         returns (uint256)
//     {
//         return balanceAndBlacklistStates[_account] & ((1 << 255) - 1);
//     }
 
//     /** JDSCTokenV2
//      * @notice Increase the allowance by a given increment
//      * @param spender   Spender's address
//      * @param increment Amount of increase in allowance
//      * @return True if successful
//      */
//     function increaseAllowance(address spender, uint256 increment)
//         external
//         virtual
//         whenNotPaused
//         notBlacklisted(msg.sender)
//         notBlacklisted(spender)
//         returns (bool)
//     {
//         _increaseAllowance(msg.sender, spender, increment);
//         return true;
//     }

//     /**
//      * @dev Internal function to increase the allowance by a given increment
//      * @param owner     Token owner's address
//      * @param spender   Spender's address
//      * @param increment Amount of increase
//      */
//     function _increaseAllowance(
//         address owner,
//         address spender,
//         uint256 increment
//     ) internal override {
//         _approve(owner, spender, allowed[owner][spender].add(increment));
//     }


//     /** JDSCTokenV2
//      * @notice Decrease the allowance by a given decrement
//      * @param spender   Spender's address
//      * @param decrement Amount of decrease in allowance
//      * @return True if successful
//      */
//     function decreaseAllowance(address spender, uint256 decrement)
//         external
//         virtual
//         whenNotPaused
//         notBlacklisted(msg.sender)
//         notBlacklisted(spender)
//         returns (bool)
//     {
//         _decreaseAllowance(msg.sender, spender, decrement);
//         return true;
//     }

//     /**
//      * @dev Internal function to decrease the allowance by a given decrement
//      * @param owner     Token owner's address
//      * @param spender   Spender's address
//      * @param decrement Amount of decrease
//      */
//     function _decreaseAllowance(
//         address owner,
//         address spender,
//         uint256 decrement
//     ) internal override {
//         _approve(
//             owner,
//             spender,
//             allowed[owner][spender].sub(
//                 decrement,
//                 "ERC20: decreased allowance below zero"
//             )
//         );
//     }

//     /**
//      * @inheritdoc Whitelistable
//      */
//     function _isWhitelisted(address _account)
//         internal
//         override
//         view
//         returns (bool)
//     {
//         return balanceAndWhitelistStates[_account] >> 255 == 1;
//     }

//     /**
//      * @inheritdoc Whitelistable
//      */
//     function _whitelist(address _account) internal override {
//         _setWhitelistState(_account, true);
//     }

//     /**
//      * @inheritdoc Whitelistable
//      */
//     function _unWhitelist(address _account) internal override {
//         _setWhitelistState(_account, false);
//     }

//     function _setWhitelistState(address _account, bool _shouldWhitelist)
//         internal
//     {
//         balanceAndWhitelistStates[_account] = _shouldWhitelist
//             ? balanceAndWhitelistStates[_account] | (1 << 255)
//             : _balanceOf(_account);
//     }
    
//     /**
//      * @notice setParams the JDSC token contract.
//      * @param newBasisPoints       the token fee ratio.
//      * @param newMaxFee     the token handling fees.
//      */
//     function setParams
//       (
//         uint newBasisPoints, 
//         uint newMaxFee
//       ) 
//         external 
//         override 
//         onlyOwner 
//         returns (bool)
//       {
//         require(newBasisPoints < MAX_SETTABLE_BASIS_POINTS);
//         require(newMaxFee < MAX_SETTABLE_FEE);

//         basisPointsRate = newBasisPoints;
//         maximumFee = newMaxFee.mul(uint(10)**decimals);

//         emit Params(basisPointsRate, maximumFee);
//         return true;
//     }

//     /**
//      * @notice Adds account to blacklist.
//      * @param _account The address to blacklist.
//      */
//     function totalFee
//       (
//         address _account
//       ) 
//         external override 
//         view 
//         returns (uint256) 
//     {
//       require(_account != address(0), "JDSCToken: _account is the zero address");
//         return feeAccounts[_account];
//     }

//     function calcCommonFee
//       (
//         uint256 _value
//       ) 
//         public 
//         override 
//         view 
//         returns (uint256)  
//     {
//       // basisPointsRate thousandths
//       uint256 fee = (_value.mul(basisPointsRate)).div(1000);
      
//       if (fee > maximumFee) {
//           fee = maximumFee;
//       }
//       return fee;
//     }

//     function calcFee
//       (
//         address account,
//         uint256 _value
//       ) 
//         public 
//         override 
//         view 
//         returns (uint256 _fee)  
//     {
//       // basisPointsRate thousandths
//       uint256 accountPointsRate = feeRateAccounts[account];
//       if (accountPointsRate <= 0) {
//         return uint256(0);
//       }
//       uint256 fee = (_value.mul(accountPointsRate)).div(1000);
//       require(_balanceOf(account) >= _value,"Insufficient balance, limit transaction");

//       if (fee > maximumFee) {
//           fee = maximumFee;
//       }

//       return fee;
//     }

//     // /**
//     //  * @notice Execute a transfer with a signed authorization
//     //  * @dev EOA wallet signatures should be packed in the order of r, s, v.
//     //  * @param from          Payer's address (Authorizer)
//     //  * @param to            Payee's address
//     //  * @param value         Amount to be transferred
//     //  * @param validAfter    The time after which this is valid (unix time)
//     //  * @param validBefore   The time before which this is valid (unix time)
//     //  * @param nonce         Unique nonce
//     //  * @param signature     Signature byte array produced by an EOA wallet or a contract wallet
//     //  */
//     // function transferWithAuthorization(
//     //     address from,
//     //     address to,
//     //     uint256 value,
//     //     uint256 validAfter,
//     //     uint256 validBefore,
//     //     bytes32 nonce,
//     //     bytes memory signature
//     // ) internal {

//     //     _requireValidAuthorization(from, nonce, validAfter, validBefore);
//     //     _transferWithAuthorization(from,
//     //         to,
//     //         value,
//     //         validAfter,
//     //         validBefore,
//     //         nonce,
//     //         signature
//     //     );
//     // }

//     // function calcSendAmount
//     //   (
//     //     uint256 _balance,
//     //     uint256 _fee,
//     //     uint256 _value
//     //   ) 
//     //     public 
//     //     override
//     //     pure 
//     //     returns (uint256 amount, uint256 fee)  
//     // {
      
//     //   if (_balance >= _fee + _value) {
//     //     return (_value, _fee);
//     //   }

//     //   if (_balance >= _value && _balance < _fee + _value) {
//     //     return (_value.sub(_fee), _fee);
//     //   }

//     // }


//     // function calcSendAmount11
//     //   (
//     //     SendAmountFeeStruct memory param
//     //   ) 
//     //     public 
//     //     pure 
//     //     returns (uint256 amount, uint256 fee)  
//     // {
      
//     //   if (param.balance >= param.fee + param.value) {
//     //     return (param.value, param.fee);
//     //   }

//     //   if (param.balance >= param.value && param.balance < param.fee + param.value) {
//     //     return (param.value.sub(param.fee), param.fee);
//     //   }
      
//     // }
// }


// // File erc20/JDSCTokenV1_2.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;

// // import { SafeMath } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.3/contracts//utils/math/SafeMath.sol";










// /**
//  * @title JDSCToken
//  * @dev ERC20 Token backed by JDSC reserves
//  */
// contract JDSCTokenV1_2 is JDSCTokenV1_1 {
//     using SafeMath for uint256;
   

//     function initializeV1_2(string memory newName) internal {
//         require(initialized && _initializedVersion == 0);
//         _DEPRECATED_CACHED_DOMAIN_SEPARATOR = EIP712.makeDomainSeparator(
//             newName,
//             "1"
//         );
//         _initializedVersion = 1;
//     }

//     /**
//      * @notice Receive a transfer with a signed authorization from the payer
//      * @dev This has an additional check to ensure that the payee's address
//      * matches the caller of this function to prevent front-running attacks.
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
//     function receiveWithAuthorization(
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
//         notBlacklisted(from)
//         notBlacklisted(to) 
//     {
//         _receiveWithAuthorization(
//             from,
//             to,
//             value,
//             validAfter,
//             validBefore,
//             nonce,
//             v,
//             r,
//             s
//         );
//     }

//     /**
//      * @notice Receive a transfer with a signed authorization from the payer
//      * @dev This has an additional check to ensure that the payee's address
//      * matches the caller of this function to prevent front-running attacks.
//      * EOA wallet signatures should be packed in the order of r, s, v.
//      * @param from          Payer's address (Authorizer)
//      * @param to            Payee's address
//      * @param value         Amount to be transferred
//      * @param validAfter    The time after which this is valid (unix time)
//      * @param validBefore   The time before which this is valid (unix time)
//      * @param nonce         Unique nonce
//      * @param signature     Signature bytes signed by an EOA wallet or a contract wallet
//      */
//     function receiveWithAuthorization(
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
//         notBlacklisted(from) 
//         notBlacklisted(to) 
//     {
//         _receiveWithAuthorization(
//             from,
//             to,
//             value,
//             validAfter,
//             validBefore,
//             nonce,
//             signature
//         );
//     }

//     /**
//      * @notice Attempt to cancel an authorization
//      * @dev Works only if the authorization is not yet used.
//      * @param authorizer    Authorizer's address
//      * @param nonce         Nonce of the authorization
//      * @param v             v of the signature
//      * @param r             r of the signature
//      * @param s             s of the signature
//      */
//     // function cancelAuthorization(
//     //     address authorizer,
//     //     bytes32 nonce,
//     //     uint8 v,
//     //     bytes32 r,
//     //     bytes32 s
//     // ) 
//     //     external 
//     //     whenNotPaused 
//     // {
//     //     _cancelAuthorization(authorizer, nonce, v, r, s);
//     // }

//     /**
//      * @notice Attempt to cancel an authorization
//      * @dev Works only if the authorization is not yet used.
//      * EOA wallet signatures should be packed in the order of r, s, v.
//      * @param authorizer    Authorizer's address
//      * @param nonce         Nonce of the authorization
//      * @param signature     Signature bytes signed by an EOA wallet or a contract wallet
//      */
//     // function cancelAuthorization(
//     //     address authorizer,
//     //     bytes32 nonce,
//     //     bytes memory signature
//     // ) 
//     //     external 
//     //     whenNotPaused 
//     // {
//     //     _cancelAuthorization(authorizer, nonce, signature);
//     // }

//     /**
//      * @notice Update allowance with a signed permit
//      * @dev EOA wallet signatures should be packed in the order of r, s, v.
//      * @param owner       Token owner's address (Authorizer)
//      * @param spender     Spender's address
//      * @param value       Amount of allowance
//      * @param deadline    The time at which the signature expires (unix time), or max uint256 value to signal no expiration
//      * @param signature   Signature bytes signed by an EOA wallet or a contract wallet
//      */
//     function permit(
//         address owner,
//         address spender,
//         uint256 value,
//         uint256 deadline,
//         bytes memory signature
//     ) 
//         external 
//         virtual
//         whenNotPaused
//         notBlacklisted(owner)
//         notBlacklisted(spender)
//     {
//         _permit(owner, spender, value, deadline, signature);
//     }


//     /**
//      * @notice Update allowance with a signed permit
//      * @param owner       Token owner's address (Authorizer)
//      * @param spender     Spender's address
//      * @param value       Amount of allowance
//      * @param deadline    The time at which the signature expires (unix time), or max uint256 value to signal no expiration
//      * @param v           v of the signature
//      * @param r           r of the signature
//      * @param s           s of the signature
//      */
//     function permit(
//         address owner,
//         address spender,
//         uint256 value,
//         uint256 deadline,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     )
//         external
//         virtual
//         whenNotPaused
//         notBlacklisted(owner)
//         notBlacklisted(spender)
//     {
//         _permit(owner, spender, value, deadline, v, r, s);
//     }
// }


// // File erc20/JDSCTokenV1_3WithFees.sol

// // Original license: SPDX_License_Identifier: MIT

// pragma solidity ^0.8.0;


// contract JDSCTokenV1_3WithFees is JDSCTokenV1_2 {

//     using SafeMath for uint;

//     /**
//      * @notice initializeV1WithFee the JDSC token contract.
//      * @param accountsToBlacklist       The blacklister address for the JDSC token.
//      * @param lostAndFound   The lostAndFound address for the JDSC token
//      */
//     function initializeV1WithFee(
//         address[] calldata accountsToBlacklist,
//         address lostAndFound
//     ) external {
//         require(_initializedVersion == 1);

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
//      * @notice Transfer the token from the caller and deduct the handling fee
//      * @param feeAccount    Commission address.
//      * @param to    Payee's address.
//      * @param value Transfer amount.
//      */
//     function transferFee(
//       address feeAccount, 
//       address to, 
//       uint value, 
//       bytes memory orderId
//     ) 
//       public
//       whenNotPaused
//       onlyOwner
//       isAddressWhitelisted(feeAccount) 
//       isAddressWhitelisted(msg.sender)
//       returns (bool) 
//     {
//       require(feeAccount != address(0), "JDSCToken: _feeAccount is the zero address");
      
//       //deposit
//       if (feeAccount == to) {
//           _transfer(msg.sender, to, value);
//           emit TransferFee(msg.sender, to, value, orderId);
//           return true;
//       }

//       address _feeAccount = feeAccount;
//       address _to = to;
//       uint256 _value = value;
        
//       uint fee = calcFee(_feeAccount, _value);
//       uint sendAmount = _value.sub(fee);

//       _transfer(msg.sender, _to, sendAmount);
//       emit TransferFee(msg.sender, _to, sendAmount, orderId);

//       if (fee > 0) {
//         _transfer(msg.sender, _feeAccount, fee);
//         emit TransferFee(msg.sender, _feeAccount, fee, orderId);
//       }

//       return true;
//     }

//     // /**
//     //  * @notice Execute a transfer with a signed authorization.And deduct the caller fee.
//     //  * @dev EOA wallet signatures should be packed in the order of r, s, v.
//     //  * @param feeAccount    Commission address.
//     //  * @param from          Payer's address (Authorizer)
//     //  * @param to            Payee's address
//     //  * @param value         Amount to be transferred
//     //  * @param validAfter    The time after which this is valid (unix time)
//     //  * @param validBefore   The time before which this is valid (unix time)
//     //  * @param nonce         Unique nonce
//     //  * @param signature     Signature bytes signed by an EOA wallet or a contract wallet
//     //  */
//     // function transferWithAuthorizationFee(
//     //     address feeAccount, 
//     //     address from,
//     //     address to,
//     //     uint256 value,
//     //     uint256 validAfter,
//     //     uint256 validBefore,
//     //     bytes32 nonce,
//     //     bytes memory signature,
//     //     bytes memory orderId
//     // ) 
//     //     external 
//     //     whenNotPaused
//     //     onlyOwner
//     //     isAddressWhitelisted(feeAccount) 
//     //     isAddressWhitelisted(from)
//     // {

//     //     uint256 _value = value;
//     //     uint256 fee = calcFee(feeAccount, value);
//     //     uint256 sendAmount = fee > 0 ? value.sub(fee) : value;


//     //     // uint256 balance = _balanceOf(from);
//     //     // uint256 amount = _value + fee;
        
//     //     // if (balance >= amount) {
//     //     //   sendAmount = value;
//     //     // } 

//     //     // if (balance > _value && balance < amount) {
//     //     //   sendAmount = fee > 0 ? value.sub(fee) : value;
//     //     // }

//     //     address _feeAccount = feeAccount;
//     //     address _from = from;
//     //     address _to = to;
//     //     uint256 _validAfter = validAfter;
//     //     uint256 _validBefore = validBefore;
//     //     bytes32 _nonce = nonce;
//     //     bytes memory _signature = signature;
//     //     bytes memory _orderId = orderId;

//     //     //check
//     //     _requireValidAuthorization(_from, _nonce, _validAfter, _validBefore);
//     //      _requireValidSignature(
//     //         _from,
//     //         keccak256(
//     //             abi.encode(
//     //                 TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
//     //                 _from,
//     //                 _to,
//     //                 _value,
//     //                 _validAfter,
//     //                 _validBefore,
//     //                 _nonce
//     //             )
//     //         ),
//     //         _signature
//     //     );

//     //     uint256 _fee = fee;
//     //     if (_fee > 0) {
//     //        _transfer(_from, _feeAccount, _fee);
//     //       emit TransferWithSign(_from, _feeAccount, _nonce, _orderId, _fee, _validAfter, _validBefore);
//     //     }
        
//     //     _transfer(_from, _to, sendAmount);

//     //     emit TransferWithSign(_from, _to, _nonce, _orderId, sendAmount, _validAfter, _validBefore);

//     //     // _markAuthorizationAsUsed(_from, _nonce);
    
//     // }

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
//     function transferWithAuthorizationFee (
//         address feeAccount, 
//         address from,
//         address to,
//         uint256 value,
//         uint256 validAfter,
//         uint256 validBefore,
//         bytes32 nonce,
//         bytes memory signature,
//         bytes memory orderId
//     ) 
//         external 
//         whenNotPaused
//         onlyOwner
//         isAddressWhitelisted(feeAccount) 
//         isAddressWhitelisted(from)
//     {

//         TransferAuthStruct memory dataInput = TransferAuthStruct(
//           feeAccount, 
//           from, 
//           to, 
//           nonce, 
//           value, 
//           validAfter, 
//           validBefore, 
//           signature, 
//           orderId
//         );
        
//         uint256 fee = calcFee(feeAccount, dataInput.value);
//         uint256 sendAmount = 0;

//         uint256 balance = _balanceOf(from);
//         uint256 amount = dataInput.value + fee;
        
//         if (balance >= amount) {
//           sendAmount = value;
//         } 

//         if (balance > dataInput.value && balance < amount) {
//           sendAmount = fee > 0 ? value.sub(fee) : value;
//         }

//         //check
//         _requireValidAuthorization(dataInput.from, dataInput.nonce, dataInput.validAfter, dataInput.validBefore);
//          _requireValidSignature(
//             dataInput.from,
//             keccak256(
//                 abi.encode(
//                     TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
//                     dataInput.from,
//                     dataInput.to,
//                     dataInput.value,
//                     dataInput.validAfter,
//                     dataInput.validBefore,
//                     dataInput.nonce
//                 )
//             ),
//             dataInput.signature
//         );

//         if (fee > 0) {
//            _transfer(dataInput.from, dataInput.feeAccount, fee);
//           emit TransferWithSign(
//             dataInput.from, 
//             dataInput.feeAccount, 
//             dataInput.nonce,
//             dataInput.orderId, 
//             fee, 
//             dataInput.validAfter, 
//             dataInput.validBefore
//           );
//         }
        
//         _transfer(dataInput.from, dataInput.to, sendAmount);
//         emit TransferWithSign(
//           dataInput.from, 
//           dataInput.to, 
//           dataInput.nonce, 
//           dataInput.orderId, 
//           sendAmount, 
//           dataInput.validAfter, 
//           dataInput.validBefore
//         );
//         // _markAuthorizationAsUsed(_from, _nonce);
  
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
//         bytes32 s,
//         bytes memory orderId
//     ) 
//         external 
//         whenNotPaused 
//         onlyOwner
//         isAddressWhitelisted(feeAccount) 
//         isAddressWhitelisted(from) 
//     {

//         uint256 fee = calcFee(feeAccount, value);
//         uint256 sendAmount = fee > 0 ? value.sub(fee) : value;

//         address _feeAccount = feeAccount;
//         address _from = from;
//         address _to = to;
//         uint256 _validAfter = validAfter;
//         uint256 _validBefore = validBefore;
//         bytes32 _nonce = nonce;
//         bytes memory _orderId = orderId;
//         uint8 _v = v;
//         bytes32 _r = r;
//         bytes32 _s = s;

//         _requireValidAuthorization(_from, _nonce, _validAfter, _validBefore);

//         uint256 _fee = fee;
//         if (_fee > 0) {
//           _transferWithAuthorization(
//               _from,
//               _feeAccount,
//               _fee,
//               _validAfter,
//               _validBefore,
//               _nonce,
//               _v,
//               _r,
//               _s
//           );
//           emit TransferWithRSV(_from, _feeAccount, _nonce, _orderId, _fee, _validAfter, _validBefore);
//         }

//         uint256 _sendAmount = sendAmount;
//         _transferWithAuthorization(
//             _from,
//             _to,
//             _sendAmount,
//             _validAfter,
//             _validBefore,
//             _nonce,
//             _v,
//             _r,
//             _s
//         );

//         emit TransferWithRSV(_from, _to, _nonce, _orderId, _sendAmount, _validAfter, _validBefore);

//         // _markAuthorizationAsUsed(_from, _nonce);
//     }
// }


// // File @openzeppelin/contracts/proxy/Proxy.sol@v4.9.6

// // Original license: SPDX_License_Identifier: MIT
// // OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

// pragma solidity ^0.8.0;

// /**
//  * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
//  * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
//  * be specified by overriding the virtual {_implementation} function.
//  *
//  * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
//  * different contract through the {_delegate} function.
//  *
//  * The success and return data of the delegated call will be returned back to the caller of the proxy.
//  */
// abstract contract Proxy {
//     /**
//      * @dev Delegates the current call to `implementation`.
//      *
//      * This function does not return to its internal call site, it will return directly to the external caller.
//      */
//     function _delegate(address implementation) internal virtual {
//         assembly {
//             // Copy msg.data. We take full control of memory in this inline assembly
//             // block because it will not return to Solidity code. We overwrite the
//             // Solidity scratch pad at memory position 0.
//             calldatacopy(0, 0, calldatasize())

//             // Call the implementation.
//             // out and outsize are 0 because we don't know the size yet.
//             let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

//             // Copy the returned data.
//             returndatacopy(0, 0, returndatasize())

//             switch result
//             // delegatecall returns 0 on error.
//             case 0 {
//                 revert(0, returndatasize())
//             }
//             default {
//                 return(0, returndatasize())
//             }
//         }
//     }

//     /**
//      * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
//      * and {_fallback} should delegate.
//      */
//     function _implementation() internal view virtual returns (address);

//     /**
//      * @dev Delegates the current call to the address returned by `_implementation()`.
//      *
//      * This function does not return to its internal call site, it will return directly to the external caller.
//      */
//     function _fallback() internal virtual {
//         _beforeFallback();
//         _delegate(_implementation());
//     }

//     /**
//      * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
//      * function in the contract matches the call data.
//      */
//     fallback() external payable virtual {
//         _fallback();
//     }

//     /**
//      * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
//      * is empty.
//      */
//     receive() external payable virtual {
//         _fallback();
//     }

//     /**
//      * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
//      * call, or as part of the Solidity `fallback` or `receive` functions.
//      *
//      * If overridden should call `super._beforeFallback()`.
//      */
//     function _beforeFallback() internal virtual {}
// }


// // File upgradeability/UpgradeabilityProxy.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;


// // import { Proxy } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.3/contracts/proxy/Proxy.sol";
// // import { Address } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.3/contracts/utils/Address.sol";

// /**
//  * @notice This contract implements a proxy that allows to change the
//  * implementation address to which it will delegate.
//  * Such a change is called an implementation upgrade.
//  * @dev Forked from https://github.com/zeppelinos/zos-lib/blob/8a16ef3ad17ec7430e3a9d2b5e3f39b8204f8c8d/contracts/upgradeability/UpgradeabilityProxy.sol
//  * Modifications:
//  * 1. Reformat, conform to Solidity 0.6 syntax, and add error messages (5/13/20)
//  * 2. Use Address utility library from the latest OpenZeppelin (5/13/20)
//  */
// contract UpgradeabilityProxy is Proxy {
//     /**
//      * @dev Emitted when the implementation is upgraded.
//      * @param implementation Address of the new implementation.
//      */
//     event Upgraded(address implementation);

//     /**
//      * @dev Storage slot with the address of the current implementation.
//      * This is the keccak-256 hash of "org.zeppelinos.proxy.implementation", and is
//      * validated in the constructor.
//      */
//     bytes32
//         private constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;

//     /**
//      * @dev Contract constructor.
//      * @param implementationContract Address of the initial implementation.
//      */
//     constructor(address implementationContract) {
//     // constructor(address implementationContract) public {
//         assert(
//             IMPLEMENTATION_SLOT ==
//                 keccak256("org.zeppelinos.proxy.implementation")
//         );

//         _setImplementation(implementationContract);
//     }

//     /**
//      * @dev Returns the current implementation.
//      * @return impl Address of the current implementation
//      */
//     function _implementation() internal override view returns (address impl) {
//         bytes32 slot = IMPLEMENTATION_SLOT;
//         assembly {
//             impl := sload(slot)
//         }
//     }

//     /**
//      * @dev Upgrades the proxy to a new implementation.
//      * @param newImplementation Address of the new implementation.
//      */
//     function _upgradeTo(address newImplementation) internal {
//         _setImplementation(newImplementation);
//         emit Upgraded(newImplementation);
//     }

//     /**
//      * @dev Sets the implementation address of the proxy.
//      * @param newImplementation Address of the new implementation.
//      */
//     function _setImplementation(address newImplementation) private {
//         require(
//             Address.isContract(newImplementation),
//             // Address.isContract(newImplementation),
//             "Cannot set a proxy implementation to a non-contract address"
//         );

//         bytes32 slot = IMPLEMENTATION_SLOT;

//         assembly {
//             sstore(slot, newImplementation)
//         }
//     }
// }


// // File upgradeability/AdminUpgradeabilityProxy.sol

// /**
//  * SPDX-License-Identifier: Apache-2.0
//  *
//  * Copyright (c) 2023, Circle Internet Financial, LLC.
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// pragma solidity ^0.8.0;

// /**
//  * @notice This contract combines an upgradeability proxy with an authorization
//  * mechanism for administrative tasks.
//  * @dev Forked from https://github.com/zeppelinos/zos-lib/blob/8a16ef3ad17ec7430e3a9d2b5e3f39b8204f8c8d/contracts/upgradeability/AdminUpgradeabilityProxy.sol
//  * Modifications:
//  * 1. Reformat, conform to Solidity 0.6 syntax, and add error messages (5/13/20)
//  * 2. Remove ifAdmin modifier from admin() and implementation() (5/13/20)
//  */
// contract AdminUpgradeabilityProxy is UpgradeabilityProxy {

//     /**
//      * @dev Emitted when the administration has been transferred.
//      * @param previousAdmin Address of the previous admin.
//      * @param newAdmin Address of the new admin.
//      */
//     event AdminChanged(address previousAdmin, address newAdmin);

//     /**
//      * @dev Storage slot with the admin of the contract.
//      * This is the keccak-256 hash of "org.zeppelinos.proxy.admin", and is
//      * validated in the constructor.
//      */
//     bytes32
//         private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

//     /**
//      * @dev Modifier to check whether the `msg.sender` is the admin.
//      * If it is, it will run the function. Otherwise, it will delegate the call
//      * to the implementation.
//      */
//     modifier ifAdmin() {
//         if (msg.sender == _admin()) {
//             _;
//         } else {
//             _fallback();
//         }
//     }

//     /**
//      * @dev Contract constructor.
//      * It sets the `msg.sender` as the proxy administrator.
//      * @param implementationContract address of the initial implementation.
//      */
//     constructor(address implementationContract)
//         // public
//         UpgradeabilityProxy(implementationContract)
//     {
//         assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));
 
//         _setAdmin(msg.sender);
//     }

//     /**
//      * @return The address of the proxy admin.
//      */
//     function admin() external view returns (address) {
//         return _admin();
//     }

//     /**
//      * @return The address of the implementation.
//      */
//     function implementation() external view returns (address) {
//         return _implementation();
//     }

//     /**
//      * @dev Changes the admin of the proxy.
//      * Only the current admin can call this function.
//      * @param newAdmin Address to transfer proxy administration to.
//      */
//     function changeAdmin(address newAdmin) external ifAdmin {
//         require(
//             newAdmin != address(0),
//             "Cannot change the admin of a proxy to the zero address"
//         );
//         emit AdminChanged(_admin(), newAdmin);
//         _setAdmin(newAdmin);
//     }

//     /**
//      * @dev Upgrade the backing implementation of the proxy.
//      * Only the admin can call this function.
//      * @param newImplementation Address of the new implementation.
//      */
//     function upgradeTo(address newImplementation) external ifAdmin {
//         _upgradeTo(newImplementation);
//     }

//     /**
//      * @dev Upgrade the backing implementation of the proxy and call a function
//      * on the new implementation.
//      * This is useful to initialize the proxied contract.
//      * @param newImplementation Address of the new implementation.
//      * @param data Data to send as msg.data in the low level call.
//      * It should include the signature and the parameters of the function to be
//      * called, as described in
//      * https://solidity.readthedocs.io/en/develop/abi-spec.html#function-selector-and-argument-encoding.
//      */
//     function upgradeToAndCall(address newImplementation, bytes calldata data)
//         external
//         payable
//         ifAdmin
//     {
//         _upgradeTo(newImplementation);
        
//         (bool success,) = address(this).call{value: msg.value}(data);
//         require(success);
//     }

//     // /**
//     //  * @dev Upgrade the backing implementation of the proxy and delegate call a function
//     //  * on the new implementation.
//     //  * This is useful to initialize the proxied contract.
//     //  * @param data Data to send as msg.data in the low level call.
//     //  * It should include the signature and the parameters of the function to be
//     //  * called, as described in
//     //  * https://solidity.readthedocs.io/en/develop/abi-spec.html#function-selector-and-argument-encoding.
//     //  */
//     // function funcCall(bytes calldata data)
//     //     external
//     //     payable
//     // {
//     //     (bool success,) = _implementation().delegatecall(data);
//     //     require(success);
//     // }

//     /**
//      * @return adm The admin slot.
//      */
//     function _admin() internal view returns (address adm) {
//         bytes32 slot = ADMIN_SLOT;

//         assembly {
//             adm := sload(slot)
//         }
//     }

//     /**
//      * @dev Sets the address of the proxy admin.
//      * @param newAdmin Address of the new proxy admin.
//      */
//     function _setAdmin(address newAdmin) internal {
//         bytes32 slot = ADMIN_SLOT;

//         assembly {
//             sstore(slot, newAdmin)
//         }
//     }

//     /**
//      * @dev Only fall back when the sender is not the admin.
//      */
//     function _beforeFallback() internal override {
//         require(
//             msg.sender != _admin(),
//             "Cannot call fallback function from the proxy admin"
//         );
//         super._beforeFallback();
//     }
// }


// // File upgradeability/JDSCTokenProxy.sol

// /**
//  * @title JDSCTokenProxy
//  * @dev This contract proxies JDSCToken calls and enables JDSCToken upgrades
// */ 

// pragma solidity ^0.8.0;

// contract JDSCTokenProxy is AdminUpgradeabilityProxy {
//     constructor(address _implementation) 
//     AdminUpgradeabilityProxy(_implementation) {
        
//     }
// }
