pragma solidity ^0.4.18;

import "./Ownable.sol";

contract ChainList is Ownable {
  //custom types
  struct Article {
    uint id;
    address seller;
    address buyer;
    string name;
    string description;
    uint256 price;
  }

  //address owner;
  // state variables
  mapping (uint => Article) public articles;
  uint articleCounter;

  // events
  event LogSellArticle(
    uint indexed _id,
    address indexed _seller,
    string _name,
    uint256 _price
  );

  event LogBuyArticle(
    uint indexed _id,
    address indexed _seller,
    address indexed _buyer,
    string _name,
    uint256 _price
  );

  function kill() public onlyOwner {
  //  require(msg.sender == owner);
    selfdestruct(owner);
  }

  // sell an article
  function sellArticle(string _name, string _description, uint256 _price) public {

    articleCounter++;
    articles[articleCounter] = Article(
      articleCounter,
      msg.sender,
      0x0,
      _name,
      _description,
      _price
    );
    /* seller = msg.sender;
    name = _name;
    description = _description;
    price = _price; */

    emit LogSellArticle(articleCounter, msg.sender, _name, _price);
  }

  // get number of articles
  function getNumberOfArticles() public view returns (uint){
      return articleCounter;
  }

  function getArticlesForSale() public view returns(uint[]){
    uint[] memory articleIds = new uint[](articleCounter);
    uint numberOfArticlesForSale = 0;
    for (uint i = 1; i <= articleCounter; i++){
      if (articles[i].buyer == 0x0){
        articleIds[numberOfArticlesForSale] = articles[i].id;
        numberOfArticlesForSale++;
      }
    }

    //copy into a smaller array
    uint[] memory forSale = new uint[](numberOfArticlesForSale);
    for(uint j = 0; j < numberOfArticlesForSale; j++){
      forSale[j] = articleIds[j];
    }
    return forSale;
  }

  // buy an article
  function buyArticle(uint _id) payable public {
    require(articleCounter > 0);

    require(_id > 0 && _id <= articleCounter);

    Article storage article = articles[_id];
    //check whether there is an article for sale
  //  require(seller != 0x0);
    //check that article has not been sold yet
    require(article.buyer == 0x0);
    //check that seller cannot buy his own article
    require(msg.sender != article.seller);
    //check that value sent corresponds to the price of article
    require(msg.value == article.price);
    //keep buyer's info
    article.buyer = msg.sender;
    //buyer can pay seller
    article.seller.transfer(msg.value);
    //trigger events
    emit LogBuyArticle(_id, article.seller, article.buyer, article.name, article.price);
    }
}
