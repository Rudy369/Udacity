import Web3 from "web3";
import starNotaryArtifact from "../../build/contracts/StarNotary.json";

const App = {
  web3: null,
  account: null,
  meta: null,
  account2: null,

  start: async function() {
    const { web3 } = this;

    try {
      // get contract instance
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = starNotaryArtifact.networks[networkId];
      this.meta = new web3.eth.Contract(
        starNotaryArtifact.abi,
        deployedNetwork.address,
      );

      // get accounts
      const accounts = await web3.eth.getAccounts();
      this.account = accounts[0];
      this.account2 = accounts[1];
    } catch (error) {
      console.error("Could not connect to contract or chain.");
    }
  },

  setStatus: function(message) {
    const status = document.getElementById("status");
    status.innerHTML = message;
  },

  createStar: async function() {
    const { createStar } = this.meta.methods;
    const name = document.getElementById("starName").value;
    const id = document.getElementById("starId").value;
    await createStar(name, id).send({from: this.account});
    App.setStatus("New Star Owner is " + this.account + ".");
  },

  // Implement Task 4 Modify the front end of the DAPP
  lookUp: async function (){
    // TIL need to get method from meta methods to call
    const { lookUptokenIdToStarInfo } = this.meta.methods;
    const tokenId = document.getElementById("lookid").value;
    const starName = await lookUptokenIdToStarInfo(tokenId).call();//.send({ from: this.account });
    App.setStatus("Star Name Is " + starName + ".");
  },

  getDevInfo: async function() {
    const { getName, getSymbol } = this.meta.methods;
    const tokenName = await getName().call();
    const tokenSymbol = await getSymbol().call();
    
    document.getElementById("contractTokenName").value = tokenName;
    document.getElementById("contractTokenSymbol").value = tokenSymbol;
    document.getElementById("defaultAccount").value = this.account;
  },

  putStarForSale: async function() {
    const { putStarUpForSale } = this.meta.methods;
    const starId = document.getElementById("startIdForSale").value;
    const starPrice = document.getElementById("starPrice").value;
    await putStarUpForSale(starId, starPrice).send({ from: this.account });
    App.setStatus("Star was put up for sale.");
  },

  buyStar: async function() {
    const { buyStar } = this.meta.methods;
    const starId = document.getElementById("buyStarId").value;
    console.log(starId);
    console.log(this.account2);
    let buyerBalance = await App.web3.eth.getBalance(this.account2);
    console.log("Buyer Balance: " + buyerBalance);
    await approveBuyer(this.account2, starId).send({ from: this.account });
    await buyStar(starId).send({ from: this.account2, value: buyerBalance });
    App.setStatus("Star Was Bought.");
  },

  lookupStarPrice: async function() {
    const { lookUpStarPrice } = this.meta.methods;
    const starId = document.getElementById("priceStarId").value;
    const price = await lookUpStarPrice(starId).call();
    App.setStatus("Star " + starId + " , Price " + price);
  }
};

window.App = App;

window.addEventListener("load", async function() {
  if (window.ethereum) {
    // use MetaMask's provider
    App.web3 = new Web3(window.ethereum);
    await window.ethereum.enable(); // get permission to access accounts
  } else {
    console.warn("No web3 detected. Falling back to http://127.0.0.1:9545. You should remove this fallback when you deploy live",);
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:9545"),);
  }

  App.start();
});