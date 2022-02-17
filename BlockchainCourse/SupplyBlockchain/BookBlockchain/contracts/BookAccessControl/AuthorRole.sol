// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the library 'Roles'
import "./Roles.sol";

contract AuthorRole {
    using Roles for Roles.Role;

    // Define 2 events, one for Adding, and other for Removing
    event AuthorAdded(address indexed account);
    event AuthorRemoved(address indexed account);

    // Define a struct 'Authors' by inheriting from 'Roles' library, struct Role
    Roles.Role private authors;

    // In the constructor make the address that deploys this contract the 1st Author
    constructor() public {
        _addAuthor(msg.sender);
    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyAuthor() {
        require(isAuthor(msg.sender));
        _;
    }

    // Define a function 'isAuthor' to check this role
    function isAuthor(address account) public view returns (bool) {
        return authors.has(account);
    }

    // Define a function 'addAuthor' that adds this role
    function addAuthor(address account) public onlyAuthor {
        _addAuthor(account);
    }

    // Define a function 'renounceAuthor' to renounce this role
    function renounceAuthor() public {
        _removeAuthor(msg.sender);
    }

    // Define an internal function '_addAuthor' to add this role, called by 'addAuthor'
    function _addAuthor(address account) internal {
        authors.add(account);
        emit AuthorAdded(account);
    }

    // Define an internal function '_removeAuthor' to remove this role, called by 'removeAuthor'
    function _removeAuthor(address account) internal {
        authors.remove(account);
        emit AuthorRemoved(account);
    }
}