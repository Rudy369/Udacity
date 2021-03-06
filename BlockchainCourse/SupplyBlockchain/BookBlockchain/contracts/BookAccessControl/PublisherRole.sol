// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the library 'Roles'
import "./Roles.sol";

contract PublisherRole {
    using Roles for Roles.Role;

    // Define 2 events, one for Adding, and other for Removing
    event PublisherAdded(address indexed account);
    event PublisherRemoved(address indexed account);

    // Define a struct 'Publishers' by inheriting from 'Roles' library, struct Role
    Roles.Role private publishers;

    // In the constructor make the address that deploys this contract the 1st Publisher
    constructor() public {
        _addPublisher(msg.sender);
    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyPublisher() {
        require(isPublisher(msg.sender));
        _;
    }

    // Define a function 'isPublisher' to check this role
    function isPublisher(address account) public view returns (bool) {
        return publishers.has(account);
    }

    // Define a function 'addPublisher' that adds this role
    function addPublisher(address account) public onlyPublisher {
        _addPublisher(account);
    }

    // Define a function 'renouncePublisher' to renounce this role
    function renouncePublisher() public {
        _removePublisher(msg.sender);
    }

    // Define an internal function '_addPublisher' to add this role, called by 'addPublisher'
    function _addPublisher(address account) internal {
        publishers.add(account);
        emit PublisherAdded(account);
    }

    // Define an internal function '_removePublisher' to remove this role, called by 'removePublisher'
    function _removePublisher(address account) internal {
        publishers.remove(account);
        emit PublisherRemoved(account);
    }
}