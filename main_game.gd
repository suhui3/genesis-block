extends Control

const GameContent = preload("res://game_content.gd")
const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberUI = preload("res://ui/theme/cyber_ui.gd")
const GlossaryEntryScene = preload("res://ui/components/glossary_entry.tscn")
const UpgradeCardBase = preload("res://ui/components/upgrade_card_base.gd")
const SAVE_PATH := "user://genesis_block_save.json"
const MAX_VISIBLE_BLOCKS := 8
const MAX_STORED_BLOCKS := 50

# ==========================================
# CORE GAME DATA VARIABLES
# ==========================================
var gas_units: float = 0.0
var gas_per_click: float = 1.0
var gas_per_second: float = 0.0
var mempool_count: int = 0

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

var quiz_passed: Dictionary = {
	"contract": false,
	"pool": false,
	"dao": false,
}

var active_quiz_tier: String = ""
var overlay_blocking_input: bool = false
var active_crisis_id: String = ""
var resolved_crises: Dictionary = {}
var _yield_multiplier: float = 1.0
var _validate_cooldown_until: float = 0.0
var _passive_paused: bool = false
var _debuff_expires_at: float = 0.0
var _debuff_timer: Timer
var _active_tab: int = CyberConstants.TAB_MINING
var _active_academy_subtab: int = CyberConstants.ACADEMY_SUBTAB_AUDITS

# ==========================================
# VISUAL COMPONENT NODE LINK REFERENCES
# ==========================================
@onready var splash_screen = $SplashScreen
@onready var button_continue = $SplashScreen/ButtonStack/ButtonContinue
@onready var button_start = $SplashScreen/ButtonStack/ButtonStart
@onready var gameplay_shell = $GameplayShell
@onready var screen_header = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/ScreenHeader
@onready var gas_bar = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/GasBar
@onready var bottom_nav = $GameplayShell/RootVBox/BottomNavBar
@onready var nodes_tab = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/NodesTab
@onready var block_list_vbox = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/NodesTab/NodesScroll/BlockListVBox
@onready var mining_tab = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MiningTab
@onready var mempool_panel = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MiningTab/MempoolPanel
@onready var mempool_label = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MiningTab/MempoolPanel/MempoolLabel
@onready var button_write = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MiningTab/MiningActions/WriteColumn/ButtonWrite
@onready var button_validate = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MiningTab/MiningActions/ValidateColumn/ButtonValidate
@onready var write_hint = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MiningTab/MiningActions/WriteColumn/WriteHint
@onready var validate_hint = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MiningTab/MiningActions/ValidateColumn/ValidateHint
@onready var payout_label = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MiningTab/PayoutLabel
@onready var gas_rate_label = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MiningTab/GasRateLabel
@onready var market_tab = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MarketTab
@onready var card_contract = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MarketTab/MarketScroll/MarketCards/CardContract
@onready var card_pool = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MarketTab/MarketScroll/MarketCards/CardPool
@onready var card_dao = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MarketTab/MarketScroll/MarketCards/CardDao
@onready var academy_tab = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/AcademyTab
@onready var academy_sub_nav = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/AcademyTab/AcademySubNav
@onready var audits_scroll = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/AcademyTab/AuditsScroll
@onready var assessment_cards = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/AcademyTab/AuditsScroll/AssessmentCards
@onready var assessment_contract = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/AcademyTab/AuditsScroll/AssessmentCards/AssessmentContract
@onready var assessment_pool = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/AcademyTab/AuditsScroll/AssessmentCards/AssessmentPool
@onready var assessment_dao = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/AcademyTab/AuditsScroll/AssessmentCards/AssessmentDao
@onready var glossary_scroll = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/AcademyTab/GlossaryScroll
@onready var glossary_list = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/AcademyTab/GlossaryScroll/GlossaryList
@onready var quiz_avatar_icon = $QuizPanel/QuizBorder/QuizVBox/AvatarRow/AvatarPanel/AvatarIcon
@onready var quiz_panel = $QuizPanel
@onready var quiz_title_label = $QuizPanel/QuizBorder/QuizVBox/TitleStack/QuizTitleLabel
@onready var quiz_title_shadow = $QuizPanel/QuizBorder/QuizVBox/TitleStack/TitleShadow
@onready var quiz_question_label = $QuizPanel/QuizBorder/QuizVBox/QuestionPanel/QuizQuestionLabel
@onready var quiz_option_buttons: Array[Button] = [
	$QuizPanel/QuizBorder/QuizVBox/OptionsVBox/ButtonQuizOption0,
	$QuizPanel/QuizBorder/QuizVBox/OptionsVBox/ButtonQuizOption1,
	$QuizPanel/QuizBorder/QuizVBox/OptionsVBox/ButtonQuizOption2,
]
@onready var quiz_feedback_label = $QuizPanel/QuizBorder/QuizVBox/HintPanel/QuizFeedbackLabel
@onready var content_margin = $GameplayShell/RootVBox/ContentMargin
@onready var chrome_vbox = $GameplayShell/RootVBox/ContentMargin/ChromeVBox
@onready var mining_actions = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MiningTab/MiningActions
@onready var write_column = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MiningTab/MiningActions/WriteColumn
@onready var validate_column = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MiningTab/MiningActions/ValidateColumn
@onready var market_cards = $GameplayShell/RootVBox/ContentMargin/ChromeVBox/TabContent/MarketTab/MarketScroll/MarketCards
@onready var quiz_border = $QuizPanel/QuizBorder
@onready var quiz_vbox = $QuizPanel/QuizBorder/QuizVBox
@onready var quiz_options_vbox = $QuizPanel/QuizBorder/QuizVBox/OptionsVBox
@onready var quiz_hint_panel = $QuizPanel/QuizBorder/QuizVBox/HintPanel
@onready var quiz_avatar_panel = $QuizPanel/QuizBorder/QuizVBox/AvatarRow/AvatarPanel
@onready var quiz_question_panel = $QuizPanel/QuizBorder/QuizVBox/QuestionPanel
@onready var quiz_title_stack = $QuizPanel/QuizBorder/QuizVBox/TitleStack
@onready var crisis_panel = $CrisisPanel
@onready var crisis_margin = $CrisisPanel/CrisisMargin
@onready var crisis_scroll = $CrisisPanel/CrisisMargin/CrisisScroll
@onready var crisis_stack = $CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack
@onready var crisis_top_spacer = $CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack/TopSpacer
@onready var crisis_border = $CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack/CrisisBorder
@onready var crisis_bottom_spacer = $CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack/BottomSpacer
@onready var crisis_vbox = $CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack/CrisisBorder/CrisisVBox
@onready var crisis_title_label = $CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack/CrisisBorder/CrisisVBox/TitleStack/CrisisTitleLabel
@onready var crisis_title_shadow = $CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack/CrisisBorder/CrisisVBox/TitleStack/TitleShadow
@onready var crisis_title_stack = $CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack/CrisisBorder/CrisisVBox/TitleStack
@onready var crisis_desc_panel = $CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack/CrisisBorder/CrisisVBox/DescPanel
@onready var crisis_desc_label = $CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack/CrisisBorder/CrisisVBox/DescPanel/CrisisDescLabel
@onready var crisis_options_vbox = $CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack/CrisisBorder/CrisisVBox/OptionsVBox
@onready var crisis_effect_hint_panel = $CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack/CrisisBorder/CrisisVBox/EffectHintPanel
@onready var crisis_effect_hint_label = $CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack/CrisisBorder/CrisisVBox/EffectHintPanel/CrisisEffectHintLabel
@onready var crisis_option_buttons: Array[Button] = [
	$CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack/CrisisBorder/CrisisVBox/OptionsVBox/ButtonCrisisOptionA,
	$CrisisPanel/CrisisMargin/CrisisScroll/CrisisStack/CrisisBorder/CrisisVBox/OptionsVBox/ButtonCrisisOptionB,
]

