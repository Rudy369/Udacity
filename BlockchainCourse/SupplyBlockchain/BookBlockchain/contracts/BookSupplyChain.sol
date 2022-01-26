// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract BookSupplyChain is ERC721 {
    constructor() ERC721("", "") { }

    // TODO: NEED TO WORK IN ADDRESSES PROBABLY FOR CONSUMER AND BOOK STORE TO KEEP IT SIMPLE
    // WILL NEED TO REGISTER THE BOOKSTORE OWNER TO SELL 
    // I MAY HAVE TO GO ALLW THE WAY BACK TO THE AUTHOR 
    // NEED STRUCTS FOR AUTHOR, PUBLISHER, BOOKSTORE, BOOK, CONSUMER, STOCK
    // REALLY PUBLISHER SHOULD PURCHASE RIGHTS THEN PRINT AND CREATE DIGITAL
    // Formats: Physical_New, Digital, Physical_Used
    enum BookFormat{ Physical_New, Physical_Used, Digital }

    struct Author {
        address Address;
        uint256 AuthorId;
        string FirstName;
        string LastName;
    }

    uint256 _authorCount = 0;
    // KEY = AuthorId
    mapping(uint256 => Author) _authors;

    struct Publisher {
        address Address;
        uint256 PublisherId;
        string Name;
    }

    uint256 _publisherCount = 0;
    // KEY = PublisherId
    mapping(uint256 => Publisher) _publishers;

    struct Bookstore {
        address Address;
        uint256 BookstoreId;
        string Name;
    }

    uint256 _bookstoreCount = 0;
    // KEY = BookstoreId
    mapping(uint256 => Bookstore) _bookstores;

    // TODO: CREATE DIGITAL STORE
    struct DigitalStore {
        address Address;
        uint256 BookstoreId;
        string Name;
    }

    uint256 _digitalStoreCount = 0;
    // KEY = DigitalStoreId
    mapping(uint256 => DigitalStore) _digitalStores;

    struct Consumer {
        address Address;
        uint256 ConsumerId;
        string FirstName;
        string LastName;
    }

    uint256 _consumerCount = 0;
    // KEY = ConsumerId
    mapping(uint256 => Consumer) _consumers;

    // OR CAN HAVE BOOK AND PUBLISHING RIGHTS SEPERATE - YEAH THAT WILL BE BETTER 
    struct Book {
        address AuthorAddress;
        uint256 BookId;
        uint256 AuthorId;
        string ISBN;
        string Name;
        string Genre;
    }

    uint256 _bookCount = 0;
    // KEY = BookId
    mapping(uint256 => Book) _publishedBooks;

    struct PublishingRights {
        uint256 BookId;
        address RightsHolder;
        uint256 RightsPrice;
        bool ForSale;
    }

    // KEY = BookId
    mapping(uint256 => PublishingRights) _rightsForSale;

    struct BookInstance {
        uint256 BookInstanceId;
        uint256 BookId;
        address Owner;
        BookFormat Format;
        uint256 Price;
    }

    // KEY = BookInstanceId
    mapping(uint256 => BookInstance) _bookInstances;

    struct Stock {
        uint256 OwnerId;
        uint256 BookId;
        uint256 Quantity;
        uint256 Price;
    }

    // I NEED A WAY TO STORE THE INSTANCES OF A BOOK 

    // MAY HAVE TO THINK A BIT DIFFERENCE 
    // MAY NOT WORK THE WAY IM THINKING 
    // I MAY NEED A INDEX LOOK UP
    // PROBABLY NEED IT TO WORK DIFFERENTLY
    // KEY = PublisherId
    mapping(uint256 => Stock) public _publisherStock;
    // KEY = BookstoreId
    mapping(uint256 => Stock) public _bookstoreStock;
    // KEY DigitalStoreId
    mapping(uint256 => Stock) public _digitalStoreStock;
    uint256 LastMintedId = 0;

    function createAuthor(string memory firstName, string memory lastName) public returns (uint256) {
        uint256 authorId = _authorCount + 1;
        Author memory author = Author(msg.sender, authorId, firstName, lastName);
        _authors[authorId] = author;
        _authorCount += 1;
        return authorId;
    }

    function createPublisher(string memory name) public returns (uint256) {
        uint256 publisherId = _publisherCount + 1;
        Publisher memory publisher = Publisher(msg.sender, publisherId, name);
        _publishers[publisherId] = publisher;
        _publisherCount += 1;
        return publisherId;
    }

    function createBookstore(string memory name) public returns (uint256) {
        uint256 bookstoreId = _bookstoreCount + 1;
        Bookstore memory bookstore = Bookstore(msg.sender, bookstoreId, name);
        _bookstores[bookstoreId] = bookstore;
        _bookstoreCount += 1;
        return bookstoreId;
    }

    function createDigitalStore(string memory name) public returns(uint256) {
        uint256 digitalStoreId = _digitalStoreCount + 1;
        DigitalStore memory digitalStore = DigitalStore(msg.sender, digitalStoreId, name);
        _digitalStores[digitalStoreId] = digitalStore;
        _digitalStoreCount += 1;
        return digitalStoreId;
    }

    function createConsumer(string memory firstName, string memory lastName) public returns (uint256) {
        uint256 consumerId = _consumerCount + 1;
        Consumer memory consumer = Consumer(msg.sender, consumerId, firstName, lastName);
        _consumers[consumerId] = consumer;
        _consumerCount += 1;
        return consumerId;
    }

    function createBook(uint256 authorId,
        string memory isbn, string memory name, string memory genre,
        uint256 rightsPrice) public returns (uint256) {
        uint256 bookId = LastMintedId + 1;
        Book memory book = Book(msg.sender, bookId, authorId, isbn, name, genre);
        _mint(msg.sender, bookId);
        PublishingRights memory rights = PublishingRights(bookId, msg.sender, rightsPrice, true);
        _publishedBooks[bookId] = book;
        _rightsForSale[bookId] = rights;
        _bookCount += 1;
        LastMintedId += 1;
        return bookId;
    }
 
    function publisherPurchase(uint256 bookId) public payable {
        require(_rightsForSale[bookId].BookId > 0, "Book should have its rights for sale.");
        Book memory book = _publishedBooks[bookId];
        PublishingRights memory rights = _rightsForSale[bookId];
        require(msg.value > rights.RightsPrice, "Must have more eth than rights price.");
        address ownerAddress = ownerOf(bookId);
        transferFrom(ownerAddress, msg.sender, bookId);
        payable(ownerAddress).transfer(rights.RightsPrice);
        payable(msg.sender).transfer(msg.value - rights.RightsPrice);
        rights.RightsHolder = msg.sender;
        rights.ForSale = false;
        _publishedBooks[bookId] = book;
        _rightsForSale[bookId] = rights;
    }

    // NEED TO 
    function printBook(uint256 bookId, uint256 publisherId, BookFormat format, uint256 price) public {
        address bookOwnerAddress = ownerOf((bookId));
        require(msg.sender == bookOwnerAddress, "Must be owner of book.");
        
        // MINT 
        // NEED TO CREATE NEW INSTANCE OF A BOOK 


        if (_publisherStock[publisherId].BookId == 0) {
            // CREATE NEW
            Stock memory stock = Stock(publisherId, bookId, 1, price);
        }
        else {
            // GET EXISTING AND UPDATE 
        }

        // I WILL NEED TO GET STOCK COUNT 
        // STOCK CANT WORK THIS WAY
        //Stock memory stock = Stock(publisherId, bookId, format, quantity, price);
    }


    // TODO: CHANGE THIS TOA LOOP ON THE EXTERNAL APP THAT CALLS IN TO MINT A SINGLE BOOK
    // function printBooks(uint256 bookId, uint256 publisherId, BookFormat format, 
    //     uint256 quantity, uint256 price) public {
    //     address bookOwnerAddress = ownerOf((bookId));
    //     require(msg.sender == bookOwnerAddress, "Must be owner of book.");
    //     Stock memory stock = Stock(publisherId, bookId, format, quantity, price);
    //     //Stock memory stock = Stock();

    //     // GOING TO CREATE STOCK FOR THE PUBLISHER 
    //      for (uint i = 0; i < quantity; i++)
    //      {
    //          uint256 instanceId = LastMintedId + 1;
    //          BookInstance memory instance = BookInstance(instanceId, bookId, bookOwnerAddress);
    //          _mint(bookOwnerAddress, instanceId);
    //          _bookInstances[instanceId] = instance;

    //          // SINCE THE BOOK HAS BEEN MINTED DO I NEED TO MINT THE INSTANCE OF THE BOOK 
    //          // THEY WILL GET MINTED 
    //                  // I THINK I WILL HAVE TO MINT COPIES OF EACH OF THE DIGITAL
    //     //uint i = 0;
    //         LastMintedId += 1;
    //      }

    //      // SET PUBLISHER STOCK
    //     // _publisherStock[publisherId] = 
    //     // I NEED A KEY PAIR OR SOMETHING 
    // }

        //     uint256 OwnderId;
        // uint256 BookId;
        // BookFormat Format;
        // uint256 Quantity;
        // uint256 Price;
        // mapping(uint256 => BookInstance) BookInstances;

    // PUBLIHSER THEN NEEDS TO MAKE PRINT COPIES AND DIGITAL COPIES \

        //     uint256 BookId;
        // string Format;
        // uint256 Quantity;
        // uint256 Price;

    // I WILL PROBABLY SKIP RESELL LOGIC TO KEEP THIS SIMPLE
    // BUT THEY MAY BE IMPORTANT IN THE GRAND SCHEM OF THINGS 

    // NEED TO ESTABLIS CONTRACT BETWEEN AUTHOR AND PUBLUISHER TO GENERATE NEW BOOK
        // address RightsHolder;
        // uint256 BookId;
        // uint256 AuthorId;
        // string ISBN;
        // string Name;
        // string Genre;
        // string Format;
        // uint256 RightsPrice;

    // NO SHOULD MINT BOOK FIRST AS IT IS WRITTEN 



    // function publishBook(uint256 authorId, uint256 publisherId, 
    //     string memory isbn, string memory name, string memory genre,
    //     string memory format, uint256 price, string memory state
    // ) public returns (uint256) {
    //     // NEED TO UPDATE TO PAY AUTHOR 


    //     uint256 bookId = _bookCount + 1;
    //     Book memory book = Book(bookId, authorId, publisherId,
    //         isbn, name, genre, format, price, state
    //     );
    //     _publishedBooks[bookId] = book;
    //     _bookCount += 1;
    //     return bookId;
    // }

    // function printBook(uint256 bookId, string memory format, uint256 quantity) public {
    //     // TODO:
    //     Stock memory stock = Stock(bookId, format, quantity);
    //     _publisherStock[bookId] = stock;
    // }

    // function distributeBook(uint256 bookId, uint256 bookstoreId, uint256 copies) public {

    // }
    // NEED TO CREATE PROCESS THAT DISTRUBTES BOOK
    // NEED TO CREATE PROCESS THAT BOOKSTORE SELLS BOOK
    // NEED TO CREATE PROCESS THAT BOOKSTORE REBUYS USED BOOK


}