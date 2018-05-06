pragma solidity ^0.4.18;

contract Warrantoken {
  struct Item {
    uint identifier;
    address owner;
    address creator;
    bool activated;
    bytes32 password;
  }

  mapping(uint => Item) public items;

  event WarrantyTransferred(uint indexed indentifier, address indexed owner);
  event WarrantyCreated(uint indexed indentifier, address indexed owner);

  address admin;

  /*
  function Warrantoken
      Sets global admin so that we can pay transaction fees, and users can still be direct owners of items. 
  */

  function Warrantoken() public {
    admin = msg.sender;
  }

  /*
  function Warrantoken

    do not store warranty info in the blockchain.
    store all info off chain.

  */

  function createWarranty(bytes32 password, uint myIdentifier) public{
    require(items[myIdentifier].identifier == 0 && password.length >10);
    items[myIdentifier] = Item({
      identifier: myIdentifier,
      owner: msg.sender,
      creator: msg.sender,
      password: password,
      activated: false
    });
    //WarrantyCreated(myIdentifier, msg.sender, msg.sender, regTime, myItemName, myItemDescription, myItemCategory, myItemLocation, myItemWarrantyDescription, myItemThumbnailURL);
    WarrantyCreated(myIdentifier, msg.sender);
  }

  /*
  function constant getWarranty
    return warranty item
    
  */

  function getWarranty(uint warrantyIdentifier) public constant returns (uint identifier, address owner, address creator, bytes32 password, bool activated) {
    identifier= items[warrantyIdentifier].identifier;
    owner= items[warrantyIdentifier].owner;
    creator= items[warrantyIdentifier].creator;
    password= items[warrantyIdentifier].password;
    activated = items[warrantyIdentifier].activated;
  }

  /* 
  modifier onlyOwner 
    Either the owner, or the admin account (which is our account that will cover transaction fees for average users) can initiate the transfer. 
  */

  modifier onlyOwner(uint warrantyIdentifier, address newOwner) {
    require((items[warrantyIdentifier].owner == msg.sender && msg.sender != newOwner) || (msg.sender == admin));
    _;
  }

  /* 
  public function transferWarranty
      Authentication required to transfer warranty. 
      Warranty identifier must be original. 
      Upon successful transfer, updates ownerSecretHash with new hashed password.
      We call this from our API on the back end server to preserve anonymity and cover gas costs. 
  */

  function transferWarranty(uint warrantyIdentifier, address newOwner) public onlyOwner(warrantyIdentifier, newOwner) {
    items[warrantyIdentifier].owner = newOwner;
    WarrantyTransferred(warrantyIdentifier, newOwner);
  }


  /* 
  modifier onlyOriginalOwner 
    First scan. use secret password contained in QR code to unlock the warranty without current owner initiating transfer.
  */

  modifier onlyOriginalOwner(uint warrantyIdentifier, string password) {
    require(items[warrantyIdentifier].activated == false && items[warrantyIdentifier].password == keccak256(password));
    _;
  }

  /* 
  public function registerWarranty
      register with password from QR code. No difference except authentication type.
  */
  function registerWarranty(uint warrantyIdentifier, string password, address newOwner) public onlyOriginalOwner(warrantyIdentifier, password) {
    items[warrantyIdentifier].owner = newOwner;
    items[warrantyIdentifier].password = bytes32(0);
    items[warrantyIdentifier].activated = true;
    WarrantyTransferred(warrantyIdentifier, newOwner);
  }
}

