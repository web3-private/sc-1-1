// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {TokenBaseUpgradeable0717Back} from "./TokenBaseUpgradeable0717Back.sol";
import {Whitelistable0717Back} from "./Whitelistable0717Back.sol";

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract TokenUpgradeable0717Back is TokenBaseUpgradeable0717Back, Whitelistable0717Back {
    using Math for uint256;

    bool public whitestatus;

    event TokenTransfer(address indexed from, address indexed to, uint256 amount, uint256 value);
    event TokenTransferFrom(address indexed from, address indexed to, uint256 amount);
    event TokenMint(address indexed from, address indexed to, uint256 amount);
    event TokenRedeem(address indexed account, address indexed feeAccount, uint256 amount, uint256 fee);

    function updateWhitelister(address _newWhitelister) external override onlyOwner {
        require(_newWhitelister != address(0));
        // require(_newWhitelister != address(0), "TokenUpgradeable: new whitelister is the zero address");

        if (_newWhitelister != super.getRoleMember(WHITELISTER_MANAGER_ROLE, uint256(0))) {
            super._grantRole(WHITELISTER_MANAGER_ROLE, _newWhitelister);
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
        onlyUnlock
    {
        require(to != address(0), "TokenUpgradeable: to address is the zero address");
        if (to != owner()) {
            _checkRole(MINTER_ROLE, _msgSender());
            _spendAllowanceMint(_msgSender(), amount);
        }

        if (to == owner()) {
            require(_msgSender() == owner());
        }

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
        onlyUnlock
        returns (bool)
    {
        uint256 fee = calcCommonFee(amount);
        (bool flag, uint256 sendAmount) = amount.trySub(fee);
        if (!flag) {
            revert SubtractionOverflow();
        }

        if (fee > 0) {
            address feeAccount = commonFeeAccount();
            super._transfer(_msgSender(), feeAccount, fee);
            emit TokenTransfer(_msgSender(), feeAccount, amount, fee);
        }

        super._transfer(_msgSender(), to, sendAmount);
        emit TokenTransfer(_msgSender(), to, amount, sendAmount);

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
        onlyUnlock
        returns (bool)
    {
        // layer2 implementation

        // require(
        //     hasRole(OPERATOR_ROLE, _msgSender()),
        //     "TokenBaseUpgradeable: must have OPERATOR_ROLE role to operation"
        // );
        // super.transferFrom(from, to, amount);
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
        onlyUnlock
    {
        require(account != address(0), "TokenUpgradeable: account address is the zero address");
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
            _updateFeeAccountAmount(feeAccount, fee);
        }

        super._burn(account, sendAmount);
        emit TokenRedeem(account, feeAccount, amount, fee);
    }
}
