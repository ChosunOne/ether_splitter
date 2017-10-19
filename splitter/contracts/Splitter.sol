pragma solidity ^0.4.4;

contract Splitter {
    enum AccountStatus {Unregistered, Registered}

    // Admin Address
    address admin = 0x4991f18d4298859bea3ab8c40a5e30dbd939a442;

    // Member addresses
    address[] members;
    mapping (address => uint) position;
    mapping (address => AccountStatus) status;

    // Number of people paid in last deposit
    uint paid;

    // The size of the share from the last deposit
    uint share;

    //DEBUG variables
    uint nonce;

    // Modifier to require user to be admin
    modifier sudo() {
        require(tx.origin == admin);
        _;
    }

    // Reset the nonce value
    function resetNonce() public sudo {
        nonce = 0;
    }

    // Get the nonce
    function getNonce() public returns (uint num) {
        return nonce;
    }

    // Get the number of members in the contract
    function getMembers() public returns (uint num) {
        return members.length;
    }

    // Get the number of paid addresses from the last deposit
    function getPaid() public returns (uint num) {
        return paid;
    }

    // Get the share from the last deposit
    function getShare() public returns (uint num) {
        return share;
    }

    // Get address position
    function getPosition(address addr) public returns (uint index) {
        return position[addr];
    }

    // Get address status
    function getStatus(address addr) public returns (AccountStatus state) {
        return status[addr];
    }

    // Function to add address to the members list
    function addAddress(address addr) public sudo {
        require(status[addr] != AccountStatus.Registered);

        position[addr] = members.length;
        members.push(addr);
        status[addr] = AccountStatus.Registered;
    }

    // Function to remove address from the members list
    function removeAddress(address addr) public sudo {
        require(status[addr] == AccountStatus.Registered);

        remove(position[addr]);
        position[addr] = 0;
        status[addr] = AccountStatus.Unregistered;
    }

    // Find and remove element at index in members
    function remove(uint index) private {
        if (index >= members.length) {
            return;
        } 

        for (uint i = index; i<members.length-1; i++) {
            members[i] = members[i+1];
            position[members[i]] -= 1;
        }

        delete members[members.length-1];
        members.length--;
    }

    // Split the incoming money to all members
    function deposit() public payable {
        nonce += 1;
        share = msg.value / members.length;
        paid = 0;
        for (uint i = 0; i < members.length; i++) {
            members[i].transfer(share);
            paid += 1;
        }
    }
}