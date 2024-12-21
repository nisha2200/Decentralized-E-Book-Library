// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedEBookLibrary {
    struct EBook {
        uint256 id;
        string title;
        string author;
        string ipfsHash; // Link to the eBook stored on IPFS
        address owner;
        bool exists;
    }

    mapping(uint256 => EBook) public ebooks;
    mapping(address => uint256[]) public userEBooks;
    uint256 public nextEBookId;

    event EBookAdded(uint256 id, string title, string author, string ipfsHash, address owner);
    event EBookTransferred(uint256 id, address from, address to);

    function addEBook(string memory title, string memory author, string memory ipfsHash) public {
        require(bytes(title).length > 0, "Title is required");
        require(bytes(author).length > 0, "Author is required");
        require(bytes(ipfsHash).length > 0, "IPFS hash is required");

        ebooks[nextEBookId] = EBook(nextEBookId, title, author, ipfsHash, msg.sender, true);
        userEBooks[msg.sender].push(nextEBookId);

        emit EBookAdded(nextEBookId, title, author, ipfsHash, msg.sender);
        nextEBookId++;
    }

    function transferEBook(uint256 ebookId, address to) public {
        require(ebooks[ebookId].exists, "EBook does not exist");
        require(ebooks[ebookId].owner == msg.sender, "You are not the owner");
        require(to != address(0), "Invalid address");

        // Update ownership
        ebooks[ebookId].owner = to;
        
        // Remove from current owner
        removeEBookFromUser(msg.sender, ebookId);
        userEBooks[to].push(ebookId);

        emit EBookTransferred(ebookId, msg.sender, to);
    }

    function removeEBookFromUser(address user, uint256 ebookId) internal {
        uint256[] storage userEBookList = userEBooks[user];
        for (uint256 i = 0; i < userEBookList.length; i++) {
            if (userEBookList[i] == ebookId) {
                userEBookList[i] = userEBookList[userEBookList.length - 1];
                userEBookList.pop();
                break;
            }
        }
    }

    function getEBook(uint256 ebookId) public view returns (EBook memory) {
        require(ebooks[ebookId].exists, "EBook does not exist");
        return ebooks[ebookId];
    }

    function getUserEBooks(address user) public view returns (uint256[] memory) {
        return userEBooks[user];
    }
}
