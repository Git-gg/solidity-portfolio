// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

// Simple learning exercise: a basic on-chain voting contract.
// Anyone can vote once for one of the preloaded proposals.
contract Voting {

    // Tracks whether an address has already voted
    mapping(address => bool) public hasVoted;

    // A single proposal: its description and vote count
    struct Proposal {
        string description;
        uint256 votes;
    }

    // List of all proposals
    Proposal[] public proposals;

    // Preload 3 proposals when the contract is deployed
    constructor() {
        proposals.push(Proposal("Option A", 0));
        proposals.push(Proposal("Option B", 0));
        proposals.push(Proposal("Option C", 0));
    }

    // Cast a vote for the proposal at the given index (0, 1 or 2)
    function vote(uint256 proposalIndex) public {
        require(hasVoted[msg.sender] == false, "You already voted");
        proposals[proposalIndex].votes = proposals[proposalIndex].votes + 1;
        hasVoted[msg.sender] = true;
    }

    // Returns the description of the proposal with the most votes
    function winner() public view returns (string memory) {
        // Start by assuming the first proposal is the winner
        Proposal memory currentWinner = proposals[0];

        // Compare it against the rest, keeping the one with more votes
        for (uint256 i = 1; i < proposals.length; i++) {
            if (proposals[i].votes > currentWinner.votes) {
                currentWinner = proposals[i];
            }
        }

        return currentWinner.description;
    }
}
