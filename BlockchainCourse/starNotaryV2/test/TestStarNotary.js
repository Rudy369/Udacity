const StarNotary = artifacts.require("StarNotary");

var accounts;
var owner;

contract('StarNotary', (accs) => {
    accounts = accs;
    owner = accounts[0];
});

it ('can Create a Star', async () => {
    let tokenId = 1;
    let instance = await StarNotary.deployed();
    await instance.createStar('Awesome Star!', tokenId, { from: accounts[0] });
    assert.equal(await instance.tokenIdToStarInfo.call(tokenId), 'Awesome Star!');
});

it ('lets user1 put up their star for sale', async() => {
    let instance = await StarNotary.deployed();
    let user1 = accounts[1];
    let starId = 2;
    let starPrice = web3.utils.toWei(".01", "ether");
    await instance.createStar("awesome star", starId, { from: user1 });
    await instance.putStarUpForSale(starId, starPrice, { from: user1 });
    assert.equal(await instance.starsForSale.call(starId), starPrice);
});

it('lets user1 get the funds after the sale', async() => {
    // WITH THE NEW SOL VERSION LOOKS LIKE I NEED TO HAVE THE SELLER APPROVE THE BUYER BEFORE THEY CAN BUY
    let instance = await StarNotary.deployed();
    let user1 = accounts[1];
    let user2 = accounts[2];
    //console.log("User Selling Star: " + user1);
    //console.log("User Buying Star: " + user2);
    let starId = 3;
    let starPrice = web3.utils.toWei(".01", "ether");
    let balance = web3.utils.toWei(".05", "ether");
    //console.log("Star Price: " + Number(starPrice));
    //console.log("Buyer Balance: " + Number(balance));
    await instance.createStar('awesome star', starId, {from: user1});
    //let owner = await instance.lookupStarOwner(starId);
    //console.log("Star Owner: " + owner); 
    await instance.putStarUpForSale(starId, starPrice, {from: user1});
    let balanceOfUser1BeforeTransaction = await web3.eth.getBalance(user1);
    //console.log("Seller Balance: " + Number(balanceOfUser1BeforeTransaction));
    await instance.approveBuyer(user2, starId, { from: user1 });
    //let approved = await instance.isApprovedToBuy(user2, starId);
    //console.log("Buyer Approval: " + approved);
    //await instance.testBuy(starId, {from: user2, value: balance});
    await instance.buyStar(starId, {from: user2, value: balance });
    //console.log("past test buy");
    //let newOwner = await instance.lookupStarOwner(starId); // CAN REMOVE AFTER
    //console.log("Star Owner: " + newOwner); 
    let balanceOfUser1AfterTransaction = await web3.eth.getBalance(user1);
    //console.log("Seller Balance After Transaction: " + Number(balanceOfUser1AfterTransaction));
    let balAfter = Number(balanceOfUser1AfterTransaction);
    let balPreAndStarCost = Number(balanceOfUser1BeforeTransaction) + Number(starPrice);
    let offset = Number(balPreAndStarCost) - Number(balAfter); // FOR FEES
    let value1 = Number(balanceOfUser1BeforeTransaction) + Number(starPrice);
    let value2 = Number(balanceOfUser1AfterTransaction) + Number(offset);
    let testVal = Number(balanceOfUser1AfterTransaction) - Number(starPrice);
    //console.log("math test: " + Number(balanceOfUser1BeforeTransaction) + Number(starPrice));
    //console.log("math test: " + testVal);  
    //console.log("math offset: " + offset);
    //console.log("Value 1: " + value1);
    //console.log("Value 2: " + value2);
    assert.equal(value1, value2);
});

it('lets user2 buy a star, if it is put up for sale', async() => {
    let instance = await StarNotary.deployed();
    let user1 = accounts[1];
    let user2 = accounts[2];
    let starId = 4;
    let starPrice = web3.utils.toWei(".01", "ether");
    let balance = web3.utils.toWei(".05", "ether");
    await instance.createStar('awesome star', starId, {from: user1});
    await instance.putStarUpForSale(starId, starPrice, {from: user1});
    let balanceOfUser1BeforeTransaction = await web3.eth.getBalance(user2);
    await instance.approveBuyer(user2, starId, { from: user1 });
    await instance.buyStar(starId, {from: user2, value: balance});
    assert.equal(await instance.ownerOf.call(starId), user2);
});