var game_timer: Timer
var game_started: bool = false
var _has_save: bool = false
var _last_visualized_block_count: int = -1

# ==========================================
# INITIALIZATION LIFECYCLE
# ==========================================
func _ready():
	quiz_panel.visible = false
	crisis_panel.visible = false
	_setup_cyber_styles()
	_populate_glossary()
	_connect_market_cards()
	_connect_assessment_cards()
	academy_sub_nav.configure(PackedStringArray(CyberConstants.ACADEMY_SUBTAB_LABELS))
	academy_sub_nav.tab_selected.connect(_on_academy_subtab_selected)
	_switch_academy_subtab(CyberConstants.ACADEMY_SUBTAB_AUDITS)
	bottom_nav.tab_selected.connect(_on_tab_selected)
	load_game()
	_update_splash_buttons()
	splash_screen.visible = true
	gameplay_shell.visible = false

func _setup_cyber_styles() -> void:
	_apply_gameplay_layout()
	mempool_panel.add_theme_stylebox_override("panel", CyberUI.outline_panel(CyberConstants.CYAN))
	CyberUI.apply_title(mempool_label, CyberConstants.CYAN, CyberConstants.BASE_FONT_BODY_LG)
	_style_mining_button(button_write, true)
	_style_mining_button(button_validate, false)
	CyberUI.apply_italic(write_hint, CyberConstants.TEXT_DIM, CyberConstants.BASE_FONT_CAPTION)
	CyberUI.apply_italic(validate_hint, CyberConstants.TEXT_DIM, CyberConstants.BASE_FONT_CAPTION)
	CyberUI.apply_title(payout_label, CyberConstants.CYAN, CyberConstants.BASE_FONT_SMALL)
	CyberUI.apply_body(gas_rate_label, CyberConstants.TEXT_GRAY, CyberConstants.BASE_FONT_SMALL)
	_setup_quiz_styles()
	_setup_crisis_styles()

func _apply_gameplay_layout() -> void:
	var margin := CyberUI.scaled(CyberConstants.BASE_MARGIN)
	content_margin.add_theme_constant_override("margin_left", margin)
	content_margin.add_theme_constant_override("margin_top", margin)
	content_margin.add_theme_constant_override("margin_right", margin)
	content_margin.add_theme_constant_override("margin_bottom", CyberUI.scaled(CyberConstants.BASE_MARGIN_BOTTOM))
	CyberUI.set_separation(chrome_vbox, CyberConstants.BASE_SEP_CHROME)
	CyberUI.set_separation(nodes_tab, CyberConstants.BASE_SEP_COMPACT)
	CyberUI.set_separation(block_list_vbox, CyberConstants.BASE_SEP_COMPACT)
	CyberUI.set_separation(mining_tab, CyberConstants.BASE_SEP_SECTION)
	CyberUI.set_separation(mining_actions, CyberConstants.BASE_SEP_CHROME)
	CyberUI.set_separation(write_column, CyberConstants.BASE_SEP_TIGHT)
	CyberUI.set_separation(validate_column, CyberConstants.BASE_SEP_TIGHT)
	CyberUI.set_separation(market_cards, CyberConstants.BASE_SEP_CARD)
	CyberUI.set_separation(assessment_cards, CyberConstants.BASE_SEP_CARD)
	CyberUI.set_separation(academy_tab, CyberConstants.BASE_SEP_COMPACT)
	CyberUI.set_separation(glossary_list, CyberConstants.BASE_SEP_GLOSSARY)
	var mining_btn_h := CyberUI.touch_height(CyberConstants.BASE_MINING_BUTTON_HEIGHT)
	button_write.custom_minimum_size = Vector2(0, mining_btn_h)
	button_validate.custom_minimum_size = Vector2(0, mining_btn_h)

