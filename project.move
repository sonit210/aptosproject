module MyModule::DAO {

    use aptos_framework::coin;
    use aptos_framework::signer;
    use aptos_framework::aptos_coin::{AptosCoin};

    struct Vote has store, key {
        proposal_id: u64,
        yes_votes: u64,
        no_votes: u64,
    }

    struct Treasury has store, key {
        dao_address: address,
        balance: u64,
    }

    // Function to cast a vote on a proposal
    public fun cast_vote(voter: &signer, proposal_id: u64, vote_for: bool) acquires Vote {
        let vote = borrow_global_mut<Vote>(signer::address_of(voter));
        assert!(vote.proposal_id == proposal_id, 1);

        if (vote_for) {
            vote.yes_votes = vote.yes_votes + 1;
        } else {
            vote.no_votes = vote.no_votes + 1;
        }
    }

    // Function to release treasury funds based on the vote outcome
    public fun release_funds(dao: &signer, amount: u64) acquires Vote, Treasury {
        let treasury = borrow_global_mut<Treasury>(signer::address_of(dao));
        
        // Ensure funds are only released if yes_votes are greater than no_votes
        let vote = borrow_global<Vote>(signer::address_of(dao));
        assert!(vote.yes_votes > vote.no_votes, 2);

        // Transfer funds from the treasury to the DAO's address
        coin::transfer<AptosCoin>(dao, treasury.dao_address, amount);
    }
}
