// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {TokenBaseUpgradeable0712} from "./TokenBaseUpgradeable0712.sol";
import {Whitelistable0712} from "./Whitelistable0712.sol";

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
// import {TokenErrors} from "./interfaces/TokenErrors.sol";

contract TokenUpgradeable0712 is TokenBaseUpgradeable0712, Whitelistable0712 {
    using Math for uint256;

    bool public whitestatus;

    function updateWhitelister(address _newWhitelister) external override onlyOwner {
        require(_newWhitelister != address(0), "TokenUpgradeable: new whitelister is the zero address");
        // TODO
        super._grantRole(WHITELISTER_MANAGER_ROLE, _newWhitelister);
        emit WhitelisterChanged(_newWhitelister);
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
        if (to != owner()) {
            _checkRole(MINTER_ROLE, _msgSender());
            _spendAllowanceMint(_msgSender(), amount);
        }

        super._mint(to, amount);
    }

    function transfer(
        address to,
        uint256 amount
    )
        public
        virtual
        override
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        isAddressWhitelisted(msg.sender)
        isAddressWhitelisted(to)
        returns (bool)
    {
        uint256 fee = calcCommonFee(amount);
        (bool flag, uint256 sendAmount) = amount.trySub(fee);
        if (!flag) {
            revert SubtractionOverflow();
        }

        if (fee > 0) {
            address feeAccount = commonFeeAccount();
            super._transfer(msg.sender, feeAccount, fee);
        }

        super._transfer(msg.sender, to, sendAmount);

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
            //            _spendAllowance(account, _msgSender(), fee);
            super._transfer(account, feeAccount, fee);
            _updateFeeAccountAmount(feeAccount, fee);
        }

        super._burn(account, sendAmount);
        //        super.burnFrom(account, sendAmount);
    }
}
