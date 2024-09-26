use starknet::ContractAddress;

#[starknet::interface]
trait IProgressTracker<TContractState> {
    fn set_username(ref self: TContractState, user: ContractAddress, new_username: ByteArray);
    fn set_github(ref self: TContractState, user: ContractAddress, github_username: ByteArray, sign: ByteArray);
    fn set_Xname(ref self: TContractState, user: ContractAddress, x_username: ByteArray, sign: ByteArray);
    fn get_github(self: @TContractState, user: ContractAddress) -> ByteArray;
    fn get_Xname(self: @TContractState, user: ContractAddress) -> ByteArray;
    fn get_contract_owner(self: @TContractState) -> ContractAddress;
}

#[starknet::contract]
mod ProgressTracker {
    use starknet::ContractAddress;
    use starknet::get_caller_address;


    #[storage]
    struct Storage {
        owner: ContractAddress,
        username: ByteArray, // Consider removing if username_dict serves the same purpose
        username_dict: starknet::storage::Map<ContractAddress, ByteArray>, // Username mapping for each user
        user_address: ContractAddress, // Corrected field name
        github_username: starknet::storage::Map<ContractAddress, ByteArray>,
        github_sign: starknet::storage::Map<ContractAddress, ByteArray>,
        x_username: starknet::storage::Map<ContractAddress, ByteArray>,
        x_username_sign: starknet::storage::Map<ContractAddress, ByteArray>,
    }


    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: ContractAddress) {
        self.owner.write(initial_owner);
    }

    #[abi(embed_v0)]
    impl ProgressTrackerImpl of super::IProgressTracker<ContractState> {
        fn set_username(
            ref self: ContractState, user: ContractAddress, new_username: ByteArray
        ) {
            self.username_dict.write(user, new_username);
            // Consider removing if username is not needed separately
            // self.username.write(new_username);
        }

        fn set_github(ref self: ContractState, user: ContractAddress, github_username: ByteArray, sign: ByteArray) {
            self.github_username.write(user, github_username);
            self.github_sign.write(user, sign);
        }

        fn set_Xname(ref self: ContractState, user: ContractAddress, x_username: ByteArray, sign: ByteArray) {
            self.x_username.write(user, x_username);
            self.x_username_sign.write(user, sign);
        }

        fn get_github(self: @ContractState, user: ContractAddress) -> ByteArray {
            self.github_username.read(user)
        }

        fn get_Xname(self: @ContractState, user: ContractAddress) -> ByteArray {
            self.x_username.read(user)
        }

        fn get_contract_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
    }
}