func _style_mining_button(button: Button, primary: bool) -> void:
	var accent := CyberConstants.CYAN if primary else CyberConstants.MAGENTA
	CyberUI.apply_button_states(button, accent, true, CyberConstants.TEXT_WHITE)
	CyberUI.apply_button_font(button, CyberConstants.BASE_FONT_SMALL, true)

func _setup_quiz_styles() -> void:
	var inset := CyberUI.scaled_f(12.0)
	quiz_border.offset_left = inset
	quiz_border.offset_top = CyberUI.scaled_f(24.0)
	quiz_border.offset_right = -inset
	quiz_border.offset_bottom = -CyberUI.scaled_f(24.0)
	quiz_border.add_theme_stylebox_override(
		"panel",
		CyberUI.outline_panel(CyberConstants.CYAN, CyberConstants.BG_DARK, 2)
	)
	CyberUI.set_separation(quiz_vbox, CyberConstants.BASE_SEP_SECTION)
	CyberUI.set_separation(quiz_title_stack, CyberConstants.BASE_SEP_HEADER)
	CyberUI.set_separation(quiz_options_vbox, CyberConstants.BASE_SEP_COMPACT)
	quiz_title_stack.get_node("TitleUnderline").custom_minimum_size.y = CyberUI.scaled(
		CyberConstants.BASE_UNDERLINE
	)
	quiz_title_shadow.text = "QUIZ"
	CyberUI.apply_title(quiz_title_shadow, CyberConstants.MAGENTA, CyberConstants.BASE_FONT_TITLE)
	quiz_title_shadow.position = Vector2(2, 2)
	CyberUI.apply_title(quiz_title_label, CyberConstants.CYAN, CyberConstants.BASE_FONT_TITLE)
	quiz_avatar_panel.custom_minimum_size = CyberUI.scaled_vec2(
		Vector2(CyberConstants.BASE_QUIZ_AVATAR, CyberConstants.BASE_QUIZ_AVATAR)
	)
	quiz_avatar_panel.add_theme_stylebox_override(
		"panel",
		CyberUI.outline_panel(CyberConstants.MAGENTA)
	)
	_setup_quiz_icon()
	quiz_question_panel.add_theme_stylebox_override(
		"panel",
		CyberUI.outline_panel(CyberConstants.TEXT_WHITE, CyberConstants.BG_PANEL, 1)
	)
	
	CyberUI.apply_body(quiz_question_label, CyberConstants.TEXT_WHITE, CyberConstants.BASE_FONT_BODY)
	quiz_hint_panel.custom_minimum_size.y = CyberUI.scaled(CyberConstants.BASE_QUIZ_HINT_HEIGHT)
	var hint_box := StyleBoxFlat.new()
	hint_box.bg_color = Color(0, 0, 0, 0)
	hint_box.border_color = CyberConstants.MAGENTA
	hint_box.set_border_width_all(1)
	hint_box.draw_center = false
	quiz_hint_panel.add_theme_stylebox_override("panel", hint_box)
	CyberUI.apply_italic(quiz_feedback_label, CyberConstants.MAGENTA, CyberConstants.BASE_FONT_SMALL)
	quiz_feedback_label.text = "[ Hint appears here if wrong ]"

func _setup_quiz_icon() -> void:
	quiz_avatar_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	quiz_avatar_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	quiz_avatar_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quiz_avatar_icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quiz_avatar_icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var texture := _load_quiz_icon()
	if texture:
		quiz_avatar_icon.texture = texture
		quiz_avatar_icon.visible = true
	else:
		quiz_avatar_icon.visible = false

func _load_quiz_icon() -> Texture2D:
	if not ResourceLoader.exists(CyberConstants.QUIZ_ICON_PATH):
		return null
	return load(CyberConstants.QUIZ_ICON_PATH) as Texture2D

