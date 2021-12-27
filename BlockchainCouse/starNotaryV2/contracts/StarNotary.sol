// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract StarNotary is ERC721 {

    struct Star {
        string name;
    }

    string Name = "Rockstar";
    string Symbol = "RSTR";
    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;

    constructor() ERC721("Rockstar", "RSTR") { }

    function getName() public view returns(string memory) {
        return Name;
    }

    function getSymbol() public view returns(string memory) {
        return Symbol;
    }

    function createStar(string memory _name, uint256 _tokenId) public {
        Star memory newStar = Star(_name);
        tokenIdToStarInfo[_tokenId] = newStar;
        _mint(msg.sender, _tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sell the Star you don't own.");
        starsForSale[_tokenId] = _price;
    }

    function lookUpStarPrice(uint _tokenId) public view returns (uint) {
        uint price = starsForSale[_tokenId];
        return price;
    }

    function lookupStarOwner(uint _tokenId) public view returns (address) {
        return ownerOf(_tokenId);
    }

    function approveBuyer(address _buyer, uint _tokenId) public {
        approve(_buyer, _tokenId);
    }

    function isApprovedToBuy(address _buyer, uint _tokenId) public view returns (bool) {
        return getApproved(_tokenId) == _buyer;
    }

    function buyStar(uint256 _tokenId) public payable {
        // WITH THE NEW SOL VERSION LOOKS LIKE I NEED TO HAVE THE SELLER APPROVE THE BUYER BEFORE THEY CAN BUY
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        transferFrom(ownerAddress, msg.sender, _tokenId);
        //_transfer(ownerAddress, msg.sender, _tokenId);
        //address payable ownerAddressPayable = _make_payable(ownerAddress);
        payable(ownerAddress).transfer(starCost);
        //ownerAddressPayable.transfer(starCost);
        
        if (msg.value > starCost) {
            payable(msg.sender).transfer(msg.value - starCost);
        }
    }

    function testBuy(uint256 _tokenId) public payable {
        require(starsForSale[_tokenId] > 0, "Star is not up for sale.");
        uint256 starCost = starsForSale[_tokenId];
        require(msg.value > starCost, "You need to have enough Ether");
        address ownerAddress = ownerOf(_tokenId);
        address buyer = msg.sender;
        require(_msgSender() == buyer, "Sender and buyer address don't match");
        require(ERC721.ownerOf(_tokenId) == ownerAddress, "Owner address doesnt match");
        require(getApproved(_tokenId) == buyer, "Buyer Is Not Approved"); // THIS IS THE ISSUE
        //require(isApprovedForAll(ownerAddress, buyer), "Neither is approved");
    }

    // Implement Task 1 lookUptokenIdToStarInfo
    function lookUptokenIdToStarInfo (uint _tokenId) public view returns (string memory) {
        //1. You should return the Star saved in tokenIdToStarInfo mapping
        Star memory star = tokenIdToStarInfo[_tokenId];
        return star.name;
        //return tokenIdToStarInfo[_tokenId].name;
    }

        // Implement Task 1 Exchange Stars function
    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        //1. Passing to star tokenId you will need to check if the owner of _tokenId1 or _tokenId2 is the sender
        //2. You don't have to check for the price of the token (star)
        //3. Get the owner of the two tokens (ownerOf(_tokenId1), ownerOf(_tokenId1)
        //4. Use _transferFrom function to exchange the tokens.
        require(ownerOf(_tokenId1) == msg.sender || ownerOf(_tokenId2) == msg.sender, "Sender does not own either Star.");
        address ownerOfStar1 = ownerOf(_tokenId1);
        address ownerOfStar2 = ownerOf(_tokenId2);

        transferFrom(ownerOfStar1, ownerOfStar2, _tokenId1);
        transferFrom(ownerOfStar2, ownerOfStar1, _tokenId2);

        // if (ownerOfStar1 == msg.sender) { 
        //     transferFrom(ownerOfStar1, ownerOfStar2, _tokenId1);
        //     transferFrom(ownerOfStar2, ownerOfStar1, _tokenId2);
        // }
        // else {
        //     transferFrom(ownerOfStar2, ownerOfStar1, _tokenId2);
        //     transferFrom(ownerOfStar1, ownerOfStar2, _tokenId1);
        // }
    }

    // Implement Task 1 Transfer Stars
    function transferStar(address _to1, uint256 _tokenId) public {
        //1. Check if the sender is the ownerOf(_tokenId)
        //2. Use the transferFrom(from, to, tokenId); function to transfer the Star
        require(ownerOf(_tokenId) == msg.sender, "Sender is not the owner of the Star.");
        transferFrom(msg.sender, _to1, _tokenId);
    }
}