const QUIZ_ORDER := ["contract", "pool", "dao"]

const UPGRADES := {
	"contract": {
		"title": "DEPLOY SMART CONTRACT",
		"description": "Automates execution logic safely without middleware.",
		"yield": 1.0,
	},
	"pool": {
		"title": "SETUP LIQUIDITY POOL",
		"description": "Injects deeper automated capital funding mechanics.",
		"yield": 8.0,
	},
	"dao": {
		"title": "ESTABLISH DAO GOVERNANCE",
		"description": "Unlocks native decentralized stakeholder vote weighting.",
		"yield": 50.0,
	},
}

const GLOSSARY := {
	"Gas": "The fee required to execute operations on a blockchain network. Each transaction consumes gas, representing computational effort by network nodes.",
	"Genesis Block": "The first block in a blockchain. It has no previous block and anchors the entire immutable ledger chain.",
	"Smart Contract": "Self-executing code stored on the ledger that runs automatically when conditions are met, removing the need for a central intermediary.",
	"Liquidity Pool": "A shared reserve of assets used by Automated Market Makers (AMMs) to enable peer-to-peer trading without traditional clearing houses.",
	"DAO": "A Decentralized Autonomous Organization where stakeholders vote on protocol changes using token-weighted governance.",
	"Immutable Ledger": "A public record where confirmed blocks cannot be altered without consensus from the network, ensuring data integrity.",
	"Consensus": "The process by which distributed nodes agree on the valid state of the blockchain without a single authority.",
}

const QUIZZES := {
	"contract": {
		"title": "Smart Contract Assessment",
		"question": "What does a smart contract primarily replace?",
		"options": [
			"A central human intermediary",
			"The blockchain ledger itself",
			"Gas fees for transactions",
		],
		"correct_index": 0,
		"explain_wrong": "Smart contracts automate rules on-chain without a middleman enforcing them manually.",
		"concept": "smart_contract",
	},
	"pool": {
		"title": "Liquidity Pool Assessment",
		"question": "What role does a liquidity pool play in decentralized finance?",
		"options": [
			"Stores private keys for users",
			"Provides shared assets for automated peer-to-peer trading",
			"Replaces all blockchain validators",
		],
		"correct_index": 1,
		"explain_wrong": "Liquidity pools supply shared reserves so AMMs can facilitate trades without centralized clearing.",
		"concept": "liquidity_pool",
	},
	"dao": {
		"title": "DAO Governance Assessment",
		"question": "How are decisions typically made in a DAO?",
		"options": [
			"By a single network administrator",
			"Through decentralized stakeholder voting",
			"By random block selection only",
		],
		"correct_index": 1,
		"explain_wrong": "DAOs resolve proposals through token-weighted votes from distributed stakeholders.",
		"concept": "dao",
	},
}

const CRISIS_BLOCK_TRIGGERS := {
	3: "ORACLE_FAILURE",
	7: "MEMPOOL_SPAM",
	12: "DAO_QUORUM",
	18: "NODE_DESYNC",
}

const NETWORK_CRISES := {
	"ORACLE_FAILURE": {
		"title": "ORACLE FAILURE",
		"desc": "External price feeds stalled. Liquidity pools are mispricing assets.",
		"opt_a_text": "Re-sync Oracles: -300 Gas",
		"opt_a_cost": 300,
		"opt_a_effect": "STABLE",
		"opt_b_text": "Ignore: -30% Yield",
		"opt_b_effect": "SLOW",
		"slow_mult": 0.7,
		"slow_duration": 45,
	},
	"MEMPOOL_SPAM": {
		"title": "MEMPOOL SPAM",
		"desc": "A botnet is flooding the network with dust transactions.",
		"opt_a_text": "Increase Fees: -500 Gas",
		"opt_a_cost": 500,
		"opt_a_effect": "CLEAR",
		"opt_b_text": "Throttle: +10s Wait",
		"opt_b_effect": "SLOW",
		"validate_cooldown_sec": 10,
		"slow_duration": 30,
	},
	"DAO_QUORUM": {
		"title": "DAO QUORUM",
		"desc": "An emergency vote on protocol upgrades is pending.",
		"opt_a_text": "Cast Proxy Vote: -100 Gas",
		"opt_a_cost": 100,
		"opt_a_effect": "BONUS",
		"bonus_gas": 200,
		"opt_b_text": "Abstain: No Reward",
		"opt_b_effect": "NEUTRAL",
	},
	"NODE_DESYNC": {
		"title": "NODE DESYNC",
		"desc": "Your validator node has fallen behind the chain height.",
		"opt_a_text": "Hard Restart: -1000 Gas",
		"opt_a_cost": 1000,
		"opt_a_effect": "SYNC",
		"opt_b_text": "Soft Catch-up: Pause Yield",
		"opt_b_effect": "SLOW",
		"pause_yield": true,
		"slow_duration": 40,
	},
}

static func get_crisis_for_block(block: int) -> String:
	return CRISIS_BLOCK_TRIGGERS.get(block, "")

static func backfill_resolved_crises(block: int, resolved: Dictionary, pending_id: String) -> void:
	for trigger_block in CRISIS_BLOCK_TRIGGERS:
		if trigger_block > block:
			continue
		var crisis_id: String = CRISIS_BLOCK_TRIGGERS[trigger_block]
		if crisis_id == pending_id:
			continue
		resolved[crisis_id] = true

static func get_prereq_tier(tier: String) -> String:
	var idx := QUIZ_ORDER.find(tier)
	return "" if idx <= 0 else QUIZ_ORDER[idx - 1]

static func build_glossary_bbcode() -> String:
	var parts: PackedStringArray = []
	for term in GLOSSARY:
		parts.append("[b]%s[/b]\n%s\n" % [term, GLOSSARY[term]])
	return "\n".join(parts)
