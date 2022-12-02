// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "forge-std/Test.sol";

contract SwapTest is Test {
    address myAccount = 0x7ACAC5D508f839200EBB3bb92EfdfE4BD5cd1e49;
    address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address uniswapV2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    uint256 amount = 2000 * 10 ** 6;

    function setUp() external {
        vm.startPrank(0x0A59649758aa4d66E25f08Dd01271e891fe52199);
        _transfer(myAccount, amount);
        vm.stopPrank();
    }

    function testSwapUsdcToDai() external {
        uint256 balanceBefore = _balanceOf(dai, myAccount);
        address[] memory path = new address[](2);
        path[0] = usdc;
        path[1] = dai;

        vm.startPrank(myAccount);
        usdc.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                uniswapV2Router,
                amount
            )
        );
        (, bytes memory data) = uniswapV2Router.call(
            abi.encodeWithSignature(
                "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)",
                amount,
                1,
                path,
                myAccount,
                block.timestamp + 1 minutes
            )
        );
        vm.stopPrank();

        uint256[] memory amounts = abi.decode(data, (uint256[]));
        uint256 balanceAfter = _balanceOf(dai, myAccount);
        assertEq(balanceAfter, balanceBefore + amounts[path.length - 1]);
    }

    function _balanceOf(address token, address who)
        private
        returns (uint256)
    {
        (,bytes memory data) = token.call(
            abi.encodeWithSignature(
                "balanceOf(address)",
                who
            )
        );

        return abi.decode(data, (uint256));
    }

    function _transfer(address to, uint256 amount) private {
        (
            bool success,
            bytes memory data
        ) = usdc.call(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                to,
                amount
            )
        );

        require(
            success &&
            (
                data.length == 0 ||
                abi.decode(data, (bool))
            )
        );
    }
}