// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

abstract contract AbstractJDSCTokenFee {

    // Additional variables for use if transaction fees ever became necessary
    uint256 public basisPointsRate;
    uint256 public maximumFee;
    uint256 constant MAX_SETTABLE_BASIS_POINTS = 20;
    uint256 constant MAX_SETTABLE_FEE = 5000 * 1e2;

    uint public constant MAX_UINT = 2**256 - 1;

    mapping(address => uint256) public feeAccounts;

    mapping(address => uint256) public feeRateAccounts;

    address[] public feeAccountKeys;

    event Params(uint feeBasisPoints, uint maxFee);

    event TransferFee(address indexed from,address indexed to,uint256 value,bytes orderId);

    event TransferWithSign(address indexed from,address indexed to,bytes32 indexed nonce,bytes orderId,uint256 value,uint256 validAfter,uint256 validBefore);

    event TransferWithRSV(address indexed from,address indexed to,bytes32 indexed nonce,bytes orderId,uint256 value,uint256 validAfter,uint256 validBefore);
    
    struct TransferAuthStruct {
        address feeAccount;
        address from;
        address to;
        bytes32 nonce;
        uint256 value;
        uint256 validAfter;
        uint256 validBefore;
        bytes signature;
        bytes orderId;
    }

    struct TransferWithAuthStructRSV {
        address feeAccount;
        address from;
        address to;
        bytes32 nonce;
        uint256 value;
        uint256 validAfter;
        uint256 validBefore;
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes orderId;
    }

    struct SendAmountFeeStruct {
        uint256 balance;
        uint256 value;
        uint256 fee;
    }

    function setParams(uint newBasisPoints, uint newMaxFee) external virtual returns (bool);

    function calcCommonFee(uint256 _value) external virtual view returns (uint256);

    function calcFee(address account, uint256 _value) external virtual view returns (uint256);
    
    // function calcSendAmount(uint256 _balance, uint256 _fee, uint256 _value) public virtual pure returns (uint256 amount, uint256 fee);
    
    function totalFee(address _account) external virtual view returns (uint256);

    function addFeeAccount(address account) public {
        uint256 amount = 0;
        feeAccounts[account] = amount;

        uint256 newBasisPoints =  0;
        feeRateAccounts[account] = newBasisPoints;
        if (!contains(account)) {
            feeAccountKeys.push(account);
        }
    }

    function contains(address account) internal view returns (bool) {
        for (uint256 i = 0; i < feeAccountKeys.length; i++) {
            if (feeAccountKeys[i] == account) {
                return true;
            }
        }
        return false;
    }

    function updateFeeAccountAmount(address account, uint256 amount) public {
        uint256 oldAmount = feeAccounts[account];
        uint256 newAmount = oldAmount + amount;
        feeAccounts[account] = newAmount;
    }

    function removeFeeAccount(address account) public {
        delete feeAccounts[account];
        for (uint256 i = 0; i < feeAccountKeys.length; i++) {
            if (feeAccountKeys[i] == account) {
                delete feeAccountKeys[i];
                break;
            }
        }
    }

    function getFeeAccounts() external view returns (address[] memory) {
        return feeAccountKeys;
    }


    function setAccountBasisPointsRate(address account ,uint newBasisPoints) external virtual returns (bool) {
        require(newBasisPoints > 0 , "The newBasisPoints must be greater than 0");
        feeRateAccounts[account] = newBasisPoints;
        return true;
    }

}
