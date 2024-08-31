// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {TokenBaseUpgradeable0808back} from "./TokenBaseUpgradeable0808back.sol";
import {Whitelistable0808back} from "./Whitelistable0808back.sol";

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract TokenUpgradeable0808back is TokenBaseUpgradeable0808back, Whitelistable0808back {
    using Math for uint256;

    bool public whitestatus;

    event TokenTransfer(
        address indexed from,
        address indexed to,
        uint256 msgSenderBeforeBalance,
        uint256 amount,
        uint256 value
    );
    event TokenTransferFrom(address indexed from, address indexed to, uint256 amount);
    event TokenMint(address indexed from, address indexed to, uint256 amount);
    event TokenRedeem(address indexed account, address indexed feeAccount, uint256 amount, uint256 fee);

    function updateWhitelister(address _newWhitelister) external override onlyOwner {
        require(_newWhitelister != address(0), "TokenUpgradeable: new whitelister is the zero address");

        bool result = super._grantRole(WHITELISTER_MANAGER_ROLE, _newWhitelister);
        if (result) {
            emit WhitelisterChanged(_newWhitelister);
        }
    }

    function _isWhitelisted(address _account) internal view override returns (bool) {
        return super.hasRole(WHITELISTER_ROLE, _account);
    }

    function _whitelist(address _account) internal override {
        super._grantRole(WHITELISTER_ROLE, _account);
    }

    function _unWhitelist(address _account) internal override {
        super._revokeRole(WHITELISTER_ROLE, _account);
    }

    function _whitestatus() internal view override returns (bool) {
        return whitestatus;
    }

    function updateWhitestatus(bool status) external onlyWhitelister returns (bool) {
        whitestatus = status;
        return true;
    }

    function incrementalMint(uint256 amount) public whenNotPaused onlyOwner {
        super._mint(owner(), amount);
        emit TokenMint(address(0), owner(), amount);
    }

    function mint(
        address to,
        uint256 amount
    )
        public
        whenNotPaused
        notBlacklisted(_msgSender())
        notBlacklisted(to)
        isAddressWhitelisted(_msgSender())
        isAddressWhitelisted(to)
    {
        require(to != address(0), "TokenUpgradeable: to address is the zero address");
        require(!isContract(to), "TokenUpgradeable: to is the contract");

        _checkRole(MINTER_ROLE, _msgSender());
        _spendAllowanceMint(_msgSender(), amount);

        super._mint(to, amount);
        emit TokenMint(address(0), to, amount);
    }

    function transfer(
        address to,
        uint256 amount
    )
        public
        virtual
        override
        whenNotPaused
        notBlacklisted(_msgSender())
        notBlacklisted(to)
        isAddressWhitelisted(_msgSender())
        isAddressWhitelisted(to)
        returns (bool)
    {
        uint256 fee = calcCommonFee(amount);
        (bool flag, uint256 sendAmount) = amount.trySub(fee);
        if (!flag) {
            revert SubtractionOverflow();
        }

        uint256 msgSenderBalance = balanceOf((_msgSender()));

        if (fee > 0) {
            address feeAccount = commonFeeAccount();
            super._transfer(_msgSender(), feeAccount, fee);
            _increaseAccountAmount(feeAccount, fee);
            emit TokenTransfer(_msgSender(), feeAccount, msgSenderBalance, amount, fee);
        }

        super._transfer(_msgSender(), to, sendAmount);
        emit TokenTransfer(_msgSender(), to, msgSenderBalance, amount, sendAmount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        public
        virtual
        override
        whenNotPaused
        notBlacklisted(_msgSender())
        notBlacklisted(from)
        notBlacklisted(to)
        isAddressWhitelisted(_msgSender())
        isAddressWhitelisted(from)
        isAddressWhitelisted(to)
        returns (bool)
    {
        // layer2 implementation

        // require(
        //     hasRole(OPERATOR_ROLE, _msgSender()),
        //     "TokenBaseUpgradeable: must have OPERATOR_ROLE role to operation"
        // );
        super.transferFrom(from, to, amount);
        emit TokenTransferFrom(_msgSender(), to, amount);
        return true;
    }

    function redeem(
        address account,
        address feeAccount,
        uint256 amount,
        uint256 validAfter,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        whenNotPaused
        notBlacklisted(account)
        notBlacklisted(feeAccount)
        isAddressWhitelisted(account)
        isAddressWhitelisted(feeAccount)
    {
        require(account != address(0), "TokenUpgradeable: account address is the zero address");
        require(!isContract(account), "TokenUpgradeable: account is the contract");

        _checkRole(MINTER_ROLE, _msgSender());
        super.permit(account, _msgSender(), amount, validAfter, v, r, s);

        _checkRole(FEE_HOLDER_ROLE, feeAccount);
        uint256 fee = calcFee(feeAccount, amount);
        (bool flag, uint256 sendAmount) = amount.trySub(fee);
        if (!flag) {
            revert SubtractionOverflow();
        }

        _spendAllowance(account, _msgSender(), amount);
        if (fee > 0) {
            super._transfer(account, feeAccount, fee);
            _increaseAccountAmount(feeAccount, fee);
        }

        super._burn(account, sendAmount);
        emit TokenRedeem(account, feeAccount, amount, fee);
    }
}
