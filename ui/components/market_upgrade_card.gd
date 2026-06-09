extends PanelContainer

const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberUI = preload("res://ui/theme/cyber_ui.gd")
const UpgradeCardBase = preload("res://ui/components/upgrade_card_base.gd")

signal upgrade_pressed
signal audit_pressed(tier: String)
signal go_to_academy_pressed(tier: String)

@onready var title_label: Label = $VBox/HeaderBar/HeaderHBox/TitleLabel
@onready var level_label: Label = $VBox/HeaderBar/HeaderHBox/LevelLabel
@onready var normal_body: VBoxContainer = $VBox/NormalBody
@onready var description_label: Label = $VBox/NormalBody/DescriptionLabel
@onready var effect_label: Label = $VBox/NormalBody/EffectLabel
@onready var normal_footer: HBoxContainer = $VBox/NormalFooter
@onready var cost_label: Label = $VBox/NormalFooter/CostLabel
@onready var upgrade_button: Button = $VBox/NormalFooter/UpgradeButton
@onready var lock_section: VBoxContainer = $VBox/LockSection
@onready var lock_header_label: Label = $VBox/LockSection/LockHeaderLabel
@onready var lock_body_label: Label = $VBox/LockSection/LockBodyLabel
@onready var lock_cta_button: Button = $VBox/LockSection/LockCtaButton

var _tier: String = ""
var _lock_state: UpgradeCardBase.CertLockState = UpgradeCardBase.CertLockState.UNLOCKED

func _enter_tree() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN

func _ready() -> void:
	add_theme_stylebox_override("panel", CyberUI.outline_panel(CyberConstants.MAGENTA))
	$VBox/HeaderBar.add_theme_stylebox_override("panel", CyberUI.header_bar())
	$VBox.add_theme_constant_override("separation", 0)
	CyberUI.set_separation(normal_body, CyberConstants.BASE_SEP_COMPACT)
	CyberUI.set_separation(normal_footer, CyberConstants.BASE_SEP_COMPACT)
	CyberUI.set_separation(lock_section, CyberConstants.BASE_SEP_COMPACT)
	CyberUI.apply_title(title_label, CyberConstants.TEXT_WHITE, CyberConstants.BASE_FONT_SMALL)
	CyberUI.apply_body(level_label, CyberConstants.TEXT_DIM, CyberConstants.BASE_FONT_SMALL)
	CyberUI.apply_body(description_label, CyberConstants.TEXT_GRAY, CyberConstants.BASE_FONT_SMALL)
	CyberUI.apply_body(effect_label, CyberConstants.CYAN, CyberConstants.BASE_FONT_SMALL)
	cost_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	CyberUI.apply_body(cost_label, CyberConstants.COST_PINK, CyberConstants.BASE_FONT_SMALL)
	upgrade_button.custom_minimum_size = Vector2(
		CyberUI.scaled(CyberConstants.BASE_UPGRADE_BTN_WIDTH),
		CyberUI.touch_height(CyberConstants.BASE_UPGRADE_BTN_HEIGHT),
	)
	lock_cta_button.custom_minimum_size = Vector2(
		0,
		CyberUI.touch_height(CyberConstants.BASE_UPGRADE_BTN_HEIGHT),
	)
	lock_cta_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	CyberUI.apply_title(lock_header_label, CyberConstants.TEXT_WHITE, CyberConstants.BASE_FONT_SMALL)
	CyberUI.apply_body(lock_body_label, CyberConstants.TEXT_GRAY, CyberConstants.BASE_FONT_SMALL)
	lock_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	CyberUI.apply_button_font(lock_cta_button, CyberConstants.BASE_FONT_CAPTION, true)
	upgrade_button.pressed.connect(func(): upgrade_pressed.emit())
	lock_cta_button.pressed.connect(_on_lock_cta_pressed)
	lock_section.visible = false
	_apply_upgrade_button_style(true)
	_apply_lock_button_style()

func configure(
	tier: String,
	title: String,
	level: int,
	description: String,
	effect_text: String,
	cost: float,
	can_afford: bool,
	input_blocked: bool,
	lock_state: UpgradeCardBase.CertLockState,
	lock_header: String,
	lock_body: String,
) -> void:
	_tier = tier
	_lock_state = lock_state
	title_label.text = title
	level_label.text = "[Lvl %d]" % level
	CyberUI.apply_body(
		level_label,
		CyberConstants.CYAN if level > 0 else CyberConstants.TEXT_DIM,
		CyberConstants.BASE_FONT_SMALL,
	)
	description_label.text = description
	effect_label.text = "⚡ EFFECT: " + effect_text
	cost_label.text = "🔥 Cost: %s Gas" % int(cost)

	var cert_locked := lock_state != UpgradeCardBase.CertLockState.UNLOCKED
	modulate = Color(0.55, 0.55, 0.55, 1.0) if cert_locked else Color.WHITE
	normal_body.visible = not cert_locked
	normal_footer.visible = not cert_locked
	lock_section.visible = cert_locked

	if cert_locked:
		lock_header_label.text = "🚫 " + lock_header
		lock_body_label.text = lock_body
		lock_cta_button.text = (
			"GO TO ACADEMY" if lock_state == UpgradeCardBase.CertLockState.NEEDS_PREREQ else "TAKE AUDIT"
		)
	else:
		var blocked := input_blocked or not can_afford
		upgrade_button.disabled = blocked
		upgrade_button.text = "UPGRADE" if can_afford and not input_blocked else "INSUFFICIENT"
		_apply_upgrade_button_style(can_afford and not input_blocked)

func _on_lock_cta_pressed() -> void:
	if _lock_state == UpgradeCardBase.CertLockState.NEEDS_PREREQ:
		go_to_academy_pressed.emit(_tier)
	elif _lock_state == UpgradeCardBase.CertLockState.NEEDS_AUDIT:
		audit_pressed.emit(_tier)

func _apply_lock_button_style() -> void:
	var box := CyberUI.flat_button(CyberConstants.MAGENTA)
	lock_cta_button.add_theme_stylebox_override("normal", box)
	lock_cta_button.add_theme_stylebox_override("hover", box)
	lock_cta_button.add_theme_stylebox_override("pressed", box)
	lock_cta_button.add_theme_color_override("font_color", CyberConstants.MAGENTA)

func _apply_upgrade_button_style(enabled: bool) -> void:
	var border := CyberConstants.CYAN if enabled else CyberConstants.TEXT_DIM
	var box := CyberUI.flat_button(border)
	upgrade_button.add_theme_stylebox_override("normal", box)
	upgrade_button.add_theme_stylebox_override("hover", box)
	upgrade_button.add_theme_stylebox_override("disabled", box)
	upgrade_button.add_theme_color_override(
		"font_color",
		CyberConstants.CYAN if enabled else CyberConstants.TEXT_DIM
	)
	upgrade_button.add_theme_color_override("font_disabled_color", CyberConstants.TEXT_DIM)
	CyberUI.apply_button_font(upgrade_button, CyberConstants.BASE_FONT_CAPTION, true)
