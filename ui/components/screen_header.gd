extends VBoxContainer

const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberUI = preload("res://ui/theme/cyber_ui.gd")

signal settings_pressed

@onready var title_label: Label = $HeaderRow/TitleCenter/TitleLabel
@onready var underline: ColorRect = $Underline
@onready var settings_button: Button = $HeaderRow/RightSlot/SettingsButton

func _ready() -> void:
	CyberUI.apply_title(title_label, CyberConstants.CYAN, CyberConstants.BASE_FONT_SCREEN_TITLE)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	CyberUI.set_separation(self, CyberConstants.BASE_SEP_HEADER)
	underline.custom_minimum_size = Vector2(0, CyberUI.scaled(CyberConstants.BASE_UNDERLINE))
	underline.color = CyberConstants.MAGENTA
	settings_button.text = "⚙"
	settings_button.flat = true
	settings_button.focus_mode = Control.FOCUS_NONE
	settings_button.custom_minimum_size = Vector2(
		CyberUI.scaled(44),
		CyberUI.scaled(44),
	)
	CyberUI.apply_button_states(settings_button, CyberConstants.CYAN, true)
	CyberUI.apply_button_font(settings_button, CyberConstants.BASE_FONT_TITLE)
	settings_button.pressed.connect(_on_settings_pressed)
	if not Engine.is_editor_hint():
		CyberUI.wire_button_sound(settings_button, GameAudio.play_ui_click, "header_settings")

func set_title(text: String) -> void:
	title_label.text = text

func _on_settings_pressed() -> void:
	settings_pressed.emit()
