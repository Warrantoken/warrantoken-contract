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







