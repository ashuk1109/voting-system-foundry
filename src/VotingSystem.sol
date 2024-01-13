// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface VotingSystemEvents {
    /** Events */
    event VoterRegistered(address indexed voterAddress);
    event CandidateAdded(uint256 indexed id, string name);
    event VoteCast(address indexed voterAddress, uint256 candidateId);
}

/**
 * @title VotingSystem
 * @author ashuk1109
 *
 * Decentralized Voting System for complete transparency
 */
contract VotingSystem is VotingSystemEvents {
    /** Errors */
    error VotingSystem__OnlyOwner();
    error VotingSystem__VoterNotRegistered();
    error VotingSystem__VoterAlreadyRegistered();
    error VotingSystem__VoteAlreadyCasted();
    error VotingSystem__InvalidCandidateId();

    /** Type Declarations */
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }

    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    /** Variables */
    uint256 public s_id = 0;
    address public immutable i_owner;
    mapping(address => Voter) public s_voters;
    Candidate[] public s_candidates;

    /** Modifiers */
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert VotingSystem__OnlyOwner();
        }
        _;
    }

    modifier onlyRegisteredVoter() {
        if (!s_voters[msg.sender].isRegistered) {
            revert VotingSystem__VoterNotRegistered();
        }
        _;
    }

    modifier hasNotVoted() {
        if (s_voters[msg.sender].hasVoted) {
            revert VotingSystem__VoteAlreadyCasted();
        }
        _;
    }

    /** Functions */
    constructor() {
        i_owner = msg.sender;
    }

    function registerToVote() public {
        if (s_voters[msg.sender].isRegistered) {
            revert VotingSystem__VoterAlreadyRegistered();
        }

        s_voters[msg.sender].isRegistered = true;
        emit VoterRegistered(msg.sender);
    }

    function addCandidate(string memory _name) public onlyOwner {
        s_candidates.push(Candidate(s_id, _name, 0));
        emit CandidateAdded(s_id, _name);
        s_id++;
    }

    /**
     * @dev Voter can cast vote only if :
     * 1. Voter is registered.
     * 2. Voter hasn't already voted.
     * 3. Voter provides a valid candidate id for voting.
     */
    function castVote(
        uint256 candidateId
    ) public onlyRegisteredVoter hasNotVoted {
        if (candidateId >= s_candidates.length) {
            revert VotingSystem__InvalidCandidateId();
        }

        s_voters[msg.sender].hasVoted = true;
        s_voters[msg.sender].votedCandidateId = candidateId;
        s_candidates[candidateId].voteCount++;

        emit VoteCast(msg.sender, candidateId);
    }

    /**
     * @dev Get complete results of voting for each and every candidate publicly
     */
    function getResults()
        public
        view
        returns (string[] memory, uint256[] memory)
    {
        uint256 candidateCount = s_candidates.length;
        string[] memory candidateNames = new string[](candidateCount);
        uint256[] memory voteCounts = new uint256[](candidateCount);

        for (uint256 i = 0; i < candidateCount; i++) {
            candidateNames[i] = s_candidates[i].name;
            voteCounts[i] = s_candidates[i].voteCount;
        }

        return (candidateNames, voteCounts);
    }

    /**
     * @dev Get the winner of the voting, internally calls the getResults function
     */
    function getWinner() public view returns (uint256) {
        (, uint256[] memory votes) = getResults();
        uint256 winnerId = 0;
        for (uint256 i = 1; i < votes.length; i++) {
            if (votes[i] > votes[winnerId]) {
                winnerId = i;
            }
        }
        return winnerId;
    }

    /** Getter functions */
    function getVoter(
        address _voterAddress
    )
        public
        view
        returns (bool isRegistered, bool hasVoted, uint256 votedCandidateId)
    {
        Voter memory voter = s_voters[_voterAddress];
        return (voter.isRegistered, voter.hasVoted, voter.votedCandidateId);
    }

    function getCandidatesCount() public view returns (uint256) {
        return s_candidates.length;
    }

    function getCandidate(
        uint256 _candidateId
    ) public view returns (string memory name, uint256 voteCount) {
        require(_candidateId < s_candidates.length, "Invalid candidate ID");

        Candidate memory candidate = s_candidates[_candidateId];
        return (candidate.name, candidate.voteCount);
    }
}
