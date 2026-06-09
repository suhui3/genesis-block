extends Control

# ==========================================
# 🛑 CORE GAME DATA VARIABLES
# ==========================================
var gas_units: float = 0.0
var gas_per_click: float = 1.0
var gas_per_second: float = 0.0

# Upgrade Tier 1: Smart Contract
var cost_contract: float = 15.0
var count_contract: int = 0
var yield_contract: float = 1.0

# Upgrade Tier 2: Liquidity Pool
var cost_pool: float = 100.0
var count_pool: int = 0
var yield_pool: float = 8.0

# Upgrade Tier 3: DAO Governance
var cost_dao: float = 1000.0
var count_dao: int = 0
var yield_dao: float = 50.0

# ==========================================
# 🖥️ VISUAL COMPONENT NODE LINK REFERENCES
# ==========================================
@onready var splash_screen = $SplashScreen
@onready var gameplay_container = $GameplayVBox
@onready var currency_label = $GameplayVBox/LabelCurrency
@onready var contract_button = $GameplayVBox/ScrollContainer/UpgradeListContainer/ButtonUpgradeContract
@onready var pool_button = $GameplayVBox/ScrollContainer/UpgradeListContainer/ButtonUpgradePool
@onready var dao_button = $GameplayVBox/ScrollContainer/UpgradeListContainer/ButtonUpgradeDao

var game_timer: Timer
var game_started: bool = false

# ==========================================
# ⚙️ INITIALIZATION LIFECYCLE
# ==========================================
func _ready():
	splash_screen.visible = true
	gameplay_container.visible = false

func _on_start_button_pressed():
	if game_started:
		return
	game_started = true
	splash_screen.visible = false
	gameplay_container.visible = true
	setup_background_clock()
	refresh_user_interface()

# Spawns a background clock runner that fires every 1000 milliseconds
func setup_background_clock():
	if game_timer:
		return
	game_timer = Timer.new()
	game_timer.wait_time = 1.0
	game_timer.autostart = true
	game_timer.timeout.connect(_on_every_second_elapsed)
	add_child(game_timer)

# ==========================================
# 🎮 INTERACTIVE USER ACTIONS
# ==========================================

# Fires instantly whenever the main coding button is tapped
func _on_clicker_button_pressed():
	gas_units += gas_per_click
	refresh_user_interface()

# Purchase Execution: Smart Contract Layer
func _on_button_upgrade_contract_pressed():
	if gas_units >= cost_contract:
		gas_units -= cost_contract
		count_contract += 1
		gas_per_second += yield_contract
		cost_contract = int(cost_contract * 1.45) # Exponential scaling equation
		refresh_user_interface()

# Purchase Execution: Liquidity Pool Layer
func _on_button_upgrade_pool_pressed():
	if gas_units >= cost_pool:
		gas_units -= cost_pool
		count_pool += 1
		gas_per_second += yield_pool
		cost_pool = int(cost_pool * 1.50)
		refresh_user_interface()

# Purchase Execution: DAO Governance Layer
func _on_button_upgrade_dao_pressed():
	if gas_units >= cost_dao:
		gas_units -= cost_dao
		count_dao += 1
		gas_per_second += yield_dao
		cost_dao = int(cost_dao * 1.55)
		refresh_user_interface()

# Automated state advancement ticker triggered by background hardware clock
func _on_every_second_elapsed():
	gas_units += gas_per_second
	refresh_user_interface()

# ==========================================
# 📊 RENDERING AND VALIDATION GRAPHICS ENGINE
# ==========================================
func refresh_user_interface():
	# 1. Redraw the central telemetry metrics
	currency_label.text = "Wallet Ledger Balance: " + str(int(gas_units)) + " Gas Units\nNetwork Performance Speed: " + str(gas_per_second) + " Gas/sec"
	
	# 2. Re-render button titles with real-time costs and educational summaries
	contract_button.text = "Deploy Smart Contract [Lvl " + str(count_contract) + "]\nCost: " + str(cost_contract) + " Gas | Provides +" + str(yield_contract) + " Gas/sec\n(Automates execution logic safely without middleware)"
	
	pool_button.text = "Setup Liquidity Pool [Lvl " + str(count_pool) + "]\nCost: " + str(cost_pool) + " Gas | Provides +" + str(yield_pool) + " Gas/sec\n(Injects deeper automated capital funding mechanics)"
	
	dao_button.text = "Establish DAO Governance [Lvl " + str(count_dao) + "]\nCost: " + str(cost_dao) + " Gas | Provides +" + str(yield_dao) + " Gas/sec\n(Unlocks native decentralized stakeholder vote weighting)"
	
	# 3. Validation Logic Gate: Dynamic Gray-Out Engine Rule
	# Evaluates Boolean constraints; if true, items unlock. If false, item inputs freeze.
	contract_button.disabled = gas_units < cost_contract
	pool_button.disabled = gas_units < cost_pool
	dao_button.disabled = gas_units < cost_dao
