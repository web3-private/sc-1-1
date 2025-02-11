pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract Safe {
    receive() external payable {}

    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract SafeTest is Test {
    Safe safe;

    // Needed so the test contract itself can receive ether
    // when withdrawing
    receive() external payable {}

    function setUp() public {
        safe = new Safe();
    }

    function testWithdraw() public {
        payable(address(safe)).transfer(1 ether);
        uint256 preBalance = address(this).balance;
        safe.withdraw();
        uint256 postBalance = address(this).balance;
        assertEq(preBalance + 1 ether, postBalance);
    }

    // function testWithdraw(uint256 amount) public {
    //     payable(address(safe)).transfer(amount);
    //     uint256 preBalance = address(this).balance;
    //     safe.withdraw();
    //     uint256 postBalance = address(this).balance;
    //     assertEq(preBalance + amount, postBalance);
    // }

    function testFuzz_Withdraw(uint96 amount) public {
    vm.assume(amount > 0.1 ether);
    // snip
}

}