func _setup_crisis_styles() -> void:
	var inset := CyberUI.scaled(CyberConstants.BASE_MARGIN)
	crisis_margin.add_theme_constant_override("margin_left", inset)
	crisis_margin.add_theme_constant_override("margin_top", CyberUI.scaled(CyberConstants.BASE_MARGIN))
	crisis_margin.add_theme_constant_override("margin_right", inset)
	crisis_margin.add_theme_constant_override("margin_bottom", CyberUI.scaled(CyberConstants.BASE_MARGIN_BOTTOM))
	crisis_border.add_theme_stylebox_override(
		"panel",
		CyberUI.outline_panel(CyberConstants.MAGENTA, CyberConstants.BG_PANEL, 2)
	)
	crisis_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	crisis_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	crisis_top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	crisis_bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	crisis_border.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	crisis_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	crisis_scroll.resized.connect(_sync_crisis_layout)
	CyberUI.set_separation(crisis_vbox, CyberConstants.BASE_SEP_SECTION)
	CyberUI.set_separation(crisis_title_stack, CyberConstants.BASE_SEP_HEADER)
	CyberUI.set_separation(crisis_options_vbox, CyberConstants.BASE_SEP_COMPACT)
	var underline := crisis_title_stack.get_node("TitleUnderline") as ColorRect
	underline.custom_minimum_size.y = CyberUI.scaled(CyberConstants.BASE_UNDERLINE)
	underline.color = CyberConstants.MAGENTA
	crisis_title_shadow.text = "NETWORK CRISIS"
	CyberUI.apply_title(crisis_title_shadow, CyberConstants.MAGENTA, CyberConstants.BASE_FONT_TITLE)
	crisis_title_shadow.position = Vector2(2, 2)
	CyberUI.apply_title(crisis_title_label, CyberConstants.CYAN, CyberConstants.BASE_FONT_TITLE)
	crisis_desc_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	crisis_desc_panel.add_theme_stylebox_override(
		"panel",
		CyberUI.outline_panel(CyberConstants.TEXT_WHITE, CyberConstants.BG_PANEL, 1)
	)
	CyberUI.apply_body(crisis_desc_label, CyberConstants.TEXT_WHITE, CyberConstants.BASE_FONT_BODY)
	crisis_effect_hint_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	crisis_effect_hint_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var hint_box := StyleBoxFlat.new()
	hint_box.bg_color = Color(0, 0, 0, 0)
	hint_box.border_color = CyberConstants.MAGENTA
	hint_box.set_border_width_all(1)
	hint_box.draw_center = false
	crisis_effect_hint_panel.add_theme_stylebox_override("panel", hint_box)
	CyberUI.apply_italic(crisis_effect_hint_label, CyberConstants.MAGENTA, CyberConstants.BASE_FONT_SMALL)
	crisis_effect_hint_label.text = "Choose a response to restore network stability."

func _sync_crisis_layout() -> void:
	if not crisis_scroll or not crisis_stack:
		return
	crisis_stack.custom_minimum_size = Vector2(crisis_scroll.size.x, crisis_scroll.size.y)

func _connect_market_cards() -> void:
	card_contract.upgrade_pressed.connect(_on_button_upgrade_contract_pressed)
	card_pool.upgrade_pressed.connect(_on_button_upgrade_pool_pressed)
	card_dao.upgrade_pressed.connect(_on_button_upgrade_dao_pressed)
	card_contract.audit_pressed.connect(_on_audit_pressed)
	card_pool.audit_pressed.connect(_on_audit_pressed)
	card_dao.audit_pressed.connect(_on_audit_pressed)
	card_contract.go_to_academy_pressed.connect(_on_go_to_academy_pressed)
	card_pool.go_to_academy_pressed.connect(_on_go_to_academy_pressed)
	card_dao.go_to_academy_pressed.connect(_on_go_to_academy_pressed)

func _connect_assessment_cards() -> void:
	assessment_contract.audit_pressed.connect(_on_audit_pressed)
	assessment_pool.audit_pressed.connect(_on_audit_pressed)
	assessment_dao.audit_pressed.connect(_on_audit_pressed)

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
	mempool_count = 0
	cost_contract = 15.0
	count_contract = 0
	cost_pool = 100.0
	count_pool = 0
	cost_dao = 1000.0
	count_dao = 0
	block_count = 0
	block_chain = []
	quiz_passed = {
		"contract": false,
		"pool": false,
		"dao": false,
	}
	active_quiz_tier = ""
	active_crisis_id = ""
	resolved_crises = {}
	_clear_active_debuff()
	overlay_blocking_input = false
	if crisis_panel:
		crisis_panel.visible = false
	game_started = false
	_active_tab = CyberConstants.TAB_MINING
	_active_academy_subtab = CyberConstants.ACADEMY_SUBTAB_AUDITS
	_last_visualized_block_count = -1
	if game_timer:
		game_timer.stop()
		game_timer.queue_free()
		game_timer = null

func _enter_gameplay(from_splash: bool) -> void:
	splash_screen.visible = false
	gameplay_shell.visible = true
	_last_visualized_block_count = -1
	setup_background_clock()
	_switch_tab(CyberConstants.TAB_MINING)
	refresh_user_interface()
	if not active_crisis_id.is_empty():
		show_crisis_popup(active_crisis_id)
	if from_splash:
		save_game()

func _on_tab_selected(tab_index: int) -> void:
	if overlay_blocking_input:
		return
	_switch_tab(tab_index)

func _switch_tab(tab_index: int) -> void:
	_active_tab = tab_index
	bottom_nav.set_active_tab(tab_index)
	screen_header.set_title(CyberConstants.TAB_TITLES[tab_index])
	nodes_tab.visible = tab_index == CyberConstants.TAB_NODES
	mining_tab.visible = tab_index == CyberConstants.TAB_MINING
	market_tab.visible = tab_index == CyberConstants.TAB_MARKET
	academy_tab.visible = tab_index == CyberConstants.TAB_ACADEMY
	if tab_index == CyberConstants.TAB_ACADEMY:
		_switch_academy_subtab(CyberConstants.ACADEMY_SUBTAB_AUDITS)

