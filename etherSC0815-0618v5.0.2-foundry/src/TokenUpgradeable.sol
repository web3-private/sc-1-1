// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {TokenBaseUpgradeable} from "./TokenBaseUpgradeable.sol";
import {Whitelistable} from "./Whitelistable.sol";

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title This is a business expansion contract.
 * @author Asan
 * @notice This is an ERC20-compliant JDSC stablecoin business extension contract.
 * @dev It implements some basic token functions and is upgradable.
 */
contract TokenUpgradeable is TokenBaseUpgradeable, Whitelistable {
    using Math for uint256;

    //The whitelist status is enabled.
    bool public whitestatus;

    /**
     * @dev Define token transfer events.
     * @param from from address.
     * @param to to address.
     * @param msgSenderBeforeBalance Balance from account address before transfer.
     * @param amount transfer amount.
     * @param value fee or the amount of the transfer after deducting the fee.
     */
    event TokenTransfer(
        address indexed from, address indexed to, uint256 msgSenderBeforeBalance, uint256 amount, uint256 value
    );

    /**
     * @dev Define token transfrom events
     * @param from from address.
     * @param to to address.
     * @param amount transfrom amount.
     */
    event TokenTransferFrom(address indexed from, address indexed to, uint256 amount);

    /**
     * @dev Define token mint events
     * @param from from address.
     * @param to to address.
     * @param amount mint amount.
     */
    event TokenMint(address indexed from, address indexed to, uint256 amount);

    /**
     * @dev Define token redeem events
     * @param account Redemption account address.
     * @param feeAccount  fee account address.
     * @param amount Redemption amount.
     * @param fee fee amount.
     */
    event TokenRedeem(address indexed account, address indexed feeAccount, uint256 amount, uint256 fee);

    /**
     * @notice Updates the whitelister address. only the owner role is invoked.
     * @dev Updates the whitelister address.
     * @param _newManager The address of the new Whitelist Manager.
     * @inheritdoc Whitelistable
     */
    function updateWhitelistManager(address _newManager) external override onlyOwner {
        require(_newManager != address(0), "TokenUpgradeable: new whitelist manager is the zero address");

        bool result = super._grantRole(WHITELIST_MANAGER_ROLE, _newManager);
        if (result) {
            emit UpdateWhitelistManager(_newManager);
        }
    }

    /**
     * @dev Checks if account is whitelisted.
     * @param _account The address to check.
     * @return true if the account is whitelisted, false otherwise.
     * @inheritdoc Whitelistable
     */
    function _isWhitelisted(address _account) internal view override returns (bool) {
        return super.hasRole(WHITELIST_MEMBER_ROLE, _account);
    }

    /**
     * @dev Helper method that addWhitelist an account.
     * @param _account The address to whitelist.
     * @inheritdoc Whitelistable
     */
    function _addWhitelist(address _account) internal override {
        super._grantRole(WHITELIST_MEMBER_ROLE, _account);
    }

    /**
     * @dev Helper method that removeWhitelist an account.
     * @param _account The address to unwhitelist.
     * @inheritdoc Whitelistable
     */
    function _removeWhitelist(address _account) internal override {
        super._revokeRole(WHITELIST_MEMBER_ROLE, _account);
    }

    /**
     * @dev Querying whitelist status.
     * @inheritdoc Whitelistable
     */
    function _whitestatus() internal view override returns (bool) {
        return whitestatus;
    }

    /**
     * @dev Update the whitelist status. only the whitelister role is invoked.
     * @param status status variable.
     */
    function updateWhitestatus(bool status) external onlyWhitelistManager returns (bool) {
        whitestatus = status;
        return true;
    }

    /**
     * @notice Incremental mint function.
     * @dev Incremental mint function, only the owner role calls, mint amount into the owner account address.
     * @param amount Incremental mint amount.
     * @dev Emits a {TokenMint} event.
     */
    function incrementalMint(uint256 amount) public whenNotPaused onlyOwner {
        super._mint(owner(), amount);
        emit TokenMint(address(0), owner(), amount);
    }

    /**
     * @notice The mint function gives mint tokens to the address.
     * @dev The mint function gives mint tokens to the address, only the MINTER_ROLE role callss.
     * @param to Increment mint receives the address.
     * @param amount Incremental mint amount.
     * @dev Emits a {TokenMint,ApprovalMint} event.
     */
    function mint(address to, uint256 amount)
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

    /**
     * @notice Transfer token function, transfer token to address.
     * @dev Transfer token function, transfer token to address.
     * @param to The recipient's account address.
     * @param amount transfer amount.
     * @inheritdoc ERC20Upgradeable
     * @dev Emits a {TokenTransfer} event.
     */
    function transfer(address to, uint256 amount)
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

    /**
     * @notice Transfer token function, transfer token to address.
     * @dev Transfer token function, transfer token to address.
     * @param from Account address of the sender.
     * @param to The recipient's account address.
     * @param amount transfer amount.
     * @inheritdoc ERC20Upgradeable
     * @dev Emits a {TokenTransferFrom} event.
     */
    function transferFrom(address from, address to, uint256 amount)
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

    /**
     * @notice Token redemption function.
     * @dev Token redemption function, only the MINTER_ROLE role callss.
     *
     * The account redeemes the stablecoin amount authorizes the platform allowance and signs the transaction.
     * The platform initiates a transaction using the account amount, charges the fee and burns the balance of
     * the amount minus the fee.
     *
     * @param account Account address to redeem stablecoins.
     * @param feeAccount fee account address.
     * @param amount redemption amount.
     * @param validAfter Signature validity time.
     * @param v Recovery ID.
     * @param r Signature R.
     * @param s Signature S.
     * @dev Emits a {TokenRedeem} event.
     */
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
