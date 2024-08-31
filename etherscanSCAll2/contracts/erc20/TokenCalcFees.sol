// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./JDSCTokenV1.sol";
// import "../access/JDSCOwnable.sol";

contract TokenCalcFees is JDSCTokenV1 {

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

    function calcFee(uint _value) public view returns (uint) {
      // basisPointsRate thousandths
      uint fee = (_value.mul(basisPointsRate)).div(10000);
      if (fee > maximumFee) {
          fee = maximumFee;
      }
      return fee;
    }
}