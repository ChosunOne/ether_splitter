pragma solidity ^0.4.4;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Splitter.sol";

contract TestSplitter {
    Splitter splitter = Splitter(DeployedAddresses.Splitter());
    uint public initialBalance = 1 ether;

    // Test the addAddress Function
    function testAddAddress() public {
        address testAddr = 0x4991f18d4298859bea3ab8c40a5e30dbd939a442;
        address testAddr2 = 0x92da6543808f6c6766821ba5a8b9ca9090bbf835;

        splitter.addAddress(testAddr);
        splitter.addAddress(testAddr2);
        
        assert(splitter.getStatus(testAddr) == Splitter.AccountStatus.Registered);
        assert(splitter.getPosition(testAddr) == 0);
        assert(splitter.getStatus(testAddr2) == Splitter.AccountStatus.Registered);
        assert(splitter.getPosition(testAddr2) == 1);
    }

    // Test the removeAddress Function
    function testRemoveAddress() public {
        address testAddr = 0x959caec604a8e7d430694ce1ca161f52a0a93cb7;
        address testAddr2 = 0xbd535e8476301709f0ed0ec8f813219e8f707de8;

        splitter.addAddress(testAddr);
        splitter.addAddress(testAddr2);
        splitter.removeAddress(testAddr);

        assert(splitter.getStatus(testAddr) == Splitter.AccountStatus.Unregistered);
        assert(splitter.getPosition(testAddr) == 0);
        assert(splitter.getPosition(testAddr2) == 2);
    }

    // Test the deposit function
    function testDeposit() public {
        splitter.resetNonce();
        uint nonce = splitter.getNonce();

        assert(nonce == 0);
        
        uint members = splitter.getMembers();
        assert(members == 3);

        splitter.deposit.value(1 ether)();
        nonce = splitter.getNonce();

        assert(nonce == 1);

        uint paid = splitter.getPaid();
        uint share = splitter.getShare();
        uint expectedPaid = 3;
        uint expectedShare = uint(1 ether) / expectedPaid;

        assert(paid == expectedPaid);
        assert(share == expectedShare);
    }
}