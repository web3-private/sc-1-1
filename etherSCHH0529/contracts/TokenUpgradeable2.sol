// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { SafeMathUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import { TokenBaseUpgradeable } from "./TokenBaseUpgradeable.sol";
import { AbstractJDSCTokenFee } from "./extensions/AbstractJDSCTokenFee.sol";
import { Blacklistable } from "./Blacklistable.sol";
import { Minterable } from "./Minterable.sol";
import { Rescuable } from "./Rescuable.sol";
import { Authorizable } from "./Authorizable.sol";
import { Pausable } from "./Pausable.sol";

import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract TokenUpgradeable2 is TokenBaseUpgradeable, AbstractJDSCTokenFee, Authorizable, Pausable, Rescuable, Minterable, Blacklistable {

    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) internal balanceAndBlacklistStates;
    mapping(address => uint256) internal balanceAndWhitelistStates;
    string public  ba44;
    string public constant ba = "sadad";
    string public constant bsa = "sadad";

    event Mint(address indexed minter, address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 amount);

  
    //初始化
    function updateRole (    
        uint256 initBasisPointsRate,
        uint256 initMaximumFee,
        address newMasterMinter, 
        address newBlacklister, 
        address newPauser, 
        address newOwner, 
        // address[] calldata accountsToBlacklist,
        address lostAndFound
        ) public virtual {
        basisPointsRate = initBasisPointsRate;
         maximumFee = initMaximumFee;
        // 设置初始权限，合约部署者将成为合约所有者
        updateMasterMinter(newMasterMinter);
        updateBlacklister(newBlacklister);
        updatePauser(newPauser);
        transferOwnership(newOwner);

        uint256 lockedAmount = balanceOf(address(this));
        if (lockedAmount > 0) {
            _transfer(address(this), lostAndFound, lockedAmount);
        }
        
        _blacklist(address(this));

    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public override onlyPauser {
        super._pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public override onlyPauser {
        super._unpause();
    }

    /**
     * @notice Updates the pauser address.
     * @param _newPauser The address of the new pauser.
     */
    function updatePauser(address _newPauser) public override onlyOwner {
        require(
            _newPauser != address(0),
            "TokenUpgradeable: new pauser is the zero address"
        );
        pauser = _newPauser;
        emit PauserChanged(pauser);
    }

   /**
     * @notice Updates the blacklister address.
     * @param _newBlacklister The address of the new blacklister.
     */
    function updateBlacklister(address _newBlacklister) public override onlyOwner {
        require(
            _newBlacklister != address(0),
            "TokenUpgradeable: new blacklister is the zero address"
        );
        blacklister = _newBlacklister;
        emit BlacklisterChanged(blacklister);
    }

    /**
     * @inheritdoc Blacklistable
     */
    function _blacklist(address _account) internal override {
        _setBlacklistState(_account, true);
    }

    /**
     * @inheritdoc Blacklistable
     */
    function _unBlacklist(address _account) internal override {
        _setBlacklistState(_account, false);
    }

    /**
     * @dev Helper method that sets the blacklist state of an account on balanceAndBlacklistStates.
     * If _shouldBlacklist is true, we apply a (1 << 255) bitmask with an OR operation on the
     * account's balanceAndBlacklistState. This flips the high bit for the account to 1,
     * indicating that the account is blacklisted.
     *
     * If _shouldBlacklist if false, we reset the account's balanceAndBlacklistStates to their
     * balances. This clears the high bit for the account, indicating that the account is unblacklisted.
     * @param _account         The address of the account.
     * @param _shouldBlacklist True if the account should be blacklisted, false if the account should be unblacklisted.
     */
    function _setBlacklistState(address _account, bool _shouldBlacklist)
        internal
    {
        balanceAndBlacklistStates[_account] = _shouldBlacklist
            ? balanceAndBlacklistStates[_account] | (1 << 255)
            : balanceOf(_account);
    }

    /**
     * @dev Helper method that sets the balance of an account on balanceAndBlacklistStates.
     * Since balances are stored in the last 255 bits of the balanceAndBlacklistStates value,
     * we need to ensure that the updated balance does not exceed (2^255 - 1).
     * Since blacklisted accounts' balances cannot be updated, the method will also
     * revert if the account is blacklisted
     * @param _account The address of the account.
     * @param _balance The new JDSC token balance of the account (max: (2^255 - 1)).
     */
    function _setBalance(address _account, uint256 _balance) internal {
        require(
            _balance <= ((1 << 255) - 1),
            "TokenUpgradeable: Balance exceeds (2^255 - 1)"
        );
        require(
            !_isBlacklisted(_account),
            "TokenUpgradeable: Account is blacklisted"
        );

        balanceAndBlacklistStates[_account] = _balance;
    }

    /**
     * @inheritdoc Blacklistable
     */
    function _isBlacklisted(address _account)
        internal
        override
        view
        returns (bool)
    {
        return balanceAndBlacklistStates[_account] >> 255 == 1;
    }
 
    /**
     * @notice Increase the allowance by a given increment
     * @param spender   Spender's address
     * @param increment Amount of increase in allowance
     * @return True if successful
     */
    function increaseAllowance(address spender, uint256 increment)
        public
        override
        virtual
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(spender)
        returns (bool)
    {
        super.increaseAllowance(spender, increment);
        return true;
    }

    /**
     * @notice Decrease the allowance by a given decrement
     * @param spender   Spender's address
     * @param decrement Amount of decrease in allowance
     * @return True if successful
     */
    function decreaseAllowance(address spender, uint256 decrement)
        public
        override
        virtual
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(spender)
        returns (bool)
    {
        super.decreaseAllowance(spender, decrement);
        return true;
    }

    /**
     * @notice Updates the rescuer address.
     * @param newRescuer The address of the new rescuer.
     */
    function updateRescuer(address newRescuer) external override onlyOwner {
        require(
            newRescuer != address(0),
            "TokenUpgradeable: new rescuer is the zero address"
        );
        _rescuer = newRescuer;
        emit RescuerChanged(newRescuer);
    }

    /**
     * @notice Adds or updates a new minter with a mint allowance.
     * @param minter The address of the minter.
     * @param minterAllowedAmount The minting amount allowed for the minter.
     * @return True if the operation was successful.
     */
    function configureMinter(address minter, uint256 minterAllowedAmount)
        external
        override
        whenNotPaused
        onlyMasterMinter
        returns (bool)
    {
        minters[minter] = true;
        minterAllowed[minter] = minterAllowedAmount;
        emit MinterConfigured(minter, minterAllowedAmount);
        return true;
    }

    /**
     * @notice Updates the master minter address.
     * @param _newMasterMinter The address of the new master minter.
     */
    function updateMasterMinter(address _newMasterMinter) public override onlyOwner {
        require(
            _newMasterMinter != address(0),
            "TokenUpgradeable: new masterMinter is the zero address"
        );
        masterMinter = _newMasterMinter;
        emit MasterMinterChanged(masterMinter);
    }

    /**
     * @notice setParams the JDSC token contract.
     * @param newBasisPoints       the token fee ratio.
     * @param newMaxFee     the token handling fees.
     */
    function setParams
      (
        uint newBasisPoints, 
        uint newMaxFee
      ) 
        external 
        override 
        onlyOwner 
        returns (bool)
      {
        require(newBasisPoints < MAX_SETTABLE_BASIS_POINTS);
        require(newMaxFee < MAX_SETTABLE_FEE);

        basisPointsRate = newBasisPoints;
        maximumFee = newMaxFee.mul(uint(10)**_decimals);

        emit Params(basisPointsRate, maximumFee);
        return true;
    }

    /**
     * @notice Adds account to blacklist.
     * @param _account The address to blacklist.
     */
    function totalFee
      (
        address _account
      ) 
        external override 
        view 
        returns (uint256) 
    {
      require(_account != address(0), "TokenUpgradeable: _account is the zero address");
        return feeAccounts[_account];
    }

    function calcCommonFee
      (
        uint256 _value
      ) 
        public 
        override 
        view 
        returns (uint256)  
    {
        
      uint256 fee = (_value.mul(basisPointsRate)).div(1000);
      
      if (fee > maximumFee) {
          fee = maximumFee;
      }
      return fee;
    }

    function calcFee
      (
        address account,
        uint256 _value
      ) 
        public 
        override 
        view 
        returns (uint256 _fee)  
    {

      uint256 accountPointsRate = feeRateAccounts[account];
      if (accountPointsRate <= 0) {
        return uint256(0);
      }
      uint256 fee = (_value.mul(accountPointsRate)).div(1000);
      require(balanceOf(account) >= _value,"Insufficient balance, limit transaction");

      if (fee > maximumFee) {
          fee = maximumFee;
      }

      return fee;
    }


    /**
     * @notice Transfer the token from the caller and deduct the handling fee
     * @param feeAccount    Commission address.
     * @param to    Payee's address.
     * @param value Transfer amount.
     */
    function transferFee(
      address feeAccount, 
      address to, 
      uint value, 
      bytes memory orderId
    ) 
      public
      whenNotPaused
      onlyOwner
      returns (bool) 
    {
      require(feeAccount != address(0), "TokenUpgradeable: _feeAccount is the zero address");
      
      //deposit
      if (feeAccount == to) {
          _transfer(msg.sender, to, value);
          emit TransferFee(msg.sender, to, value, orderId);
          return true;
      }

      address _feeAccount = feeAccount;
      address _to = to;
      uint256 _value = value;
        
      uint fee = calcFee(_feeAccount, _value);
      uint sendAmount = _value.sub(fee);

      _transfer(msg.sender, _to, sendAmount);
      emit TransferFee(msg.sender, _to, sendAmount, orderId);

      if (fee > 0) {
        _transfer(msg.sender, _feeAccount, fee);
        emit TransferFee(msg.sender, _feeAccount, fee, orderId);
      }

      return true;
    }

    /**
     * @notice Execute a transfer with a signed authorization.And deduct the caller fee.
     * @dev EOA wallet signatures should be packed in the order of r, s, v.
     * @param feeAccount    Commission address.
     * @param from          Payer's address (Authorizer)
     * @param to            Payee's address
     * @param value         Amount to be transferred
     * @param validAfter    The time after which this is valid (unix time)
     * @param validBefore   The time before which this is valid (unix time)
     * @param nonce         Unique nonce
     * @param signature     Signature bytes signed by an EOA wallet or a contract wallet
     */
    function transferWithAuthorizationFee (
        address feeAccount, 
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes memory signature,
        bytes memory orderId
    ) 
        external 
        whenNotPaused
        onlyOwner
    {
        TransferAuthStruct memory dataInput = TransferAuthStruct(
          feeAccount, 
          from, 
          to, 
          nonce, 
          value, 
          validAfter, 
          validBefore, 
          signature, 
          orderId
        );
        
        uint256 fee = calcFee(feeAccount, dataInput.value);
        uint256 sendAmount = 0;

        uint256 balance = balanceOf(from);
        uint256 amount = dataInput.value + fee;
        
        if (balance >= amount) {
          sendAmount = dataInput.value;
        } 

        if (balance > dataInput.value && balance < amount) {
          sendAmount = fee > 0 ? dataInput.value.sub(fee) : dataInput.value;
        }

        //check
        _requireValidAuthorization(dataInput.from, dataInput.nonce, dataInput.validAfter, dataInput.validBefore);
         _requireValidSignature(
            dataInput.from,
            keccak256(
                abi.encode(
                    TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
                    dataInput.from,
                    dataInput.to,
                    dataInput.value,
                    dataInput.validAfter,
                    dataInput.validBefore,
                    dataInput.nonce
                )
            ),
            dataInput.signature
        );

        if (fee > 0) {
           _transfer(dataInput.from, dataInput.feeAccount, fee);
          emit TransferWithSign(
            dataInput.from, 
            dataInput.feeAccount, 
            dataInput.nonce,
            dataInput.orderId, 
            fee, 
            dataInput.validAfter, 
            dataInput.validBefore
          );
        }
        
        _transfer(dataInput.from, dataInput.to, sendAmount);
        emit TransferWithSign(
          dataInput.from, 
          dataInput.to, 
          dataInput.nonce, 
          dataInput.orderId, 
          sendAmount, 
          dataInput.validAfter, 
          dataInput.validBefore
        );
    }

     /**
     * @notice Execute a transfer with a signed authorization.And deduct the caller fee.
     * @param feeAccount    Commission address.
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
    function transferWithAuthorizationFee(
        address feeAccount, 
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes memory orderId
    ) 
        external 
        whenNotPaused 
        onlyOwner
    {
         TransferWithAuthStructRSV memory dataInput = TransferWithAuthStructRSV(
          feeAccount, 
          from, 
          to, 
          nonce, 
          value, 
          validAfter, 
          validBefore, 
          v, 
          r, 
          s, 
          orderId
        );

        uint256 fee = calcFee(feeAccount, dataInput.value);
        uint256 sendAmount = 0;

        uint256 balance = balanceOf(dataInput.from);
        uint256 amount = dataInput.value + fee;

        if (balance >= amount) {
          sendAmount = dataInput.value;
        } 

        if (balance > dataInput.value && balance < amount) {
          sendAmount = fee > 0 ? dataInput.value.sub(fee) : dataInput.value;
        }

        //check
        _requireValidAuthorization(dataInput.from, dataInput.nonce, dataInput.validAfter, dataInput.validBefore);
        _requireValidSignature(
            dataInput.from,
            keccak256(
                abi.encode(
                    TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
                    dataInput.from,
                    dataInput.to,
                    dataInput.value,
                    dataInput.validAfter,
                    dataInput.validBefore,
                    dataInput.nonce
                )
            ),
            abi.encodePacked(dataInput.r, dataInput.s, dataInput.v)
        );
        
        if (fee > 0) {
          _transfer(dataInput.from, dataInput.feeAccount, fee);
          emit TransferWithRSV(
            dataInput.from, 
            dataInput.feeAccount, 
            dataInput.nonce, 
            dataInput.orderId, 
            fee, 
            dataInput.validAfter, 
            dataInput.validBefore
          );
        }

        _transfer(dataInput.from, dataInput.to, sendAmount);
        emit TransferWithRSV(
          dataInput.from, 
          dataInput.to, 
          dataInput.nonce, 
          dataInput.orderId, 
          sendAmount, 
          dataInput.validAfter, 
          dataInput.validBefore
        );
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
    ) internal view override {
        require(
            SignatureChecker.isValidSignatureNow(
                signer,
                _hashTypedDataV4(dataHash),
                signature
            ),
            "TokenUpgradeable: invalid signature"
        );
    }
}
