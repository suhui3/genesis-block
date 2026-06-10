# Genesis Block

An educational idle clicker built with **Godot 4.6** that teaches blockchain concepts through play. Mine transactions, validate blocks, earn gas, pass certification audits, and upgrade your network — all in a cyberpunk-styled mobile-first UI.

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [How to Play](#how-to-play)
- [Game Screens](#game-screens)
- [Core Mechanics](#core-mechanics)
- [Progression Guide](#progression-guide)
- [Academy & Certifications](#academy--certifications)
- [Network Crises](#network-crises)
- [Tutorial](#tutorial)
- [Settings](#settings)
- [Save Data](#save-data)
- [Tips & Strategy](#tips--strategy)
- [Project Structure](#project-structure)
- [For Developers](#for-developers)

---

## Overview

Genesis Block is a single-scene incremental game where you act as both a **miner** and a **validator** on a simplified blockchain:

1. **Write** transactions into the mempool.
2. **Validate** a full block to earn gas and extend the chain.
3. **Study** crypto concepts in the Academy.
4. **Pass audits** to unlock Market upgrades.
5. **Spend gas** on upgrades that increase passive income.
6. **Respond** to network crises that appear as your chain grows.

The game auto-saves progress and is designed for portrait mobile play (720×1280), though it runs on desktop too.

---

## Requirements

| Requirement | Version |
|-------------|---------|
| Godot Engine | **4.6** (GL Compatibility renderer) |
| Platform | Desktop, mobile, or web (export targets depend on your Godot export templates) |

---

## Getting Started

### Run in the editor

1. Install [Godot 4.6](https://godotengine.org/download).
2. Clone or download this repository.
3. Open the project folder in Godot (`project.godot`).
4. Press **F5** (or click **Run Project**).

### Splash screen

| Button | Action |
|--------|--------|
| **Start** | Begins a **new game** (resets progress) and launches the first-minute tutorial. |
| **Continue** | Loads your saved game and resumes where you left off. Only visible if a save exists. |
| **⚙ (top-right)** | Opens **Settings** (volume, tutorial replay, quit, reset). |

---

## How to Play

### The core loop

```
Write transactions → Fill mempool (10 tx) → Validate block → Earn gas → Upgrade network → Repeat
```

**Gas** is the main currency. You earn it by validating blocks and (later) passively every second from Market upgrades.

### Quick start (first 5 minutes)

1. On **Mining**, tap **WRITE CODE BLOCK** until the mempool shows `10 / 10`.
2. Tap **VALIDATE BLOCK** to seal a block and receive your first gas payout.
3. Open **Nodes** to see your block on the chain.
4. Open **Academy → Audits** and pass the **Smart Contract Assessment**.
5. Open **Market** and buy your first **Deploy Smart Contract** upgrade.
6. Let passive gas income accumulate, then validate more blocks to fund bigger upgrades.

---

## Game Screens

Navigation uses four bottom tabs:

| Tab | Purpose |
|-----|---------|
| **Nodes** | View your blockchain — the most recent blocks with index, hash, and previous hash. |
| **Mining** | Fill the mempool and validate blocks to earn gas. |
| **Market** | Purchase network upgrades (locked until you pass the matching audit). |
| **Academy** | **Audits** — certification quizzes; **Glossary** — crypto term definitions. |

The header shows the current tab name. Tap **⚙** in the top-right to open Settings.

---

## Core Mechanics

### Mining

| Action | Effect |
|--------|--------|
| **Write Code Block** | Adds `1` transaction to the mempool per tap (up to **10** total). |
| **Validate Block** | Requires a **full mempool** (`10 / 10`). Clears the pool, appends a block, and pays gas. |

**Validation reward formula:**

```
Payout = 500 + (block_count × 25) + (gas_per_second × 10)
```

Later blocks pay more, and passive income from upgrades boosts each validation.

### Passive income

After buying Market upgrades, you earn `gas_per_second` every second automatically. Debuffs from crises can reduce or pause this rate (see [Network Crises](#network-crises)).

### Blockchain visualizer

- Each validated block gets an index and a simulated hash linked to the previous block.
- Block 1 is labeled **Genesis**.
- The Nodes tab shows the **8 most recent** blocks; up to **50** are stored in your save.

### Gas bar

The top gas bar always shows your current **Gas Units** balance.

---

## Progression Guide

### Market upgrades (in order)

Upgrades require passing the matching Academy audit first. Each tier also requires the previous tier's audit.

| Upgrade | Starting cost | Gas/sec per level | Cost scaling |
|---------|---------------|-------------------|--------------|
| **Deploy Smart Contract** | 15 gas | +1 | ×1.45 per purchase |
| **Setup Liquidity Pool** | 100 gas | +8 | ×1.50 per purchase |
| **Establish DAO Governance** | 1,000 gas | +50 | ×1.55 per purchase |

You can buy each upgrade multiple times. Levels stack — every purchase adds more passive gas per second.

### Recommended path

1. **Mine** until you can afford the Smart Contract audit and first upgrade.
2. **Certify** Smart Contract → buy Contract upgrades.
3. **Certify** Liquidity Pool → buy Pool upgrades.
4. **Certify** DAO Governance → buy DAO upgrades.
5. Keep alternating **validating blocks** (burst income) with **upgrade purchases** (passive income).

---

## Academy & Certifications

### Audits tab

Three assessments unlock the three Market tiers:

| Order | Assessment | Unlocks |
|-------|------------|---------|
| 1 | Smart Contract Assessment | Deploy Smart Contract |
| 2 | Liquidity Pool Assessment | Setup Liquidity Pool (requires Smart Contract passed) |
| 3 | DAO Governance Assessment | Establish DAO Governance (requires Liquidity Pool passed) |

- Tap **Take Audit** on an unlocked card to start the quiz.
- Each quiz has **3 multiple-choice options**.
- Wrong answers show a hint; you can retry until correct.
- Passing an audit is permanent for that save.

### Glossary tab

Browse definitions for terms including **Gas**, **Genesis Block**, **Smart Contract**, **Liquidity Pool**, **DAO**, **Immutable Ledger**, and **Consensus**. Use this as an in-game reference while learning.

---

## Network Crises

At specific block heights, a **Network Crisis** popup interrupts gameplay. You must choose option **A** (usually costs gas) or **B** (usually applies a debuff).

| Block # | Crisis | Option A (pay gas) | Option B (risk) |
|---------|--------|-------------------|-----------------|
| 3 | Oracle Failure | −300 gas, stabilize | −30% yield for 45s |
| 7 | Mempool Spam | −500 gas, clear mempool | +10s validate cooldown for 30s |
| 12 | DAO Quorum | −100 gas, +200 gas bonus | No reward |
| 18 | Node Desync | −1,000 gas, sync node | Pause passive yield for 40s |

Each crisis appears **once per save**. If you cannot afford option A, that button is disabled — you may need to choose B or earn more gas first.

Crisis state is saved; unresolved crises resume when you reload the game.

---

## Tutorial

New games include a **first-minute guided tour** using a coach overlay that highlights UI elements step by step:

1. Write transactions (fill the mempool)
2. Validate a block
3. Open **Nodes** and view the chain
4. Open **Academy** → Audits
5. Switch to the **Glossary** tab
6. Open **Market** and view upgrades

You can **Skip** at any time. To replay later, open **Settings → Replay Tutorial** (runs on your current save without wiping progress).

Settings, quizzes, and crises are blocked while the tutorial is active.

---

## Settings

Open Settings with the **⚙** button (splash screen or in-game header).

| Option | Behavior |
|--------|----------|
| **Master Volume** | Adjusts overall game audio. Saved separately from game progress. |
| **Replay Tutorial** | Restarts the coach overlay on your current save. |
| **Quit to Main Menu** | Auto-saves and returns to the splash screen. |
| **Reset Game** | Shows a confirmation prompt, then deletes all progress and returns to splash. |

Close Settings with the **X** button or by tapping the dimmed background.

Settings cannot be opened during quizzes, crises, or the active tutorial.

---

## Save Data

### Game progress

| File | Location | Contents |
|------|----------|----------|
| `genesis_block_save.json` | Godot `user://` directory | Gas, upgrades, blocks, quiz results, crises, tutorial state, debuffs |

On desktop, `user://` maps to a per-project folder under your OS user data path (shown in Godot under **Project → Open User Data Folder**).

The game saves automatically after most actions (mining, validating, upgrades, quizzes, crises). Quitting via Settings also saves.

### Player preferences

| File | Location | Contents |
|------|----------|----------|
| `settings.json` | `user://` | Master volume |

Preferences persist across new games and resets.

---

## Tips & Strategy

- **Fill before you validate** — validation is only available at `10 / 10` transactions.
- **Audits before upgrades** — Market cards stay locked until you pass the matching quiz.
- **Follow the audit order** — Pool and DAO assessments require earlier certifications.
- **Balance active and passive income** — validating gives large bursts; upgrades fund steady gas/sec.
- **Read crisis hints** — the effect summary at the bottom explains costs and risks before you choose.
- **Use the Glossary** — especially before audits, to reinforce terminology.
- **Continue vs Start** — use **Continue** to resume; **Start** wipes progress and replays the tutorial.

---

## Project Structure

```
genesis-block/
├── main_game.gd / main_game.tscn   # Main scene — game logic and UI shell
├── game_content.gd                 # Quizzes, glossary, upgrades, crises (data)
├── project.godot                   # Godot project config
├── default_bus_layout.tres         # Audio buses (Master, UI)
└── ui/
    ├── components/                 # Reusable UI (nav, cards, settings, tutorial, …)
    ├── services/                   # Autoloads: GameAudio, GameSettings
    ├── theme/                      # CyberConstants, CyberUI, fonts
    ├── textures/                   # Sprites and UI art
    ├── fonts/                      # Space Mono
    └── audio/                      # UI and gameplay sound effects
```

### Autoloads

| Name | Role |
|------|------|
| `GameAudio` | Plays UI, mining, quiz, and upgrade sounds |
| `GameSettings` | Loads/saves master volume to `user://settings.json` |

### Key constants (`ui/theme/cyber_constants.gd`)

| Constant | Value |
|----------|-------|
| Mempool capacity | 10 transactions |
| Validate base payout | 500 gas |
| Viewport | 720 × 1280 (portrait) |

---

## For Developers

### Editing game content

Most player-facing text and balance data lives in `game_content.gd`:

- `UPGRADES` — Market card titles, descriptions, yields
- `QUIZZES` — Assessment questions and answers
- `GLOSSARY` — Academy glossary entries
- `NETWORK_CRISES` / `CRISIS_BLOCK_TRIGGERS` — Crisis events and block milestones

Upgrade costs and scaling are computed in `main_game.gd` (`apply_*_upgrade` functions).

### Adding UI components

Follow existing patterns:

- Cyberpunk styling via `CyberUI` and `CyberConstants`
- Full-screen overlays (quiz, crisis, settings) sit at the root of `main_game.tscn` and set `overlay_blocking_input`
- Button sounds via `CyberUI.wire_button_sound(button, GameAudio.play_ui_click)`

### Exporting

Configure export presets in Godot (**Project → Export**). This repo does not ship pre-built binaries — build for your target platform using the Godot export templates.

### Engine notes

- Renderer: **GL Compatibility** (mobile-friendly)
- Main scene UID: `uid://bm8hvxl2rtn20`
- Handheld orientation: portrait

---

## License

See repository ownership and license terms from the project maintainer. If no license file is present, assume all rights reserved unless stated otherwise.
