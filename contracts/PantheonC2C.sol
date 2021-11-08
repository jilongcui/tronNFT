
import "./utils/math/SafeMath.sol";
import "./utils/Address.sol";
import "./token/ERC721/IERC721.sol";
import "./token/ERC20/IERC20.sol";
import "./access/Ownable.sol";
import "./token/ERC721/utils/ERC721Holder.sol";

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

contract BeanC2C is Ownable, ERC721Holder{

  uint MIN_DEPOSITE = 1*10**6; // 1PAN
  uint MAX_DEPOSITE_ETH = 0.1*10**18; // ether; //10
  uint MAX_DEPOSITE_SCC = 1*10**18; //10**12

  enum C2CStatus{
    C2C_ONLINE,
    C2C_OFFLINE,
    C2C_LOCKED,
    C2C_PAUSED
  }

  struct C2CItem {
    address author;
    uint nftId;
    uint value;
    // C2CStatus status;
    uint timestamp;
  }

  using SafeMath for uint;

  event C2CDepositItemEvent(address owner, uint nftId, uint value, uint timestamp);
  event C2CBuyItemEvent(address owner, uint nftId, uint value, uint timestamp);
  event C2CDownItemEvent(address owner, uint nftId, uint timestamp);

  // 代币的地址
  address payable public tokenAddress;
  IERC20 public token;

  // NFTToken对象
  address nftAddress;
  IERC721 public nftToken;
  address public beneficience;

  // 发布者
  address public chairperson;
  C2CItem[] public c2cAllItems;
  
  bool public c2cEnabled;
  // // 剩余供应
  uint public totalItem;
  // C2C fee 
  uint8 public c2cFee;

  // 新的IDO地址，用户领取状态
  mapping(uint => C2CItem) public c2cItems;
  // 构建函数，需要知道前一个地址，代币地址，受益者地址
  // ido 开始时间、结束时间、可以领取时间、领取结束时间
  constructor(address beneficience_, address nftAddress_, address tokenAddress_) {
  	chairperson = msg.sender;
  	// remainSupply = TOTAL_ETH_SUPPLY;
    c2cEnabled = true;
    c2cFee = 4;
    nftAddress = nftAddress_;
  	nftToken = IERC721(nftAddress);
    tokenAddress = payable(tokenAddress_);
    beneficience = beneficience_;
    token = IERC20(tokenAddress);
  }
  
  function setNFTAddress(address payable nftAddress_) public onlyOwner{
    require(nftAddress_ != address(0));
     nftAddress = nftAddress_;
     nftToken = IERC721(nftAddress);
  }

  // 质押ETH进入到中间地址（合约地址）
  // 本质是通过这个函数发送ETH，然后得到的对应代币的数量，这些记录在链上。
  function depositC2CItem(uint nftId, uint value) public returns (bool){
    uint timestamp = block.timestamp;

    require(c2cEnabled, "C2C system is down.");

    require(value >= MIN_DEPOSITE, "NFT value should big than 0.1ETH");
    // 需要判断当前用户是否具有NFT
    require(nftToken.balanceOf(msg.sender) >0, "Sender has none of this type nft");
    // 需要判断用户是否具有这个NFT
    require(nftToken.ownerOf(nftId) == msg.sender, "Sender is not the owner of this item");

    // 把用户地址的NFT，转移到代理地址（本合约地址）
    nftToken.transferFrom(msg.sender, address(this), nftId);

    // 创建C2C商品记录
    C2CItem memory c2cItem = C2CItem({
      nftId: nftId,
      value: value,
      author: msg.sender,
      timestamp: block.timestamp
    });
    c2cItems[nftId] = c2cItem;
    totalItem = totalItem.add(1);
    // c2cAllItems.push();

    emit C2CDepositItemEvent(msg.sender, nftId, value, timestamp);
    
    return true;
  }

  // 购买IDO
  // 本质是通过这个函数发送ETH，然后得到的对应代币的数量，这些记录在链上。
  function buyC2CItem(uint nftId) payable public returns (bool){
    uint timestamp = block.timestamp;
    // 然后获取这个nft的item
    C2CItem memory c2cItem = c2cItems[nftId];
    require(c2cEnabled, "C2C system is down.");
    require(c2cItem.author != address(0), "This nft is not for sell");
    // 转移过来的币
    uint value = c2cItem.value;
    // 然后判断转进来的钱是否够这个价格，
    require(token.balanceOf(msg.sender) >= c2cItem.value, "The value is insufficeint for this token");

    // 然后把NFT转移到目标用户。
    nftToken.safeTransferFrom(address(this), msg.sender, nftId);
    
    // 然后把用户转进来的代币，转移给卖家用户
    uint fee = value.mul(c2cFee).div(100);
    token.transferFrom(msg.sender, c2cItem.author, value.sub(fee));
    token.transferFrom(msg.sender, beneficience, fee);

    delete c2cItems[nftId];
    totalItem = totalItem.sub(1);
    // 触发购买记录
    emit C2CBuyItemEvent(msg.sender, nftId, value, timestamp);

    return true;

  }

  // 购买IDO
  // 本质是通过这个函数发送ETH，然后得到的对应代币的数量，这些记录在链上。
  function downC2CItem(uint nftId) public returns (bool){
    uint timestamp = block.timestamp;
    // 然后获取这个nft的item
    C2CItem memory c2cItem = c2cItems[nftId];
    // 检测是否存在这个item
    require(c2cItem.author != address(0), "This nft is not for sell");

    // check is author has the permmit.
    require(c2cItem.author == msg.sender, "It's not your item");

    // 然后把NFT返回给原始用户。
    nftToken.safeTransferFrom(address(this), msg.sender, nftId);

    delete c2cItems[nftId];

    // 触发下架记录
    emit C2CDownItemEvent(msg.sender, nftId, timestamp);
    totalItem = totalItem.sub(1);
    // c2cItems.push(C2CItem({
    //   nftId: nftId,
    //   value: value,
    //   status: C2CStatus.C2C_ONLINE,
    //   timestamp: block.timestamp
    // }));
    return true;

  }
  
  function getC2CItem(uint nftId) public view returns(C2CItem memory item){
    return c2cItems[nftId];
  }

  function getTotalItem() public view returns (uint) {
    return totalItem;
  }

  function release() public  onlyOwner {
      payable(chairperson).transfer(address(this).balance);
      token.transfer(chairperson, token.balanceOf(address(this)));
  }

function setC2CFee(uint8 fee) public onlyOwner {
    c2cFee = fee; //div 100
  }

  function setC2CEnable(bool enable) public onlyOwner {
    c2cEnabled = enable;
  }

  function isC2CEnable() public view returns(bool) {
    return c2cEnabled;
  }

}
