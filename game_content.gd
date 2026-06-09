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

static func get_prereq_tier(tier: String) -> String:
	var idx := QUIZ_ORDER.find(tier)
	return "" if idx <= 0 else QUIZ_ORDER[idx - 1]

static func build_glossary_bbcode() -> String:
	var parts: PackedStringArray = []
	for term in GLOSSARY:
		parts.append("[b]%s[/b]\n%s\n" % [term, GLOSSARY[term]])
	return "\n".join(parts)
