module guess_number::main {
    use std::signer;
    use std::vector;
    use endless_std::simple_map::{Self, SimpleMap};
    use endless_framework::event;

    const E_GAME_NOT_FOUND: u64 = 1;
    const E_INVALID_GUESS: u64 = 2;
    const E_GAME_ALREADY_COMPLETED: u64 = 3;

    struct Game has key, store, drop, copy {
        hidden_number: u8,
        player_address: address,
        completed: bool,
    }

    struct GameResultEvent has drop, store {
        winner: address,
        player: address,
        player_guess: u8,
        hidden_number: u8,
    }

    struct GameStore has key {
        games: SimpleMap<u64, Game>,
        next_id: u64,
    }

    #[event]
    struct GameWinner has store, drop {
        winner: address,
        guess: u8,
        hidden_number: u8
    }

    fun init_module(account: &signer) {
        move_to(account, GameStore {
            games: simple_map::create(),
            next_id: 1,
        });
    }

    public entry fun start_game(player: &signer, random_number: u64) acquires GameStore {
        let player_addr = signer::address_of(player);
        let store = borrow_global_mut<GameStore>(@guess_number);

        let game_id = store.next_id;
        let hidden_number = generate_random_number(random_number, game_id) % 100 + 1;

        simple_map::add(&mut store.games, game_id, Game {
            hidden_number,
            player_address: player_addr,
            completed: false,
        });

        store.next_id = game_id + 1;
    }

    #[view]
    public fun get_game_by_id(game_id: u64): Game acquires GameStore {
        let store = borrow_global<GameStore>(@guess_number);
        let game = simple_map::borrow(&store.games, &game_id);
        if (!game.completed) {
            Game {
                hidden_number: 0,
                player_address: game.player_address,
                completed: game.completed
            }
        } else {
            *game
        }
    }

    #[view]
    public fun get_active_game_ids(): vector<u64> acquires GameStore {
        let store = borrow_global_mut<GameStore>(@guess_number);
        let keys = simple_map::keys(&store.games);

        let result = vector::empty<u64>();

        let len = vector::length(&keys);
        let i = 0;

        while (i < len) {
            let key = *vector::borrow(&keys, i);
            let game = simple_map::borrow(&store.games, &key);
            if (!game.completed) {
                vector::push_back(&mut result, key);
            };

            i = i + 1;
        };

        result
    }

    public entry fun submit_guess(player: &signer, game_id: u64, guess: u8) acquires GameStore {
        let player_addr = signer::address_of(player);
        let store = borrow_global_mut<GameStore>(@guess_number);

        assert!(guess >= 1 && guess <= 100, E_INVALID_GUESS);
        assert!(simple_map::contains_key(&store.games, &game_id), E_GAME_NOT_FOUND);

        let game = simple_map::borrow_mut(&mut store.games, &game_id);

        assert!(game.player_address == player_addr, E_GAME_NOT_FOUND);
        assert!(!game.completed, E_GAME_ALREADY_COMPLETED);

        game.completed = true;

        let winner_address = @guess_number;

        if ((guess - game.hidden_number) < 10) {
            winner_address = player_addr;
        };

        event::emit(
            GameWinner {
                winner: winner_address,
                guess,
                hidden_number: game.hidden_number
            }
        );

        // simple_map::remove(&mut store.games, &game_id);
    }

    fun generate_random_number(random_number: u64, game_id: u64): u8 {
        let seed = ((random_number % 256) as u8);
        let modifier = ((game_id % 100) as u8);
        let timestamp = ((game_id + random_number) as u8);
        (seed ^ modifier ^ timestamp) % 100 + 1
    }
}