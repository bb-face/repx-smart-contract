#[starknet::contract]
mod RepXContract {
    use starknet::get_caller_address; 
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        owner: ContractAddress,
        maintainers: starknet::storage::Map::<ContractAddress, bool>,
        admins: starknet::storage::Map::<ContractAddress, bool>,
        users: starknet::storage::Map::<ContractAddress, User>,
    }

    #[derive(Drop, Serde, starknet::Store)]
    struct User {
        username: ByteArray,
        github_username: ByteArray,
        x_username: ByteArray,
        quiz_marks: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        MaintainerAdded: MaintainerAdded,
        AdminAdded: AdminAdded,
        UserAdded: UserAdded,
        UserUpdated: UserUpdated,
        UserRemoved: UserRemoved,
    }

    #[derive(Drop, starknet::Event)]
    struct MaintainerAdded {
        #[key]
        maintainer: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct AdminAdded {
        #[key]
        admin: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct UserAdded {
        #[key]
        user: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct UserUpdated {
        #[key]
        user: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct UserRemoved {
        #[key]
        user: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: ContractAddress) {
        self.owner.write(initial_owner);
    }

    #[external(v0)]
    fn add_maintainer(ref self: ContractState, new_maintainer: ContractAddress) {
        self.maintainers.write(new_maintainer, true);
        self.emit(Event::MaintainerAdded(MaintainerAdded { maintainer: new_maintainer }));
    }

    #[external(v0)]
    fn add_admin(ref self: ContractState, new_admin: ContractAddress) {
        self.admins.write(new_admin, true);
        self.emit(Event::AdminAdded(AdminAdded { admin: new_admin }));
    }

    #[external(v0)]
    fn add_user(
        ref self: ContractState,
        wallet_address: ContractAddress,
        username: ByteArray,
        github_username: ByteArray,
        x_username: ByteArray
    ) {
        let new_user = User { username, github_username, x_username, quiz_marks: 0 };
        self.users.write(wallet_address, new_user );
        self.emit(Event::UserAdded(UserAdded { user: wallet_address }));
    }

    #[external(v0)]
    fn store_data(
        ref self: ContractState,
        wallet_address: ContractAddress,
        username: ByteArray,
        github_username: ByteArray,
        x_username: ByteArray,
        quiz_marks: u256
    ) {
        let mut user = self.users.read(wallet_address);
        
        if username != user.username {
            user.username = username;
        }
        if github_username != user.github_username {
            user.github_username = github_username;
        }
        if x_username != user.x_username {
            user.x_username = x_username;
        }
        if quiz_marks != user.quiz_marks {
            user.quiz_marks = quiz_marks;
        }

        self.users.write(wallet_address, user);
        self.emit(Event::UserUpdated(UserUpdated { user: wallet_address }));
    }

    #[external(v0)]
    fn search_data(self: @ContractState, wallet_address: ContractAddress) -> User {
        self.users.read(wallet_address)
    }

    #[external(v0)]
    fn edit_user(
        ref self: ContractState,
        wallet_address: ContractAddress,
        username: ByteArray,
        github_username: ByteArray,
        x_username: ByteArray
    ) {
        let mut user = self.users.read(wallet_address);
        assert(user.username != " ", 'User does not exist');
        user.username = username;
        user.github_username = github_username;
        user.x_username = x_username;
        self.users.write(wallet_address, user);
        self.emit(Event::UserUpdated(UserUpdated { user: wallet_address }));
    }

    #[external(v0)]
    fn remove_user(ref self: ContractState, wallet_address: ContractAddress) {
        let user = self.users.read(wallet_address);
        assert(user.username != " ", 'User does not exist');
        self.users.write(wallet_address, User { username: " ", github_username: " ", x_username: " ", quiz_marks: 0 });
        self.emit(Event::UserRemoved(UserRemoved { user: wallet_address }));
    }
}