/*
0x9a7464d1ec3ba4f478c660936447993f11d6ca67

web3.personal.unlockAccount(web3.eth.accounts[0], 'password', 1500000)

web3.eth.defaultAccount=web3.eth.accounts[0]
var c = web3.eth.contract([{"constant":false,"inputs":[{"name":"warrantyIdentifier","type":"uint"},{"name":"newOwner","type":"address"}],"name":"transferWarranty","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint"}],"name":"items","outputs":[{"name":"identifier","type":"uint"},{"name":"owner","type":"address"},{"name":"creator","type":"address"},{"name":"itemRegistered","type":"uint"},{"name":"itemName","type":"string"},{"name":"itemDescription","type":"string"},{"name":"itemWarranty","type":"string"},{"name":"itemThumbnailURL","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[{"name":"myItemName","type":"string"},{"name":"myItemDescription","type":"string"},{"name":"myItemWarranty","type":"string"},{"name":"myItemThumbnailURL","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"indentifier","type":"uint"},{"indexed":true,"name":"owner","type":"address"}],"name":"WarrantyTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"indentifier","type":"uint"},{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"itemName","type":"string"}],"name":"WarrantyCreated","type":"event"}])


var c = web3.eth.contract([{"constant": false,"inputs": [{"name": "warrantyIdentifier","type": "uint"},{"name": "newOwner","type": "address"}],"name": "transferWarranty","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "myItemName","type": "string"},{"name": "myItemDescription","type": "string"},{"name": "myItemWarranty","type": "string"},{"name": "myItemThumbnailURL","type": "string"}],"name": "createWarranty","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [{"name": "","type": "uint"}],"name": "items","outputs": [{"name": "identifier","type": "uint"},{"name": "owner","type": "address"},{"name": "creator","type": "address"},{"name": "itemRegistered","type": "uint"},{"name": "itemName","type": "string"},{"name": "itemDescription","type": "string"},{"name": "itemWarranty","type": "string"},{"name": "itemThumbnailURL","type": "string"}],"payable": false,"stateMutability": "view","type": "function"},{"anonymous": false,"inputs": [{"indexed": true,"name": "indentifier","type": "uint"},{"indexed": true,"name": "owner","type": "address"}],"name": "WarrantyTransferred","type": "event"},{"anonymous": false,"inputs": [{"indexed": true,"name": "indentifier","type": "uint"},{"indexed": true,"name": "owner","type": "address"},{"indexed": true,"name": "itemName","type": "string"}],"name": "WarrantyCreated","type": "event"}]);

var d = c.at(0x9a7464d1ec3ba4f478c660936447993f11d6ca67)

web3.personal.unlockAccount('0x39d752db6193c5c7Ec0dA08116c6be63D6C6c465', "password", 1500000, function(e,c){})





d.transferWarranty.call(1, '0x39d752db6193c5c7Ec0dA08116c6be63D6C6c465').set({from: '0x39d752db6193c5c7Ec0dA08116c6be63D6C6c465'});   , {from:web3.eth.accounts[0]})
//not working. 
d.transferWarranty.call(100000000000, 0x39d752db6193c5c7Ec0dA08116c6be63D6C6c465, {from:0x39d752db6193c5c7Ec0dA08116c6be63D6C6c465})
d.transferWarranty(100000000000, 0x39d752db6193c5c7Ec0dA08116c6be63D6C6c465, {from:0x39d752db6193c5c7Ec0dA08116c6be63D6C6c465})
d.transferWarranty.sendTransaction({from:web3.eth.accounts[0], data:'0x90581cdb000000000000000000000000000000000000000000000000000000000000000100000000000000000000000039d752db6193c6321f47ed55ca77d5ed00000000'})

eth.sendTransaction({from:web3.eth.accounts[0], data:'0x90581cdb000000000000000000000000000000000000000000000000000000000000000100000000000000000000000039d752db6193c6321f47ed55ca77d5ed00000000', to:'0x55f83524b525945ed24a3cee5c0edf75dcb5f0b1'})
d.transferWarranty.sendTransaction({from:web3.eth.accounts[0], data:'0x90581cdb000000000000000000000000000000000000000000000000000000000000000100000000000000000000000039d752db6193c6321f47ed55ca77d5ed00000000', to:'0x55f83524b525945ed24a3cee5c0edf75dcb5f0b1'}, function(err,c){ console.log(err,c); })

web3.personal.unlockAccount(web3.eth.defaultAccount, "password", 150000000, function(err, result) {console.log(result) });
0xb94105B676e256639560369566f4C670e0546F000

acc = '0x39d752db6193c5c7Ec0dA08116c6be63D6C6c465';




Warrantoken.deployed().then(inst => { w = inst });
var p = web3.sha3("password");
w.createWarranty(p)
w.getWarranty(0)

w.registerWarranty(0, "password", '0x39d752db6193c5c7Ec0dA08116c6be63D6C6c465')

w.transferWarranty(0, 0x9eab32c718b3291d0351792a6af96bff7ae46297)


w.transferWarranty(0, '0x9eab32c718b3291d0351792a6af96bff7ae46297').then(function(res){ console.log("AAA", res.logs[0].args); });

TMR: Listen for events and get the response after transaction with ID. vendor can check ID and user can save. 
w.allEvents(function(event) {  console.log(event); });
ev = w.WarrantyTransferred({warrantyIdentifier:0})
ev.watch(function(error, result){ console.log("aAAA", result); });
ev.get(function(error, logs){ console.log(logs); });
w.allEvents([])

deployed on rinkeby: 0xa66e42068c375d0b82197e630d68b9d9d2d31b79
*/