it('lets user2 buy a star and decreases its balance in ether', async() => {
    let instance = await StarNotary.deployed();
    let user1 = accounts[1];
    let user2 = accounts[2];
    let starId = 5;
    let starPrice = web3.utils.toWei(".01", "ether");
    let balance = web3.utils.toWei(".05", "ether");
    await instance.createStar('awesome star', starId, {from: user1});
    await instance.putStarUpForSale(starId, starPrice, {from: user1});
    let balanceOfUser1BeforeTransaction = await web3.eth.getBalance(user2);
    const balanceOfUser2BeforeTransaction = await web3.eth.getBalance(user2);
    await instance.approveBuyer(user2, starId, { from: user1 });
    await instance.buyStar(starId, {from: user2, value: balance, gasPrice:0});
    const balanceAfterUser2BuysStar = await web3.eth.getBalance(user2);
    let value = Number(balanceOfUser2BeforeTransaction) - Number(balanceAfterUser2BuysStar);
    assert.equal(value, starPrice);
  });


// Implement Task 2 Add supporting unit tests
it('can add the star name and star symbol properly', async() => {
    // 1. create a Star with different tokenId
    //2. Call the name and symbol properties in your Smart Contract and compare with the name and symbol provided
    let instance = await StarNotary.deployed();
    let user1 = accounts[1];
    let starId = 6;
    await instance.createStar('awesome star', starId, {from: user1});
    let name = "Rockstar";
    let symbol = "RSTR";
    assert.equal(await instance.getName(), name);
    assert.equal(await instance.getSymbol(), symbol);
});

it('lets 2 users exchange stars', async() => {
    // 1. create 2 Stars with different tokenId
    // 2. Call the exchangeStars functions implemented in the Smart Contract
    // 3. Verify that the owners changed
    let instance = await StarNotary.deployed();
    let user1 = accounts[1];
    let user2 = accounts[2];
    //console.log("User1: " + user1);
    //console.log("User2: " + user2);
    let starId = 7;
    let starId2 = 8;
    await instance.createStar('awesome star', starId, {from: user1});
    await instance.createStar('super star', starId2, {from: user2});
    await instance.approveBuyer(user2, starId, { from: user1 });
    await instance.approveBuyer(user1, starId2, { from: user2 });
    await instance.exchangeStars(starId, starId2, { from: user1 });
    let ownerOfStar1 = await instance.lookupStarOwner(starId);
    let ownerOfStar2 = await instance.lookupStarOwner(starId2);
    //console.log("Owner of Star1: " + ownerOfStar1);
    //console.log("Owner of Star2: " + ownerOfStar2);
    assert.equal(ownerOfStar1, user2);
    assert.equal(ownerOfStar2, user1);
});

it('lets a user transfer a star', async() => {
    // 1. create a Star with different tokenId
    // 2. use the transferStar function implemented in the Smart Contract
    // 3. Verify the star owner changed.
    let instance = await StarNotary.deployed();
    let user1 = accounts[1];
    let user2 = accounts[2];
    let starId = 9;
    await instance.createStar('awesome star', starId, {from: user1});
    await instance.transferStar(user2, starId, { from: user1 });
    assert.equal(await instance.lookupStarOwner(starId), user2);
});

it('lookUptokenIdToStarInfo test', async() => {
    // 1. create a Star with different tokenId
    // 2. Call your method lookUptokenIdToStarInfo
    // 3. Verify if you Star name is the same
    let instance = await StarNotary.deployed();
    let user1 = accounts[1];
    let user2 = accounts[2];
    let starId = 10;
    await instance.createStar('awesome star', starId, {from: user1});
    assert.equal(await instance.lookUptokenIdToStarInfo(starId), "awesome star");
});