func _on_academy_subtab_selected(subtab_index: int) -> void:
	if overlay_blocking_input:
		return
	_switch_academy_subtab(subtab_index)

func _switch_academy_subtab(subtab_index: int) -> void:
	_active_academy_subtab = subtab_index
	academy_sub_nav.set_active_tab(subtab_index)
	audits_scroll.visible = subtab_index == CyberConstants.ACADEMY_SUBTAB_AUDITS
	glossary_scroll.visible = subtab_index == CyberConstants.ACADEMY_SUBTAB_GLOSSARY

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
		"mempool_count": mempool_count,
		"cost_contract": cost_contract,
		"count_contract": count_contract,
		"cost_pool": cost_pool,
		"count_pool": count_pool,
		"cost_dao": cost_dao,
		"count_dao": count_dao,
		"block_count": block_count,
		"block_chain": _trim_block_chain_for_save(),
		"quiz_passed": quiz_passed,
		"game_started": game_started,
		"resolved_crises": resolved_crises,
		"active_crisis_id": active_crisis_id,
		"yield_multiplier": _yield_multiplier,
		"passive_paused": _passive_paused,
		"validate_cooldown_until": _validate_cooldown_until,
		"debuff_expires_at": _debuff_expires_at,
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
	mempool_count = int(data.get("mempool_count", mempool_count))
	cost_contract = float(data.get("cost_contract", cost_contract))
	count_contract = int(data.get("count_contract", count_contract))
	cost_pool = float(data.get("cost_pool", cost_pool))
	count_pool = int(data.get("count_pool", count_pool))
	cost_dao = float(data.get("cost_dao", cost_dao))
	count_dao = int(data.get("count_dao", count_dao))
	block_count = int(data.get("block_count", block_count))
	block_chain = data.get("block_chain", block_chain)
	_merge_dictionary(quiz_passed, data.get("quiz_passed", {}))
	game_started = bool(data.get("game_started", game_started))
	mempool_count = mini(mempool_count, CyberConstants.MEMPOOL_CAPACITY)
	var saved_crises = data.get("resolved_crises", {})
	if typeof(saved_crises) == TYPE_DICTIONARY:
		for key in saved_crises:
			resolved_crises[key] = saved_crises[key]
	active_crisis_id = str(data.get("active_crisis_id", ""))
	_yield_multiplier = float(data.get("yield_multiplier", 1.0))
	_passive_paused = bool(data.get("passive_paused", false))
	_validate_cooldown_until = float(data.get("validate_cooldown_until", 0.0))
	_debuff_expires_at = float(data.get("debuff_expires_at", 0.0))
	GameContent.backfill_resolved_crises(block_count, resolved_crises, active_crisis_id)
	_restore_debuff_timer()

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
func _on_write_button_pressed():
	if overlay_blocking_input:
		return
	if mempool_count >= CyberConstants.MEMPOOL_CAPACITY:
		return
	var added := int(gas_per_click)
	mempool_count = mini(mempool_count + added, CyberConstants.MEMPOOL_CAPACITY)
	refresh_user_interface()
	save_game()

func _on_validate_button_pressed():
	if overlay_blocking_input:
		return
	if Time.get_ticks_msec() < _validate_cooldown_until:
		return
	if mempool_count < CyberConstants.MEMPOOL_CAPACITY:
		return
	var payout := _calculate_validate_payout()
	gas_units += payout
	mempool_count = 0
	append_block()
	refresh_user_interface()
	save_game()

func _calculate_validate_payout() -> float:
	return (
		CyberConstants.VALIDATE_BASE_PAYOUT
		+ (block_count * CyberConstants.VALIDATE_BLOCK_MULT)
		+ (gas_per_second * CyberConstants.VALIDATE_PASSIVE_MULT)
	)

func _on_button_upgrade_contract_pressed():
	if overlay_blocking_input or not is_certified("contract") or gas_units < cost_contract:
		return
	apply_contract_upgrade()
	refresh_user_interface()
	save_game()

func _on_button_upgrade_pool_pressed():
	if overlay_blocking_input or not is_certified("pool") or gas_units < cost_pool:
		return
	apply_pool_upgrade()
	refresh_user_interface()
	save_game()

func _on_button_upgrade_dao_pressed():
	if overlay_blocking_input or not is_certified("dao") or gas_units < cost_dao:
		return
	apply_dao_upgrade()
	refresh_user_interface()
	save_game()

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
	if overlay_blocking_input or _passive_paused:
		return
	gas_units += gas_per_second * _yield_multiplier
	refresh_user_interface()

func _on_quiz_option_pressed(option_index: int) -> void:
	if active_quiz_tier.is_empty():
		return
	var quiz: Dictionary = GameContent.QUIZZES[active_quiz_tier]
	if option_index == quiz["correct_index"]:
		quiz_passed[active_quiz_tier] = true
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
	_schedule_crisis_check()

func _schedule_crisis_check() -> void:
	var crisis_id := GameContent.get_crisis_for_block(block_count)
	if crisis_id.is_empty() or resolved_crises.get(crisis_id, false):
		return
	_deferred_show_crisis(crisis_id)

func _deferred_show_crisis(crisis_id: String) -> void:
	await get_tree().process_frame
	if crisis_id.is_empty() or resolved_crises.get(crisis_id, false):
		return
	show_crisis_popup(crisis_id)

