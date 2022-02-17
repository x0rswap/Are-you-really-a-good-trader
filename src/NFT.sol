// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {IERC20} from "./interfaces/IERC20.sol";
import {IUniswapV2Pair} from "./interfaces/IUniswapV2Pair.sol";

//import {ERC721} from "lib/solmate/src/test/utils/mocks/MockERC20.sol";

contract NFT /* is ERC721, ERC721Enumerable */ {
    uint256 public totalSupply;
    mapping(address => uint256[]) public balances;
    mapping(uint256 => address) public ownerOf; //Information about the nft
    mapping(uint256 => Trade) public trades; //Information about the nft

    struct Trade {
        uint start0; uint end0;
        uint start1; uint end1;
    }

    IUniswapV2Pair swap;
    //uint limit0;
    //uint limit1;

    constructor(address _v2pair/*, uint _limit0, uint _limit1*/) {
        //require(_limit0 == 0 || _limit1 == 0);
        //limit0 = _limit0;
        //limit1 = _limit1;
        swap = IUniswapV2Pair(_v2pair);
    }

    /* Transfers/Approvals are disabled, so we don't use these events */
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /* Only functions of ERC721 we'll actually use */
    function balanceOf(address owner) external view returns (uint256) { return balances[owner].length; }
    //function ownerOf(uint256 tokenId) external view returns (address);
    
    /* We disable all transfers, as well as approvals */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable { require(false); }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable { require(false); }
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable { require(false); }
    function approve(address _approved, uint256 _tokenId) external payable { require(false); }
    function setApprovalForAll(address _operator, bool _approved) external { require(false); }
    function getApproved(uint256 _tokenId) external view returns (address) { require(false); }
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) { return false; }

    /* ERC721Enumerable */
    //function totalSupply() external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256) { return index; }
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) { return balances[owner][index]; }

    /* Execute a trade to mint an NFT */
    function swapAndMint(uint amount0_swap, uint amount1_swap, uint amount0_uniswap, uint amount1_uniswap) external {
        IERC20 token0 = IERC20(swap.token0());
        IERC20 token1 = IERC20(swap.token1());
        address addr = address(swap);
        uint start0 = token0.balanceOf(addr);
        uint start1 = token1.balanceOf(addr);
        //require(amount0 == 0 || amount1 == 0);
        //require(amount0 >= limit0 || amount1 >= limit1);
        address from = msg.sender;
        if (amount0_swap > 0)
            token0.transferFrom(from, addr, amount0_swap);
        if (amount1_swap > 0)
            token1.transferFrom(from, addr, amount1_swap);
        swap.swap(amount0_uniswap, amount1_uniswap, from, "");
        uint end0 = token0.balanceOf(addr);
        uint end1 = token1.balanceOf(addr);
        _mint(from, start0, end0, start1, end1);
    }
    /* Private function to mint the nft */
    function _mint(address to, uint start0, uint end0, uint start1, uint end1) private {
        balances[to].push(totalSupply);
        Trade memory t = Trade({start0:start0, end0:end0, start1:start1, end1:end1});
        trades[totalSupply] = t;
        totalSupply += 1;
    }
}
