

## 一、部署主要合约 JDSCTokenV1_3WithFees

使用用户A部署合约

用户A：0x3b1b69c8398a4aae97d8b4c6255652383c28855a

合约地址：0x173C2d686F464767d7d5E9576dB82796c6971B81



## 二、合约代理部署 JDSCTokenProxy

使用用户A部署代理合约

用户A：0x3b1b69c8398a4aae97d8b4c6255652383c28855a

代理合约地址：0x42fAd15b13EBc1126BE2318ad876cb8e5f4b1C3E

```solidity
_implementation: 实现合约的地址（例如：0x58d8746570dfbAB2788FcC21db1F7cEec35295B5）
deploy（address _implementation）
```



## 三、初始化合约（通过代理）



使用用户B调用

用户B：0xDf244949e5262D33509A70d2b3A674AAD9414a01

```solidity
依次调用初始化函数：initialize，initializeV1WithFee

function initialize(
        string memory tokenName,
        string memory tokenSymbol,
        string memory tokenCurrency,
        uint8 tokenDecimals,
        uint256 tokenSupply,
        address newMasterMinter,
        address newPauser,
        address newBlacklister,
        address newOwner
    ) 
    
   参数示例：
    "jdscToken",
    "jdsc",
    "HKD"
    2,
    2100000,
    0xF896339CA453B561BfEec5b7Afdb964668E421e3,
    0xF896339CA453B561BfEec5b7Afdb964668E421e3,
    0xF896339CA453B561BfEec5b7Afdb964668E421e3,
    0xF896339CA453B561BfEec5b7Afdb964668E421e3
    
  function initializeV1WithFee(
        address[] calldata accountsToBlacklist,
        address lostAndFound
    ) 
    
   参数示例：
   ["0xF896339CA453B561BfEec5b7Afdb964668E421e3"],
   0xF896339CA453B561BfEec5b7Afdb964668E421e3
```

## 四、设置公用手续费率

调用函数setParams,注意使用步骤三设置的 newOwner 用户C( 0xF896339CA453B561BfEec5b7Afdb964668E421e3) 调用

```solidity
  function setParams
      (
        uint newBasisPoints, 
        uint newMaxFee
      ) external 
        onlyOwner 
        
        参数示例： 
        1
        50
```

## 五、设置个人手续费率

调用函数setAccountBasisPointsRate ,注意使用步骤三设置的 newOwner 用户C( 0xF896339CA453B561BfEec5b7Afdb964668E421e3) 调用

```solidity
function setAccountBasisPointsRate(
	address account ,
	uint newBasisPoints
) 
external 
virtual 
returns (bool) 
参数示例： 
0x9fC11b52468Ea30D46541e667a08eB584f82C187
1
```





## 六、白名单管理员设置

注意使用步骤三设置的 newOwner 用户C( 0xF896339CA453B561BfEec5b7Afdb964668E421e3) 调用

```solidity
function updateWhitelister(
	address _newWhitelister
	) 
	external 
	onlyOwner
	
参数示例：
0xF896339CA453B561BfEec5b7Afdb964668E421e3

```



## 七、白名单设置

注意使用步骤六设置的 Whitelister 用户( 0xF896339CA453B561BfEec5b7Afdb964668E421e3) 调用

```solidity
function whitelist(
	address _account
	) 
	external 
	onlyWhitelister
	
	参数示例：
1、0xF896339CA453B561BfEec5b7Afdb964668E421e3
2、0x2A049b90Ba0f5656F3bdcC50067A1E3470a4Be09
3、0xf896339ca453b561bfeec5b7afdb964668e421e3

```

## 八、白名单查询

```solidity
function isWhitelisted(address _account) external view returns (bool)
参数示例：0xF896339CA453B561BfEec5b7Afdb964668E421e3
```


## 九、余额查询

```solidity
    function _balanceOf(address _account)
        internal
        view
        returns (uint256)
    {
    参数示例：0xF896339CA453B561BfEec5b7Afdb964668E421e3
```

## 十、配置minter账户

```solidity
    function configureMinter(address minter, uint256 minterAllowedAmount)
        external
        whenNotPaused
        onlyMasterMinter
        returns (bool)
    {
```



## 