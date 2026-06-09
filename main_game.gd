extends Control

const GameContent = preload("res://game_content.gd")
const SAVE_PATH := "user://genesis_block_save.json"
const MAX_VISIBLE_BLOCKS := 8
const MAX_STORED_BLOCKS := 50

# ==========================================
# CORE GAME DATA VARIABLES
# ==========================================
var gas_units: float = 0.0
var gas_per_click: float = 1.0
var gas_per_second: float = 0.0

var cost_contract: float = 15.0
var count_contract: int = 0
var yield_contract: float = 1.0

var cost_pool: float = 100.0
var count_pool: int = 0
var yield_pool: float = 8.0

var cost_dao: float = 1000.0
var count_dao: int = 0
var yield_dao: float = 50.0

# ==========================================
# EDUCATIONAL STATE
# ==========================================
var block_count: int = 0
var block_chain: Array = []

var concepts_unlocked: Dictionary = {
	"gas": false,
	"genesis_block": false,
	"smart_contract": false,
	"liquidity_pool": false,
	"dao": false,
}

var quiz_passed: Dictionary = {
	"contract": false,
	"pool": false,
	"dao": false,
}

var active_quiz_tier: String = ""
var quiz_blocking_input: bool = false

# ==========================================
# VISUAL COMPONENT NODE LINK REFERENCES
# ==========================================
@onready var splash_screen = $SplashScreen
@onready var button_continue = $SplashScreen/ButtonContinue
@onready var button_start = $SplashScreen/ButtonStart
@onready var gameplay_container = $GameplayVBox
@onready var button_learn = $GameplayVBox/HBoxToolbar/ButtonLearn
@onready var journal_label = $GameplayVBox/HBoxToolbar/LabelJournal
@onready var block_chain_row = $GameplayVBox/BlockChainScroll/BlockChainRow
@onready var currency_label = $GameplayVBox/LabelCurrency
@onready var button_clicker = $GameplayVBox/ButtonClicker
@onready var contract_button = $GameplayVBox/ScrollContainer/UpgradeListContainer/ButtonUpgradeContract
@onready var pool_button = $GameplayVBox/ScrollContainer/UpgradeListContainer/ButtonUpgradePool
@onready var dao_button = $GameplayVBox/ScrollContainer/UpgradeListContainer/ButtonUpgradeDao
@onready var learn_panel = $LearnPanel
@onready var glossary_label = $LearnPanel/VBoxContainer/ScrollContainer/GlossaryLabel
@onready var quiz_panel = $QuizPanel
@onready var quiz_title_label = $QuizPanel/VBoxContainer/LabelQuizTitle
@onready var quiz_question_label = $QuizPanel/VBoxContainer/LabelQuizQuestion
@onready var quiz_option_buttons: Array[Button] = [
	$QuizPanel/VBoxContainer/ButtonQuizOption0,
	$QuizPanel/VBoxContainer/ButtonQuizOption1,
	$QuizPanel/VBoxContainer/ButtonQuizOption2,
]
@onready var quiz_feedback_label = $QuizPanel/VBoxContainer/LabelQuizFeedback

var game_timer: Timer
var game_started: bool = false
var _has_save: bool = false
var _last_visualized_block_count: int = -1

# ==========================================
# INITIALIZATION LIFECYCLE
# ==========================================
func _ready():
	learn_panel.visible = false
	quiz_panel.visible = false
	load_game()
	_populate_glossary()
	_update_splash_buttons()
	splash_screen.visible = true
	gameplay_container.visible = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()

func _update_splash_buttons() -> void:
	button_continue.visible = _has_save and game_started

func _on_continue_button_pressed() -> void:
	_enter_gameplay(true)

func _on_start_button_pressed() -> void:
	reset_game()
	game_started = true
	_enter_gameplay(true)

func reset_game() -> void:
	gas_units = 0.0
	gas_per_click = 1.0
	gas_per_second = 0.0
	cost_contract = 15.0
	count_contract = 0
	cost_pool = 100.0
	count_pool = 0
	cost_dao = 1000.0
	count_dao = 0
	block_count = 0
	block_chain = []
	concepts_unlocked = {
		"gas": false,
		"genesis_block": false,
		"smart_contract": false,
		"liquidity_pool": false,
		"dao": false,
	}
	quiz_passed = {
		"contract": false,
		"pool": false,
		"dao": false,
	}
	active_quiz_tier = ""
	quiz_blocking_input = false
	game_started = false
	_last_visualized_block_count = -1
	if game_timer:
		game_timer.stop()
		game_timer.queue_free()
		game_timer = null

func _enter_gameplay(from_splash: bool) -> void:
	splash_screen.visible = false
	gameplay_container.visible = true
	_last_visualized_block_count = -1
	setup_background_clock()
	refresh_user_interface()
	if from_splash:
		save_game()

func setup_background_clock():
	if game_timer:
		return
	game_timer = Timer.new()
	game_timer.wait_time = 1.0
	game_timer.autostart = true
	game_timer.timeout.connect(_on_every_second_elapsed)
	add_child(game_timer)