func rebuild_block_visualizer() -> void:
	if block_count == _last_visualized_block_count:
		return
	_last_visualized_block_count = block_count
	for child in block_list_vbox.get_children():
		child.queue_free()
	if block_chain.is_empty():
		var empty_panel := PanelContainer.new()
		empty_panel.add_theme_stylebox_override("panel", CyberUI.outline_panel(CyberConstants.MAGENTA))
		var empty_label := Label.new()
		empty_label.text = "No blocks validated yet"
		CyberUI.apply_body(empty_label, CyberConstants.TEXT_GRAY, CyberConstants.BASE_FONT_SMALL)
		empty_panel.add_child(empty_label)
		block_list_vbox.add_child(empty_panel)
		return
	var start_index := maxi(0, block_chain.size() - MAX_VISIBLE_BLOCKS)
	for i in range(start_index, block_chain.size()):
		var block: Dictionary = block_chain[i]
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", CyberUI.outline_panel(CyberConstants.CYAN))
		var label := Label.new()
		if block["index"] == 1:
			label.text = "Genesis -> %s" % block["hash"]
		else:
			label.text = "#%d %s <- %s" % [block["index"], block["hash"], block["prev"]]
		CyberUI.apply_body(label, CyberConstants.TEXT_WHITE, CyberConstants.BASE_FONT_SMALL)
		panel.add_child(label)
		block_list_vbox.add_child(panel)

# ==========================================
# GLOSSARY
# ==========================================
func _populate_glossary() -> void:
	for child in glossary_list.get_children():
		child.queue_free()
	var index := 0
	for term in GameContent.GLOSSARY:
		var entry: VBoxContainer = GlossaryEntryScene.instantiate()
		glossary_list.add_child(entry)
		entry.configure(term, GameContent.GLOSSARY[term], index % 2 == 0)
		index += 1

# ==========================================
# QUIZ
# ==========================================
func show_quiz(tier: String) -> void:
	active_quiz_tier = tier
	overlay_blocking_input = true
	quiz_panel.z_index = 10
	var quiz: Dictionary = GameContent.QUIZZES[tier]
	quiz_title_label.text = quiz["title"].to_upper()
	quiz_question_label.text = quiz["question"]
	quiz_feedback_label.text = "[ Hint appears here if wrong ]"
	for i in quiz_option_buttons.size():
		var button = quiz_option_buttons[i]
		if i < quiz["options"].size():
			button.configure(i, quiz["options"][i])
			button.visible = true
		else:
			button.visible = false
	quiz_panel.visible = true
	refresh_upgrades()
	refresh_assessments()
	refresh_input_locks()

func hide_quiz() -> void:
	quiz_panel.visible = false
	active_quiz_tier = ""
	if not crisis_panel.visible:
		overlay_blocking_input = false
	refresh_upgrades()
	refresh_assessments()
	refresh_input_locks()

# ==========================================
# NETWORK CRISIS
# ==========================================
func show_crisis_popup(crisis_id: String) -> void:
	if not GameContent.NETWORK_CRISES.has(crisis_id):
		return
	active_crisis_id = crisis_id
	overlay_blocking_input = true
	crisis_panel.z_index = 10
	var data: Dictionary = GameContent.NETWORK_CRISES[crisis_id]
	crisis_title_label.text = "⚠️ %s" % data["title"]
	crisis_desc_label.text = data["desc"]
	crisis_option_buttons[0].configure(0, data["opt_a_text"], "A")
	crisis_option_buttons[1].configure(1, data["opt_b_text"], "B")
	var cost: float = float(data.get("opt_a_cost", 0))
	crisis_option_buttons[0].disabled = gas_units < cost
	crisis_option_buttons[1].disabled = false
	crisis_effect_hint_label.text = _build_crisis_hint_text(data)
	crisis_border.position = Vector2.ZERO
	crisis_vbox.position = Vector2.ZERO
	crisis_scroll.scroll_vertical = 0
	crisis_panel.visible = true
	await get_tree().process_frame
	_sync_crisis_layout()
	_play_crisis_shake()
	refresh_upgrades()
	refresh_input_locks()
	save_game()

func hide_crisis_popup() -> void:
	if not active_crisis_id.is_empty():
		resolved_crises[active_crisis_id] = true
	crisis_panel.visible = false
	active_crisis_id = ""
	if not quiz_panel.visible:
		overlay_blocking_input = false
	refresh_upgrades()
	refresh_input_locks()

func _build_crisis_hint_text(data: Dictionary) -> String:
	var cost: float = float(data.get("opt_a_cost", 0))
	var parts: PackedStringArray = []
	if cost > 0:
		parts.append("Option A Cost: -%d Gas" % int(cost))
	match data.get("opt_a_effect", ""):
		"STABLE":
			parts.append("Safety: Stable")
		"CLEAR":
			parts.append("Effect: Clear Mempool")
		"SYNC":
			parts.append("Effect: Node Synced")
		"BONUS":
			parts.append("Reward: +%d Gas" % int(data.get("bonus_gas", 0)))
	match data.get("opt_b_effect", ""):
		"SLOW":
			if data.get("pause_yield", false):
				parts.append("Option B Risk: Pause Yield")
			elif data.has("validate_cooldown_sec"):
				parts.append("Option B Risk: +%ds Validate Wait" % int(data["validate_cooldown_sec"]))
			else:
				var penalty := int((1.0 - float(data.get("slow_mult", 0.7))) * 100.0)
				parts.append("Option B Risk: -%d%% Yield" % penalty)
		"NEUTRAL":
			parts.append("Option B: No Reward")
	return " | ".join(parts)

