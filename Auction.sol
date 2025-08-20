//SPDX-License-Identifier:MIT
pragma solidity ^0.4.17;

contract Auction {

    // Data
    // Structure to hold details of the item
    struct Item {
        uint itemId; // id of the item
        uint[] itemTokens;  // tokens bid in favor of the item
    }

    // Structure to hold the details of a person
    struct Person {
        uint remainingTokens; // tokens remaining with bidder
        uint personId; // it serves as tokenId as well
        address addr; // address of the bidder
    }

    mapping(address => Person) tokenDetails; // address to person
    Person [4] bidders; // Array containing 4 person objects

    Item [3] public items; // Array containing 3 item objects
    address[3] public winners; // Array for address of winners
    address public beneficiary; // owner of the smart contract

    uint bidderCount = 0; // counter

    // Modifier for Version 2 (onlyOwner)
    modifier onlyOwner() {
        require(msg.sender == beneficiary);
        _;
    }

    // Constructor
    function Auction() public payable {
        // Task 1: Initialize beneficiary with msg.sender
        beneficiary = msg.sender;

        uint[] memory emptyArray;

        // Task 2: Initialize 3 items
        items[0] = Item({itemId: 0, itemTokens: emptyArray});
        items[1] = Item({itemId: 1, itemTokens: emptyArray});
        items[2] = Item({itemId: 2, itemTokens: emptyArray});
    }

    function register() public payable {
        // Assign personId to the bidder
        bidders[bidderCount].personId = bidderCount;

        // Task 3: Store bidder's address
        bidders[bidderCount].addr = msg.sender;

        // Assign 5 tokens
        bidders[bidderCount].remainingTokens = 5;

        // Update mapping
        tokenDetails[msg.sender] = bidders[bidderCount];

        // Increment bidder count
        bidderCount++;
    }

    function bid(uint _itemId, uint _count) public payable {
        // Task 4: Check conditions
        require(tokenDetails[msg.sender].remainingTokens >= _count);
        require(tokenDetails[msg.sender].remainingTokens > 0);
        require(_itemId <= 2); // only 3 items: 0, 1, 2

        // Task 5: Decrement token count
        tokenDetails[msg.sender].remainingTokens -= _count;

        // Sync updated token count in array
        bidders[tokenDetails[msg.sender].personId].remainingTokens = tokenDetails[msg.sender].remainingTokens;

        // Add bid to item's token list
        Item storage bidItem = items[_itemId];
        for (uint i = 0; i < _count; i++) {
            bidItem.itemTokens.push(tokenDetails[msg.sender].personId);
        }
    }

    // Version 2 change: Add `onlyOwner` modifier here
    function revealWinners() public onlyOwner {
        for (uint id = 0; id < 3; id++) {
            Item storage currentItem = items[id];

            if (currentItem.itemTokens.length != 0) {
                // Random index
                uint randomIndex = (block.number / currentItem.itemTokens.length) % currentItem.itemTokens.length;
                uint winnerId = currentItem.itemTokens[randomIndex];

                // Task 6: Assign winner address
                winners[id] = bidders[winnerId].addr;
            }
        }
    }

    // DO NOT MODIFY
    function getPersonDetails(uint id) public view  returns (uint, uint, address) {
        return (
            bidders[id].remainingTokens,
            bidders[id].personId,
            bidders[id].addr
        );
    }
}