# ==========================================
# SAVE / LOAD
# ==========================================
func save_game() -> void:
	var data := {
		"gas_units": gas_units,
		"gas_per_click": gas_per_click,
		"gas_per_second": gas_per_second,
		"cost_contract": cost_contract,
		"count_contract": count_contract,
		"cost_pool": cost_pool,
		"count_pool": count_pool,
		"cost_dao": cost_dao,
		"count_dao": count_dao,
		"block_count": block_count,
		"block_chain": _trim_block_chain_for_save(),
		"concepts_unlocked": concepts_unlocked,
		"quiz_passed": quiz_passed,
		"game_started": game_started,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	_has_save = true
	var data: Dictionary = parsed
	gas_units = float(data.get("gas_units", gas_units))
	gas_per_click = float(data.get("gas_per_click", gas_per_click))
	gas_per_second = float(data.get("gas_per_second", gas_per_second))
	cost_contract = float(data.get("cost_contract", cost_contract))
	count_contract = int(data.get("count_contract", count_contract))
	cost_pool = float(data.get("cost_pool", cost_pool))
	count_pool = int(data.get("count_pool", count_pool))
	cost_dao = float(data.get("cost_dao", cost_dao))
	count_dao = int(data.get("count_dao", count_dao))
	block_count = int(data.get("block_count", block_count))
	block_chain = data.get("block_chain", block_chain)
	_merge_dictionary(concepts_unlocked, data.get("concepts_unlocked", {}))
	_merge_dictionary(quiz_passed, data.get("quiz_passed", {}))
	game_started = bool(data.get("game_started", game_started))

func _trim_block_chain_for_save() -> Array:
	if block_chain.size() <= MAX_STORED_BLOCKS:
		return block_chain
	return block_chain.slice(block_chain.size() - MAX_STORED_BLOCKS)

func _merge_dictionary(target: Dictionary, source: Variant) -> void:
	if typeof(source) != TYPE_DICTIONARY:
		return
	for key in source:
		if target.has(key):
			target[key] = source[key]

# ==========================================
# INTERACTIVE USER ACTIONS
# ==========================================
func _on_clicker_button_pressed():
	if quiz_blocking_input:
		return
	gas_units += gas_per_click
	append_block()
	unlock_concept("gas")
	if block_count == 1:
		unlock_concept("genesis_block")
	refresh_user_interface()
	if block_count % 5 == 0:
		save_game()

func _on_button_upgrade_contract_pressed():
	if quiz_blocking_input or gas_units < cost_contract:
		return
	var is_first_purchase := count_contract == 0
	apply_contract_upgrade()
	refresh_user_interface()
	save_game()
	if is_first_purchase and not quiz_passed["contract"]:
		show_quiz("contract")

func _on_button_upgrade_pool_pressed():
	if quiz_blocking_input or gas_units < cost_pool:
		return
	var is_first_purchase := count_pool == 0
	apply_pool_upgrade()
	refresh_user_interface()
	save_game()
	if is_first_purchase and not quiz_passed["pool"]:
		show_quiz("pool")

func _on_button_upgrade_dao_pressed():
	if quiz_blocking_input or gas_units < cost_dao:
		return
	var is_first_purchase := count_dao == 0
	apply_dao_upgrade()
	refresh_user_interface()
	save_game()
	if is_first_purchase and not quiz_passed["dao"]:
		show_quiz("dao")

func apply_contract_upgrade() -> void:
	gas_units -= cost_contract
	count_contract += 1
	gas_per_second += yield_contract
	cost_contract = int(cost_contract * 1.45)

func apply_pool_upgrade() -> void:
	gas_units -= cost_pool
	count_pool += 1
	gas_per_second += yield_pool
	cost_pool = int(cost_pool * 1.50)

func apply_dao_upgrade() -> void:
	gas_units -= cost_dao
	count_dao += 1
	gas_per_second += yield_dao
	cost_dao = int(cost_dao * 1.55)

func _on_every_second_elapsed():
	if quiz_blocking_input:
		return
	gas_units += gas_per_second
	refresh_user_interface()

func _on_learn_button_pressed():
	if quiz_blocking_input:
		return
	gameplay_container.visible = false
	learn_panel.visible = true

func _on_learn_back_pressed():
	learn_panel.visible = false
	gameplay_container.visible = true

func _on_quiz_option_pressed(option_index: int) -> void:
	if active_quiz_tier.is_empty():
		return
	var quiz: Dictionary = GameContent.QUIZZES[active_quiz_tier]
	if option_index == quiz["correct_index"]:
		quiz_passed[active_quiz_tier] = true
		unlock_concept(quiz["concept"])
		hide_quiz()
		refresh_user_interface()
		save_game()
	else:
		quiz_feedback_label.text = quiz["explain_wrong"]

func _on_quiz_option_0_pressed() -> void:
	_on_quiz_option_pressed(0)

func _on_quiz_option_1_pressed() -> void:
	_on_quiz_option_pressed(1)

func _on_quiz_option_2_pressed() -> void:
	_on_quiz_option_pressed(2)

# ==========================================
# BLOCKCHAIN VISUALIZER
# ==========================================
func append_block() -> void:
	var prev_hash := "0000"
	if not block_chain.is_empty():
		prev_hash = block_chain[-1]["hash"]
	block_count += 1
	var fake_hash := str(abs(hash(str(block_count) + prev_hash)) % 10000).pad_zeros(4)
	block_chain.append({
		"index": block_count,
		"hash": fake_hash,
		"prev": prev_hash,
	})
	if block_chain.size() > MAX_STORED_BLOCKS:
		block_chain = block_chain.slice(block_chain.size() - MAX_STORED_BLOCKS)

func rebuild_block_visualizer() -> void:
	if block_count == _last_visualized_block_count:
		return
	_last_visualized_block_count = block_count
	for child in block_chain_row.get_children():
		child.queue_free()
	if block_chain.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No blocks written yet"
		block_chain_row.add_child(empty_label)
		return
	var start_index := maxi(0, block_chain.size() - MAX_VISIBLE_BLOCKS)
	for i in range(start_index, block_chain.size()):
		var block: Dictionary = block_chain[i]
		var label := Label.new()
		if block["index"] == 1:
			label.text = "Genesis -> %s" % block["hash"]
		else:
			label.text = "#%d %s <- %s" % [block["index"], block["hash"], block["prev"]]
		block_chain_row.add_child(label)

# ==========================================
# LEARNING JOURNAL
# ==========================================
func unlock_concept(id: String) -> void:
	if not concepts_unlocked.has(id) or concepts_unlocked[id]:
		return
	concepts_unlocked[id] = true
	refresh_journal()
	save_game()

func refresh_journal() -> void:
	var parts: PackedStringArray = []
	for id in ["gas", "genesis_block", "smart_contract", "liquidity_pool", "dao"]:
		var mark := "✓" if concepts_unlocked.get(id, false) else "○"
		parts.append("%s %s" % [GameContent.CONCEPT_LABELS[id], mark])
	journal_label.text = "Learned: " + " | ".join(parts)

# ==========================================
# GLOSSARY
# ==========================================
func _populate_glossary() -> void:
	glossary_label.bbcode_enabled = true
	glossary_label.text = GameContent.build_glossary_bbcode()

# ==========================================
# QUIZ
# ==========================================
func show_quiz(tier: String) -> void:
	active_quiz_tier = tier
	quiz_blocking_input = true
	var quiz: Dictionary = GameContent.QUIZZES[tier]
	quiz_title_label.text = quiz["title"]
	quiz_question_label.text = quiz["question"]
	quiz_feedback_label.text = ""
	for i in quiz_option_buttons.size():
		if i < quiz["options"].size():
			quiz_option_buttons[i].text = quiz["options"][i]
			quiz_option_buttons[i].visible = true
		else:
			quiz_option_buttons[i].visible = false
	quiz_panel.visible = true
	refresh_input_locks()

func hide_quiz() -> void:
	quiz_panel.visible = false
	active_quiz_tier = ""
	quiz_blocking_input = false

# ==========================================
# UI REFRESH
# ==========================================
func refresh_user_interface():
	refresh_currency()
	refresh_upgrades()
	refresh_journal()
	rebuild_block_visualizer()
	refresh_input_locks()

func refresh_currency() -> void:
	currency_label.text = "Wallet Ledger Balance: " + str(int(gas_units)) + " Gas Units\nNetwork Performance Speed: " + str(gas_per_second) + " Gas/sec"

func refresh_upgrades() -> void:
	contract_button.text = "Deploy Smart Contract [Lvl " + str(count_contract) + "]\nCost: " + str(cost_contract) + " Gas | Provides +" + str(yield_contract) + " Gas/sec\n(Automates execution logic safely without middleware)"
	pool_button.text = "Setup Liquidity Pool [Lvl " + str(count_pool) + "]\nCost: " + str(cost_pool) + " Gas | Provides +" + str(yield_pool) + " Gas/sec\n(Injects deeper automated capital funding mechanics)"
	dao_button.text = "Establish DAO Governance [Lvl " + str(count_dao) + "]\nCost: " + str(cost_dao) + " Gas | Provides +" + str(yield_dao) + " Gas/sec\n(Unlocks native decentralized stakeholder vote weighting)"

func refresh_input_locks() -> void:
	var blocked := quiz_blocking_input
	button_clicker.disabled = blocked
	button_learn.disabled = blocked
	contract_button.disabled = blocked or gas_units < cost_contract
	pool_button.disabled = blocked or gas_units < cost_pool
	dao_button.disabled = blocked or gas_units < cost_dao
	for button in quiz_option_buttons:
		button.disabled = not quiz_panel.visible