func _play_crisis_shake() -> void:
	var shake_offset := CyberUI.scaled_f(10.0)
	var tween := create_tween()
	tween.tween_property(crisis_vbox, "position", Vector2(shake_offset, 0), 0.05)
	tween.tween_property(crisis_vbox, "position", Vector2(-shake_offset, 0), 0.05)
	tween.tween_property(crisis_vbox, "position", Vector2.ZERO, 0.05)

func _on_crisis_option_a_pressed() -> void:
	_apply_crisis_choice("a")

func _on_crisis_option_b_pressed() -> void:
	_apply_crisis_choice("b")

func _apply_crisis_choice(option: String) -> void:
	if active_crisis_id.is_empty():
		return
	var data: Dictionary = GameContent.NETWORK_CRISES[active_crisis_id]
	if option == "a":
		var cost: float = float(data.get("opt_a_cost", 0))
		gas_units = maxf(gas_units - cost, 0.0)
		match data.get("opt_a_effect", ""):
			"BONUS":
				gas_units += float(data.get("bonus_gas", 0))
	else:
		_clear_active_debuff()
		match data.get("opt_b_effect", ""):
			"SLOW":
				if data.has("validate_cooldown_sec"):
					_start_validate_throttle(
						float(data["validate_cooldown_sec"]),
						float(data.get("slow_duration", 30)),
					)
				elif data.get("pause_yield", false):
					_start_passive_pause(float(data.get("slow_duration", 40)))
				else:
					_start_yield_debuff(
						float(data.get("slow_mult", 0.7)),
						float(data.get("slow_duration", 45)),
					)
	hide_crisis_popup()
	refresh_user_interface()
	save_game()

func _ensure_debuff_timer() -> void:
	if _debuff_timer:
		return
	_debuff_timer = Timer.new()
	_debuff_timer.one_shot = true
	_debuff_timer.timeout.connect(_on_debuff_timer_timeout)
	add_child(_debuff_timer)

func _start_debuff_timer(duration_sec: float) -> void:
	_ensure_debuff_timer()
	_debuff_expires_at = Time.get_ticks_msec() + duration_sec * 1000.0
	_debuff_timer.wait_time = duration_sec
	_debuff_timer.start()

func _on_debuff_timer_timeout() -> void:
	_clear_active_debuff()
	refresh_user_interface()

func _clear_active_debuff() -> void:
	_yield_multiplier = 1.0
	_passive_paused = false
	_validate_cooldown_until = 0.0
	_debuff_expires_at = 0.0
	if _debuff_timer:
		_debuff_timer.stop()

func _start_yield_debuff(multiplier: float, duration_sec: float) -> void:
	_clear_active_debuff()
	_yield_multiplier = multiplier
	_start_debuff_timer(duration_sec)

func _start_passive_pause(duration_sec: float) -> void:
	_clear_active_debuff()
	_passive_paused = true
	_start_debuff_timer(duration_sec)

func _start_validate_throttle(cooldown_sec: float, duration_sec: float) -> void:
	_clear_active_debuff()
	_validate_cooldown_until = Time.get_ticks_msec() + cooldown_sec * 1000.0
	_start_debuff_timer(duration_sec)

func _restore_debuff_timer() -> void:
	var now := Time.get_ticks_msec()
	if _validate_cooldown_until > 0.0 and _validate_cooldown_until <= now:
		_validate_cooldown_until = 0.0
	if _debuff_expires_at <= now:
		_clear_active_debuff()
		return
	_ensure_debuff_timer()
	_debuff_timer.wait_time = maxf((_debuff_expires_at - now) / 1000.0, 0.01)
	_debuff_timer.start()

func _get_debuff_seconds_remaining() -> int:
	if _debuff_expires_at <= 0.0:
		return 0
	return maxi(0, int(ceil((_debuff_expires_at - Time.get_ticks_msec()) / 1000.0)))

func _get_validate_cooldown_seconds_remaining() -> int:
	if _validate_cooldown_until <= 0.0:
		return 0
	return maxi(0, int(ceil((_validate_cooldown_until - Time.get_ticks_msec()) / 1000.0)))

# ==========================================
# CERTIFICATION
# ==========================================
func is_certified(tier: String) -> bool:
	return quiz_passed.get(tier, false)

func is_quiz_unlocked(tier: String) -> bool:
	var prereq := GameContent.get_prereq_tier(tier)
	return prereq.is_empty() or is_certified(prereq)

func get_cert_lock_state(tier: String) -> UpgradeCardBase.CertLockState:
	if is_certified(tier):
		return UpgradeCardBase.CertLockState.UNLOCKED
	if not is_quiz_unlocked(tier):
		return UpgradeCardBase.CertLockState.NEEDS_PREREQ
	return UpgradeCardBase.CertLockState.NEEDS_AUDIT

func _get_next_required_tier() -> String:
	for tier in GameContent.QUIZ_ORDER:
		if not is_certified(tier):
			return tier
	return ""

func _get_assessment_card(tier: String):
	match tier:
		"contract":
			return assessment_contract
		"pool":
			return assessment_pool
		"dao":
			return assessment_dao
	return null

