module Insurancefordefi::Insurance {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct to represent the insurance pool.
    struct InsurancePool has key {
        total_funds: u64,  // Total funds in the pool
    }

    /// Initialize the insurance pool.
    public fun initialize_pool(owner: &signer) {
        let pool = InsurancePool { total_funds: 0 };
        move_to(owner, pool);
    }

    /// Stake funds to the insurance pool.
    public fun stake_funds(staker: &signer, pool_owner: address, amount: u64) acquires InsurancePool {
        let pool = borrow_global_mut<InsurancePool>(pool_owner);

        // Transfer funds from staker to the pool owner
        let stake_amount = coin::withdraw<AptosCoin>(staker, amount);
        coin::deposit<AptosCoin>(pool_owner, stake_amount);

        // Update the total funds in the pool
        pool.total_funds = pool.total_funds + amount;
    }

    /// Claim insurance from the pool.
    public fun claim_insurance(claimer: &signer, pool_owner: address, claim_amount: u64) acquires InsurancePool {
        let pool = borrow_global_mut<InsurancePool>(pool_owner);

        // Ensure the pool has enough funds to cover the claim
        assert!(pool.total_funds >= claim_amount, 0x01); // Insufficient funds in pool

        // Transfer claim amount to the claimer
        let payout = coin::withdraw<AptosCoin>(pool_owner, claim_amount);
        coin::deposit<AptosCoin>(signer::address_of(claimer), payout);

        // Update the pool's total funds
        pool.total_funds = pool.total_funds - claim_amount;
    }
}
