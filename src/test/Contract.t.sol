// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "./utils/vm.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IUniswapV2Factory.sol";

import {MockERC20} from "lib/solmate/src/test/utils/mocks/MockERC20.sol";
import {NFT} from "../NFT.sol";

contract ContractTest is DSTest {
    IUniswapV2Factory v2factory;
    MockERC20 token0;
    MockERC20 token1;
    address user0;
    address user1;
    IUniswapV2Pair swap;
    NFT nft;

    function setUp() public {
        /* Cheatcode of foundry */
        Vm vm = Vm(HEVM_ADDRESS); //0x7109709ECfa91a80626fF3989D68f67F5b1DD12D

        /* Load uniswap v2 factory */
        bytes memory args = abi.encode(address(999));
        bytes memory bytecode = abi.encodePacked(vm.getCode("out/UniswapV2Factory.sol/UniswapV2Factory.json"), args);
        address v2factory_;
        assembly {
            v2factory_ := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        v2factory = IUniswapV2Factory(v2factory_);

        /* Two different users */
        user0 = address(1);
        user1 = address(2);

        /* Load two tokens */
        token0 = new MockERC20("Token0", "T1", 18);
        token1 = new MockERC20("Token1", "T2", 18);

        /* Create the uniswap pool */
        swap = IUniswapV2Pair(v2factory.createPair(address(token0), address(token1)));

        /* Load the NFT */
        nft = new NFT(address(swap));

        /* Mint some tokens to accounts and deposit liquidity */
        address me = address(this);
        token0.mint(me, 1e8); token0.mint(user0, 1e8);
        token1.mint(me, 1e8); token1.mint(user1, 1e8);
        token0.transfer(address(swap), 2e5);
        token1.transfer(address(swap), 2e5);
        swap.mint(me);
    }

    function testGoodInit() public {
        require(address(token0) != address(token1));
        require(v2factory.allPairsLength() == 1);
        require(swap.token0() == address(token0));
        require(swap.token1() == address(token1));
        require(token0 != token1);
        require(user0 != user1);
    }

    function testSwap() public {
        address me = address(this);
        require(token1.balanceOf(address(swap)) == 2e5);
        token0.transfer(address(swap), 2e5 + 1000);
        swap.swap(0, 1e5, me, "");
        require(token1.balanceOf(address(swap)) == 1e5);
    }
    function testMintNFT() public {
        address me = address(this);
        require(nft.balanceOf(me) == 0);
        /* Allow the NFT contract to make a swap */
        token0.approve(address(nft), 1e8);
        /* Mint the NFT */
        nft.swapAndMint(2e5 + 1000, 0, 0, 1e5);
        require(nft.balanceOf(me) == 1);
    }
}
