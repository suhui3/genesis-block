extends Control
class_name UpgradeCardBase

const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberUI = preload("res://ui/theme/cyber_ui.gd")

enum CertLockState { UNLOCKED, NEEDS_PREREQ, NEEDS_AUDIT }

@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/VBox/HeaderBar/HeaderHBox/TitleLabel
@onready var level_label: Label = $Panel/VBox/HeaderBar/HeaderHBox/LevelLabel
@onready var description_label: Label = $Panel/VBox/Body/DescriptionLabel
@onready var effect_label: Label = $Panel/VBox/Body/EffectLabel
@onready var footer: HBoxContainer = $Panel/VBox/Footer

func _enter_tree() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	custom_minimum_size.y = CyberUI.scaled(CyberConstants.BASE_MARKET_CARD_HEIGHT)

func _ready() -> void:
	clip_contents = true
	panel.add_theme_stylebox_override("panel", CyberUI.outline_panel(CyberConstants.MAGENTA))
	$Panel/VBox/HeaderBar.add_theme_stylebox_override("panel", CyberUI.header_bar())
	$Panel/VBox.add_theme_constant_override("separation", 0)
	CyberUI.set_separation($Panel/VBox/Body, CyberConstants.BASE_SEP_COMPACT)
	CyberUI.set_separation(footer, CyberConstants.BASE_SEP_COMPACT)
	CyberUI.apply_title(title_label, CyberConstants.TEXT_WHITE, CyberConstants.BASE_FONT_SMALL)
	CyberUI.apply_body(level_label, CyberConstants.TEXT_DIM, CyberConstants.BASE_FONT_SMALL)
	CyberUI.apply_body(description_label, CyberConstants.TEXT_GRAY, CyberConstants.BASE_FONT_SMALL)
	CyberUI.apply_body(effect_label, CyberConstants.CYAN, CyberConstants.BASE_FONT_SMALL)

func set_card_height(locked: bool) -> void:
	var base := (
		CyberConstants.BASE_MARKET_CARD_LOCKED_HEIGHT
		if locked
		else CyberConstants.BASE_MARKET_CARD_HEIGHT
	)
	custom_minimum_size.y = CyberUI.scaled(base)

func set_header(title: String, level: int) -> void:
	title_label.text = title
	level_label.text = "[Lvl %d]" % level
	level_label.visible = true
	CyberUI.apply_body(
		level_label,
		CyberConstants.CYAN if level > 0 else CyberConstants.TEXT_DIM,
		CyberConstants.BASE_FONT_SMALL,
	)

func set_body(description: String, effect_text: String) -> void:
	description_label.text = description
	effect_label.text = "⚡ EFFECT: " + effect_text
