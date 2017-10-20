pragma solidity ^0.4.4;

contract Splitter {
    enum AccountStatus {Unregistered, Registered}

    // Admin Address
    address admin = 0xAc8a7A8a6BCD4be3012D174b3803E943C582e526;

    // Member addresses
    address[] members;
    mapping (address => uint) public position;
    mapping (address => AccountStatus) public status;

    // Number of people paid in last deposit
    uint public paid;

    // The size of the share from the last deposit
    uint public share;

    // Modifier to require user to be admin
    modifier sudo() {
        require(msg.sender == admin);
        _;
    }

    // Get the number of members in the contract
    function getMembers() public view returns (uint num) {
        return members.length;
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

    // Payout function
    function payout(uint value) private {
        share = value / members.length;
        require(share > 0);
        paid = 0;
        for (uint i = 0; i < members.length; i++) {
            members[i].transfer(share);
            paid += 1;
        }
    }

    // Split the incoming money to all members
    function deposit() public payable {
        payout(msg.value);
    }

    // Fallback function to make sure blind deposits are impossible
    function () public payable {
        revert();
    }
}
