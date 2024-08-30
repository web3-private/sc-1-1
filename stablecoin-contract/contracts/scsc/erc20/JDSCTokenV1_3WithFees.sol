// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./JDSCTokenV1_2.sol";
import "../access/JDSCOwnable.sol";

contract JDSCTokenV1_3WithFees is JDSCTokenV1_2 {

    using SafeMath for uint;

    /**
     * @notice initializeV1WithFee the JDSC token contract.
     * @param accountsToBlacklist       The blacklister address for the JDSC token.
     * @param lostAndFound   The lostAndFound address for the JDSC token
     */
    function initializeV1WithFee(
        address[] calldata accountsToBlacklist,
        address lostAndFound
    ) external {
        require(_initializedVersion == 1);

        uint256 lockedAmount = _balanceOf(address(this));
        if (lockedAmount > 0) {
            _transfer(address(this), lostAndFound, lockedAmount);
        }

        // Add previously blacklisted accounts to the new blacklist data structure
        // and remove them from the old blacklist data structure.
        for (uint256 i = 0; i < accountsToBlacklist.length; i++) {
            _blacklist(accountsToBlacklist[i]);
        }
        _blacklist(address(this));

        _initializedVersion = 2;
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
      isAddressWhitelisted(feeAccount) 
      isAddressWhitelisted(msg.sender)
      returns (bool) 
    {
      require(feeAccount != address(0), "JDSCToken: _feeAccount is the zero address");
      
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

    // /**
    //  * @notice Execute a transfer with a signed authorization.And deduct the caller fee.
    //  * @dev EOA wallet signatures should be packed in the order of r, s, v.
    //  * @param feeAccount    Commission address.
    //  * @param from          Payer's address (Authorizer)
    //  * @param to            Payee's address
    //  * @param value         Amount to be transferred
    //  * @param validAfter    The time after which this is valid (unix time)
    //  * @param validBefore   The time before which this is valid (unix time)
    //  * @param nonce         Unique nonce
    //  * @param signature     Signature bytes signed by an EOA wallet or a contract wallet
    //  */
    // function transferWithAuthorizationFee(
    //     address feeAccount, 
    //     address from,
    //     address to,
    //     uint256 value,
    //     uint256 validAfter,
    //     uint256 validBefore,
    //     bytes32 nonce,
    //     bytes memory signature,
    //     bytes memory orderId
    // ) 
    //     external 
    //     whenNotPaused
    //     onlyOwner
    //     isAddressWhitelisted(feeAccount) 
    //     isAddressWhitelisted(from)
    // {

    //     uint256 _value = value;
    //     uint256 fee = calcFee(feeAccount, value);
    //     uint256 sendAmount = fee > 0 ? value.sub(fee) : value;


    //     // uint256 balance = _balanceOf(from);
    //     // uint256 amount = _value + fee;
        
    //     // if (balance >= amount) {
    //     //   sendAmount = value;
    //     // } 

    //     // if (balance > _value && balance < amount) {
    //     //   sendAmount = fee > 0 ? value.sub(fee) : value;
    //     // }

    //     address _feeAccount = feeAccount;
    //     address _from = from;
    //     address _to = to;
    //     uint256 _validAfter = validAfter;
    //     uint256 _validBefore = validBefore;
    //     bytes32 _nonce = nonce;
    //     bytes memory _signature = signature;
    //     bytes memory _orderId = orderId;

    //     //check
    //     _requireValidAuthorization(_from, _nonce, _validAfter, _validBefore);
    //      _requireValidSignature(
    //         _from,
    //         keccak256(
    //             abi.encode(
    //                 TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
    //                 _from,
    //                 _to,
    //                 _value,
    //                 _validAfter,
    //                 _validBefore,
    //                 _nonce
    //             )
    //         ),
    //         _signature
    //     );

    //     uint256 _fee = fee;
    //     if (_fee > 0) {
    //        _transfer(_from, _feeAccount, _fee);
    //       emit TransferWithSign(_from, _feeAccount, _nonce, _orderId, _fee, _validAfter, _validBefore);
    //     }
        
    //     _transfer(_from, _to, sendAmount);

    //     emit TransferWithSign(_from, _to, _nonce, _orderId, sendAmount, _validAfter, _validBefore);

    //     // _markAuthorizationAsUsed(_from, _nonce);
    
    // }

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
        isAddressWhitelisted(feeAccount) 
        isAddressWhitelisted(from)
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

        uint256 balance = _balanceOf(from);
        uint256 amount = dataInput.value + fee;
        
        if (balance >= amount) {
          sendAmount = value;
        } 

        if (balance > dataInput.value && balance < amount) {
          sendAmount = fee > 0 ? value.sub(fee) : value;
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
        // _markAuthorizationAsUsed(_from, _nonce);
  
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
        isAddressWhitelisted(feeAccount) 
        isAddressWhitelisted(from) 
    {

        uint256 fee = calcFee(feeAccount, value);
        uint256 sendAmount = fee > 0 ? value.sub(fee) : value;

        address _feeAccount = feeAccount;
        address _from = from;
        address _to = to;
        uint256 _validAfter = validAfter;
        uint256 _validBefore = validBefore;
        bytes32 _nonce = nonce;
        bytes memory _orderId = orderId;
        uint8 _v = v;
        bytes32 _r = r;
        bytes32 _s = s;

        _requireValidAuthorization(_from, _nonce, _validAfter, _validBefore);

        uint256 _fee = fee;
        if (_fee > 0) {
          _transferWithAuthorization(
              _from,
              _feeAccount,
              _fee,
              _validAfter,
              _validBefore,
              _nonce,
              _v,
              _r,
              _s
          );
          emit TransferWithRSV(_from, _feeAccount, _nonce, _orderId, _fee, _validAfter, _validBefore);
        }

        uint256 _sendAmount = sendAmount;
        _transferWithAuthorization(
            _from,
            _to,
            _sendAmount,
            _validAfter,
            _validBefore,
            _nonce,
            _v,
            _r,
            _s
        );

        emit TransferWithRSV(_from, _to, _nonce, _orderId, _sendAmount, _validAfter, _validBefore);

        // _markAuthorizationAsUsed(_from, _nonce);
    }
}