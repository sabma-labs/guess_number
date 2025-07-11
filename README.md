# 🎮 Endless Smart Contract Demo – Guess the Number

This code is a demo of an **Endless smart contract** written in Move, implementing a simple **Guess the Number** game.

---

## 🧩 Overview

The contract allows a player to:

- Start a game
- Submit a guess for a randomly generated number between 1 and 100

It demonstrates usage of:

- `SimpleMap` from `endless_std`
- Event emission via `endless_framework`

---

## ⚙️ Key Features

- `start_game`: Starts a new game with a random hidden number tied to the player’s address.
- `submit_guess`: The player submits a guess. If it's within 10 of the hidden number, the player wins.
- `GameWinner` event: Emitted when someone wins.
- `get_game_by_id`: Returns game details (masks hidden number as `0` if the game isn't finished).
- `get_active_game_ids`: Lists all ongoing (unfinished) games.
- `generate_random_number`: Generates a deterministic pseudo-random number using a `random_number` and `game_id`.

---

## 🧪 Purpose

This contract serves as a demo for building **interactive**, **stateful**, **event-driven dApps** on the Endless platform using smart contract primitives like:

- `SimpleMap` for key-value storage
- `event::emit` for logging results
- `#[view]` functions for off-chain queries

---

It’s ideal for learning how to build dApps on the Endless chain using Move smart contracts.