// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract BookSupplyChain is ERC721 {
    constructor() ERC721("", "") { }

    // TODO: NEED TO WORK IN ADDRESSES PROBABLY FOR CONSUMER AND BOOK STORE TO KEEP IT SIMPLE
    // WILL NEED TO REGISTER THE BOOKSTORE OWNER TO SELL 
    // I MAY HAVE TO GO ALLW THE WAY BACK TO THE AUTHOR 
    // NEED STRUCTS FOR AUTHOR, PUBLISHER, BOOKSTORE, BOOK, CONSUMER, STOCK
    struct Author {
        uint256 AuthorId;
        string FirstName;
        string LastName;
    }

    struct Publisher {
        uint256 PublisherId;
        string Name;
    }

    struct Book {
        uint256 BookId;
        uint256 AuthorId;
        uint256 PublisherId;
        string ISBN;
        string Name;
        string Genre;
        string Format;
        uint256 Price;
        string State; // MAY NOT NEED THIS 
    }

    struct Bookstore {
        uint256 BookstoreId;
        string Name;
    }

    struct Consumer {
        uint256 ConsumerId;
        string FirstName;
        string LastName;
    }

    struct Stock {
        uint256 BookId;
        string Format;
        uint256 Quantity;
    }

    // Formats: Physical_New, Digital, Physical_Used
    uint256 _authorCount = 0;
    uint256 _publisherCount = 0;
    uint256 _bookstoreCount = 0;
    uint256 _consumerCount = 0;
    uint256 _bookCount = 0;

    // I THINK I NEED SOME MAPPINGS
    mapping(uint256 => Author) public _authors;
    mapping(uint256 => Publisher) public _publishers;
    mapping(uint256 => Bookstore) public _bookstores;
    mapping(uint256 => Consumer) public _consumers;
    mapping(uint256 => Book) public _publishedBooks; // I WILL HAVE A NEW FIELD 
    // TODO: PRINTED BOOKS 
    mapping(uint256 => Stock) public _publisherStock;
    mapping(uint256 => Stock) public _bookstoreStock;

    // CREATE AUTHOR
    function createAuthor(string memory firstName, string memory lastName) public returns (uint256) {
        uint256 authorId = _authorCount + 1;
        Author memory author = Author(authorId, firstName, lastName);
        _authors[authorId] = author;
        _authorCount += 1;
        return authorId;
    }

    // CREATE PUBLISHER
    function createPublisher(string memory name) public returns (uint256) {
        uint256 publisherId = _publisherCount + 1;
        Publisher memory publisher = Publisher(publisherId, name);
        _publishers[publisherId] = publisher;
        _publisherCount += 1;
        return publisherId;
    }

    // CREATE BOOKSTORE
    function createBookstore(string memory name) public returns (uint256) {
        uint256 bookstoreId = _bookstoreCount + 1;
        Bookstore memory bookstore = Bookstore(bookstoreId, name);
        _bookstores[bookstoreId] = bookstore;
        _bookstoreCount += 1;
        return bookstoreId;
    }

    // CREATE CONSUMER 
    function createConsumer(string memory firstName, string memory lastName) public returns (uint256) {
        uint256 consumerId = _consumerCount + 1;
        Consumer memory consumer = Consumer(consumerId, firstName, lastName);
        _consumers[consumerId] = consumer;
        _consumerCount += 1;
        return consumerId;
    }

    // NEED TO ESTABLIS CONTRACT BETWEEN AUTHOR AND PUBLUISHER TO GENERATE NEW BOOK
    function publishBook(uint256 authorId, uint256 publisherId, 
        string memory isbn, string memory name, string memory genre,
        string memory format, uint256 price, string memory state
    ) public returns (uint256) {
        uint256 bookId = _bookCount + 1;
        Book memory book = Book(bookId, authorId, publisherId,
            isbn, name, genre, format, price, state
        );
        _publishedBooks[bookId] = book;
        _bookCount += 1;
        return bookId;
    }

    function printBook(uint256 bookId, string memory format, uint256 quantity) public {
        // TODO:
        Stock memory stock = Stock(bookId, format, quantity);
        _publisherStock[bookId] = stock;
    }

    function distributeBook(uint256 bookId, uint256 bookstoreId, uint256 copies) public {

    }
    // NEED TO CREATE PROCESS THAT DISTRUBTES BOOK
    // NEED TO CREATE PROCESS THAT BOOKSTORE SELLS BOOK
    // NEED TO CREATE PROCESS THAT BOOKSTORE REBUYS USED BOOK


}