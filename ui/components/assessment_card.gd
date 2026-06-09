extends PanelContainer

const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberUI = preload("res://ui/theme/cyber_ui.gd")
const UpgradeCardBase = preload("res://ui/components/upgrade_card_base.gd")

signal audit_pressed(tier: String)

@onready var title_label: Label = $VBox/HeaderBar/HeaderHBox/TitleLabel
@onready var description_label: Label = $VBox/Body/DescriptionLabel
@onready var audit_label: Label = $VBox/Body/AuditLabel
@onready var status_label: Label = $VBox/Footer/StatusLabel
@onready var audit_button: Button = $VBox/Footer/AuditButton

var _tier: String = ""

func _enter_tree() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	custom_minimum_size.y = CyberUI.scaled(CyberConstants.BASE_ASSESSMENT_CARD_HEIGHT)

func _ready() -> void:
	add_theme_stylebox_override("panel", CyberUI.outline_panel(CyberConstants.MAGENTA))
	$VBox/HeaderBar.add_theme_stylebox_override("panel", CyberUI.header_bar())
	$VBox.add_theme_constant_override("separation", 0)
	CyberUI.set_separation($VBox/Body, CyberConstants.BASE_SEP_COMPACT)
	CyberUI.set_separation($VBox/Footer, CyberConstants.BASE_SEP_COMPACT)
	CyberUI.apply_title(title_label, CyberConstants.TEXT_WHITE, CyberConstants.BASE_FONT_SMALL)
	CyberUI.apply_body(description_label, CyberConstants.TEXT_GRAY, CyberConstants.BASE_FONT_SMALL)
	CyberUI.apply_body(audit_label, CyberConstants.CYAN, CyberConstants.BASE_FONT_SMALL)
	CyberUI.apply_body(status_label, CyberConstants.TEXT_GRAY, CyberConstants.BASE_FONT_SMALL)
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	audit_button.custom_minimum_size = Vector2(
		CyberUI.scaled(CyberConstants.BASE_UPGRADE_BTN_WIDTH + 20),
		CyberUI.touch_height(CyberConstants.BASE_UPGRADE_BTN_HEIGHT),
	)
	CyberUI.apply_button_font(audit_button, CyberConstants.BASE_FONT_CAPTION, true)
	audit_button.pressed.connect(func(): audit_pressed.emit(_tier))

func configure(
	tier: String,
	title: String,
	quiz_title: String,
	description: String,
	lock_state: UpgradeCardBase.CertLockState,
) -> void:
	_tier = tier
	title_label.text = title
	description_label.text = description
	audit_label.text = '📋 Audit: "%s"' % quiz_title

	var certified := lock_state == UpgradeCardBase.CertLockState.UNLOCKED
	var prereq_locked := lock_state == UpgradeCardBase.CertLockState.NEEDS_PREREQ

	modulate = Color(0.55, 0.55, 0.55, 1.0) if prereq_locked else Color.WHITE

	if certified:
		status_label.text = "✓ PASSED"
		CyberUI.apply_body(status_label, CyberConstants.CYAN, CyberConstants.BASE_FONT_SMALL)
		audit_button.visible = false
	elif prereq_locked:
		status_label.text = "🔒 LOCKED"
		CyberUI.apply_body(status_label, CyberConstants.TEXT_DIM, CyberConstants.BASE_FONT_SMALL)
		audit_button.visible = false
	else:
		status_label.text = "○ AVAILABLE"
		CyberUI.apply_body(status_label, CyberConstants.MAGENTA, CyberConstants.BASE_FONT_SMALL)
		audit_button.visible = true
		audit_button.disabled = false
		_apply_audit_button_style(true)

func highlight() -> void:
	var orig := modulate
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1.3, 1.0, 1.3, 1.0), 0.15)
	tween.tween_property(self, "modulate", orig, 0.35)

func _apply_audit_button_style(enabled: bool) -> void:
	var border := CyberConstants.MAGENTA if enabled else CyberConstants.TEXT_DIM
	var box := CyberUI.flat_button(border)
	audit_button.add_theme_stylebox_override("normal", box)
	audit_button.add_theme_stylebox_override("hover", box)
	audit_button.add_theme_stylebox_override("disabled", box)
	audit_button.add_theme_color_override(
		"font_color",
		CyberConstants.MAGENTA if enabled else CyberConstants.TEXT_DIM
	)
	audit_button.add_theme_color_override("font_disabled_color", CyberConstants.TEXT_DIM)