func _build_lock_copy(tier: String, lock_state: UpgradeCardBase.CertLockState) -> Dictionary:
	var upgrade: Dictionary = GameContent.UPGRADES[tier]
	if lock_state == UpgradeCardBase.CertLockState.NEEDS_PREREQ:
		var prereq := GameContent.get_prereq_tier(tier)
		var prereq_quiz: Dictionary = GameContent.QUIZZES[prereq]
		return {
			"header": upgrade["title"],
			"body": "Complete the %s first." % prereq_quiz["title"],
		}
	var quiz: Dictionary = GameContent.QUIZZES[tier]
	return {
		"header": upgrade["title"],
		"body": 'Pass the "%s" in Academy before deploying.' % quiz["title"],
	}

func _on_audit_pressed(tier: String) -> void:
	show_quiz(tier)

func _on_go_to_academy_pressed(_tier: String) -> void:
	_navigate_to_assessment()

func _navigate_to_assessment() -> void:
	var target_tier := _get_next_required_tier()
	if target_tier.is_empty():
		return
	_switch_tab(CyberConstants.TAB_ACADEMY)
	await get_tree().process_frame
	var card = _get_assessment_card(target_tier)
	if card:
		audits_scroll.ensure_control_visible(card)
		card.highlight()

# ==========================================
# UI REFRESH
# ==========================================
func refresh_user_interface():
	refresh_gas_bar()
	refresh_mining()
	refresh_upgrades()
	refresh_assessments()
	rebuild_block_visualizer()
	refresh_input_locks()

func refresh_gas_bar() -> void:
	gas_bar.set_gas(gas_units)

func refresh_mining() -> void:
	mempool_label.text = (
		"Unverified Transactions: [ %d / %d ]"
		% [mempool_count, CyberConstants.MEMPOOL_CAPACITY]
	)
	write_hint.text = "Adds raw tx data (+%d Tx to Pool)" % int(gas_per_click)
	var cooldown_left := _get_validate_cooldown_seconds_remaining()
	if cooldown_left > 0:
		validate_hint.text = "Validate locked: %ds remaining" % cooldown_left
	else:
		validate_hint.text = "Requires %d tx" % CyberConstants.MEMPOOL_CAPACITY
	var payout := _calculate_validate_payout()
	payout_label.text = "Rewards: +%d Gas Units" % int(payout)
	var rate_text := "Network Speed: %s Gas/sec" % gas_per_second
	if _passive_paused:
		var pause_left := _get_debuff_seconds_remaining()
		rate_text = "Network Speed: PAUSED (%ds)" % pause_left
	elif _yield_multiplier < 1.0:
		var yield_left := _get_debuff_seconds_remaining()
		rate_text = "Network Speed: %s Gas/sec (%d%%, %ds)" % [
			gas_per_second * _yield_multiplier,
			int(_yield_multiplier * 100.0),
			yield_left,
		]
	gas_rate_label.text = rate_text
	var pool_full := mempool_count >= CyberConstants.MEMPOOL_CAPACITY
	var validate_locked := cooldown_left > 0
	button_validate.disabled = overlay_blocking_input or not pool_full or validate_locked
	button_write.disabled = overlay_blocking_input or pool_full

func refresh_upgrades() -> void:
	var input_blocked := overlay_blocking_input
	_configure_card(
		card_contract,
		"contract",
		count_contract,
		cost_contract,
		yield_contract,
		input_blocked,
	)
	_configure_card(card_pool, "pool", count_pool, cost_pool, yield_pool, input_blocked)
	_configure_card(card_dao, "dao", count_dao, cost_dao, yield_dao, input_blocked)

func refresh_assessments() -> void:
	_configure_assessment(assessment_contract, "contract")
	_configure_assessment(assessment_pool, "pool")
	_configure_assessment(assessment_dao, "dao")

func _configure_assessment(card, tier: String) -> void:
	var def: Dictionary = GameContent.UPGRADES[tier]
	var quiz: Dictionary = GameContent.QUIZZES[tier]
	var lock_state := get_cert_lock_state(tier)
	card.configure(tier, def["title"], quiz["title"], def["description"], lock_state)

func _configure_card(
	card,
	tier: String,
	level: int,
	cost: float,
	yield_amount: float,
	input_blocked: bool,
) -> void:
	var def: Dictionary = GameContent.UPGRADES[tier]
	var lock_state := get_cert_lock_state(tier)
	var lock_copy := _build_lock_copy(tier, lock_state)
	card.configure(
		tier,
		def["title"],
		level,
		def["description"],
		"+%s GAS/SEC" % int(yield_amount),
		cost,
		gas_units >= cost,
		input_blocked,
		lock_state,
		lock_copy["header"],
		lock_copy["body"],
	)

func refresh_input_locks() -> void:
	var blocked := overlay_blocking_input
	bottom_nav.mouse_filter = Control.MOUSE_FILTER_STOP if blocked else Control.MOUSE_FILTER_PASS
	academy_sub_nav.set_blocked(blocked)
	for button in quiz_option_buttons:
		button.disabled = not quiz_panel.visible
	if crisis_panel.visible and not active_crisis_id.is_empty():
		var data: Dictionary = GameContent.NETWORK_CRISES[active_crisis_id]
		var cost: float = float(data.get("opt_a_cost", 0))
		crisis_option_buttons[0].disabled = gas_units < cost
		crisis_option_buttons[1].disabled = false
	elif not crisis_panel.visible:
		for button in crisis_option_buttons:
			button.disabled = true
