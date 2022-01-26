const BookBlockchain = artifacts.require("BookBlockchain");

module.exports = function(deployer) {
  deployer.deploy(BookBlockchain);
};
