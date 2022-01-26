const BookBlockchain = artifacts.require("BookBlockchain");

var accounts;
var owner;

contract('BookBlockchain', (accs) => {
    accounts = accs;
    owner = accounts[0];
});