// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./JDSCTokenV1.sol";
import "../access/JDSCOwnable.sol";

contract JDSCTokenV1WithFees is JDSCTokenV1 {

    using SafeMath for uint;

    // Additional variables for use if transaction fees ever became necessary
    uint256 public basisPointsRate = 0;
    uint256 public maximumFee = 0;
    uint256 constant MAX_SETTABLE_BASIS_POINTS = 20;
    uint256 constant MAX_SETTABLE_FEE = 5000;

    uint public constant MAX_UINT = 2**256 - 1;

    mapping(address => uint256) public feeAccounts;

    event Params(uint feeBasisPoints, uint maxFee);


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
        onlyOwner 
      {
        require(newBasisPoints < MAX_SETTABLE_BASIS_POINTS);
        require(newMaxFee < MAX_SETTABLE_FEE);

        basisPointsRate = newBasisPoints;
        maximumFee = newMaxFee.mul(uint(10)**decimals);

        emit Params(basisPointsRate, maximumFee);
    }

    /**
     * @notice Adds account to blacklist.
     * @param _account The address to blacklist.
     */
    function totalFee(address _account) external view returns (uint256) {
      require(_account != address(0), "JDSCToken: _account is the zero address");
        return feeAccounts[_account];
    }

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

    function calcFee(uint _value) public view returns (uint) {
      // basisPointsRate thousandths
      uint fee = (_value.mul(basisPointsRate)).div(10000);
      if (fee > maximumFee) {
          fee = maximumFee;
      }
      return fee;
    }

    // /**
    //  * @notice Transfer the token from the caller and deduct the handling fee
    //  * @param _feeAccount    Commission address.
    //  * @param _to    Payee's address.
    //  * @param _value Transfer amount.
    //  */
    // function transferFee(
    //     address _feeAccount, 
    //     address _to, 
    //     uint _value
    // ) 
    //   public 
    //   whenNotPaused
    //   notBlacklisted(msg.sender)
    //   notBlacklisted(_to)
    //   returns (bool) 
    // {
    //   require(_feeAccount != address(0), "JDSCToken: _feeAccount is the zero address");
      
    //   uint fee = calcFee(_value);
    //   uint sendAmount = _value.sub(fee);

    //   _transfer(msg.sender, _to, sendAmount);
    //   if (fee > 0) {
    //     _transfer(msg.sender, _feeAccount, fee);
    //   }
    //   return true;
    // }

    // /**
    //  * @notice Transfers tokens from an address to another by spending the caller's allowance.And deduct the caller fee.
    //  * @dev The caller must have some JDSC token allowance on the payer's tokens.
    //  * @param _feeAccount    Commission address.
    //  * @param _from  Payer's address.
    //  * @param _to    Payee's address.
    //  * @param _value Transfer amount.
    //  * @return True if the operation was successful.
    //  */
    // function transferFromFee(
    //     address _feeAccount, 
    //     address _from, 
    //     address _to, 
    //     uint256 _value
    // ) 
    //   public 
    //   whenNotPaused
    //   isAddressWhitelisted(msg.sender)    
    //   notBlacklisted(msg.sender)
    //   notBlacklisted(_from)
    //   notBlacklisted(_to)
    //   returns (bool) 
    // {
    //   require(_feeAccount != address(0), "JDSCToken: _feeAccount is the zero address");

    //   uint fee = calcFee(_value);
    //   uint sendAmount = _value.sub(fee);

    //   _transfer(_from, _to, sendAmount);
    //   if (fee > 0) {
    //     _transfer(_from, _feeAccount, fee);
    //   }

    //   return true;
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
    function transferWithAuthorizationFee(
        address feeAccount, 
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
        isAddressWhitelisted(feeAccount) 
        isAddressWhitelisted(from)
    {
        uint fee = calcFee(value);
        uint sendAmount = value.sub(fee);

        _transferWithAuthorization(
        // transferWithAuthorization(
            from,
            to,
            sendAmount,
            validAfter,
            validBefore,
            nonce,
            signature
        );

        if (fee > 0) {
          _transferWithAuthorization(
          // transferWithAuthorization(
            from,
            feeAccount,
            fee,
            validAfter,
            validBefore,
            nonce,
            signature
          );
        }
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
        bytes32 s
    ) 
        external 
        whenNotPaused 
        isAddressWhitelisted(feeAccount) 
        isAddressWhitelisted(from) 
    {

        uint fee = calcFee(value);
        uint sendAmount = value.sub(fee);

        _transferWithAuthorization(
        // transferWithAuthorization(
            from,
            to,
            sendAmount,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );

        if (fee > 0) {
          _transferWithAuthorization(
          // _transferWithAuthorization(
              from,
              feeAccount,
              fee,
              validAfter,
              validBefore,
              nonce,
              v,
              r,
              s
          );
        }
    }
}