// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {StdCheats} from "forge-std/StdCheats.sol";
import {Test, console} from "forge-std/Test.sol";
import {VotingSystem, VotingSystemEvents as events} from "../src/VotingSystem.sol";
import {DeployVotingSystem} from "../script/DeployVotingSystem.s.sol";

contract VotingSystemTest is StdCheats, Test {
    DeployVotingSystem deployer;
    VotingSystem votingSystem;
    address owner;
    address user1;
    address user2;
    address user3;
    address[] users;

    function setUp() external {
        deployer = new DeployVotingSystem();
        votingSystem = deployer.run();
        owner = votingSystem.i_owner();
        user1 = vm.addr(1);
        user2 = vm.addr(2);
        user3 = vm.addr(3);
        users = new address[](10);
        for (uint8 i = 0; i < users.length; i++) {
            users[i] = vm.addr(i + 4);
        }
    }

    function testOwner() external {
        assertEq(owner, msg.sender);
    }

    function testRegisterVoter() external {
        vm.startPrank(user1);
        votingSystem.registerToVote();
        vm.stopPrank();
        (bool isRegistered, bool hasVoted, uint256 id) = votingSystem.getVoter(
            user1
        );
        assert(isRegistered);
        assert(!hasVoted);
        assertEq(id, 0);
    }

    function testRegisterEmitsEvent() external {
        vm.startPrank(user1);
        vm.expectEmit(true, false, false, true);
        emit events.VoterRegistered(user1);
        votingSystem.registerToVote();
        vm.stopPrank();
    }

    function testRevertsRegisterWhenAlreadyRegistered() external {
        vm.startPrank(user1);
        votingSystem.registerToVote();
        vm.expectRevert(
            VotingSystem.VotingSystem__VoterAlreadyRegistered.selector
        );
        votingSystem.registerToVote();
        vm.stopPrank();
    }

    function testAddCandidate() external {
        vm.startPrank(owner);
        votingSystem.addCandidate("candidate1");
        vm.stopPrank();
        (string memory name, uint256 voteCount) = votingSystem.getCandidate(0);
        assertEq(name, "candidate1");
        assertEq(voteCount, 0);
    }

    function testAddCandidateEmit() external {
        vm.startPrank(owner);
        vm.expectEmit(true, false, false, true);
        emit events.CandidateAdded(votingSystem.s_id(), "candidate1");
        votingSystem.addCandidate("candidate1");
        vm.stopPrank();
    }

    function testAddCandidateRevertsOnlyOwner() external {
        vm.startPrank(user1);
        vm.expectRevert(VotingSystem.VotingSystem__OnlyOwner.selector);
        votingSystem.addCandidate("candidate1");
        vm.stopPrank();
    }

    function testCastVote() external {
        vm.startPrank(owner);
        votingSystem.addCandidate("candidate1");
        votingSystem.addCandidate("candidate2");
        vm.stopPrank();

        vm.startPrank(user1);

        // expect revert if non registered user tries to vote
        vm.expectRevert(VotingSystem.VotingSystem__VoterNotRegistered.selector);
        votingSystem.castVote(1);

        votingSystem.registerToVote();
        votingSystem.castVote(0);
        vm.stopPrank();

        (, bool hasVoted, uint256 id) = votingSystem.getVoter(user1);
        (, uint256 count) = votingSystem.getCandidate(0);
        assert(hasVoted);
        assertEq(id, 0);
        assertEq(count, 1);
    }

    function testCastVoteEmitEvent() external {
        vm.startPrank(owner);
        votingSystem.addCandidate("candidate1");
        votingSystem.addCandidate("candidate2");
        vm.stopPrank();

        vm.startPrank(user1);
        votingSystem.registerToVote();
        vm.expectEmit(true, false, false, true);
        emit events.VoteCast(user1, 0);
        votingSystem.castVote(0);
        vm.stopPrank();
    }

    function testCastVoteRevertIfVoterNotRegistered() external {
        vm.startPrank(owner);
        votingSystem.addCandidate("candidate1");
        votingSystem.addCandidate("candidate2");
        vm.stopPrank();

        vm.startPrank(user1);
        vm.expectRevert(VotingSystem.VotingSystem__VoterNotRegistered.selector);
        votingSystem.castVote(1);
        vm.stopPrank();
    }

    function testCaseVoteRevertIfWrongCandidateId() external {
        vm.startPrank(owner);
        votingSystem.addCandidate("candidate1");
        votingSystem.addCandidate("candidate2");
        vm.stopPrank();

        vm.startPrank(user1);
        votingSystem.registerToVote();
        uint256 length = votingSystem.getCandidatesCount();
        vm.expectRevert(VotingSystem.VotingSystem__InvalidCandidateId.selector);
        votingSystem.castVote(length + 1);
        vm.stopPrank();
    }

    function addVotes() internal {
        vm.startPrank(owner);
        votingSystem.addCandidate("candidate1");
        votingSystem.addCandidate("candidate2");
        votingSystem.addCandidate("candidate3");
        vm.stopPrank();

        for (uint8 i = 0; i < 6; i++) {
            vm.startPrank(users[i]);
            votingSystem.registerToVote();
            votingSystem.castVote(0);
            vm.stopPrank();
        }

        for (uint8 i = 6; i < users.length; i++) {
            vm.startPrank(users[i]);
            votingSystem.registerToVote();
            votingSystem.castVote(1);
            vm.stopPrank();
        }
    }

    function testResults() external {
        addVotes();
        (string[] memory names, uint256[] memory votes) = votingSystem
            .getResults();
        assertEq(votingSystem.getCandidatesCount(), 3);
        assertEq(votes[0], 6);
        assertEq(votes[1], 4);
        assertEq(votes[2], 0);
        for (uint8 i = 0; i < names.length; i++) {
            console.log(names[i], votes[i]);
        }
    }

    function testWinner() external {
        addVotes();
        uint256 winnerId = votingSystem.getWinner();
        (string memory winnerName, uint256 voteCount) = votingSystem
            .getCandidate(winnerId);
        assertEq(winnerId, 0);
        assertEq(winnerName, "candidate1");
        assertEq(voteCount, 6);
    }
}
