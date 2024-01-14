## Decentralized Voting System
This smart contract represents a decentralized voting system written using solidity and test with the *Foundry Framework*.
The contract supports following features:
- Users can register to vote.
- The owner of the contract can add candidate(s).
- Only registered voters can cast their vote for a specific candidate.
- A voter can only vote once.
- The voting process is completely transparent and any user can view the voting results.

### About the Contract
There are 2 main components of this contract: Voters and Candidates. Only the owner can add new candidates, but any user who wishes to be a voter and do so by calling the registerToVote function. The flow is pretty simple - users register to vote, owner adds candidates, voters cast their vote, the results can be publically seen using the getResults function. Though this contract doesn't implment the time thingy as this was not needed as per the guidlines for the assignment. <br> <br>
Also, a key thing to note in the contract structure here is we use mapping Data structure for voters while an array for candidates, and this is by choice. Why?<br> As for voters we need efficiency, because in a voting system we often will have to check whether a partiulcar address has already voted, as we maintain a boolean to check this and a user can only vote once. So mappings provide O(1) lookup (if we had used arrays, the time complexity would have been O(n), as there is no predefined sequence of voters), hence, we use those for voters. <br>
For the Candidates though, first thing is we have a limited number of candidates only. Next thing is when showing the results to public or finding the winner, we actually need to sequentially visit every candidate and get their vote count. Arrays in solidity are the go to choice for this kind of lookup.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/DeployVotingSystem.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
## Documentation

https://book.getfoundry.sh/
