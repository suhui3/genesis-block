extends Button

const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberUI = preload("res://ui/theme/cyber_ui.gd")

@onready var hbox: HBoxContainer = $HBox
@onready var number_box: PanelContainer = $HBox/NumberBox
@onready var number_label: Label = $HBox/NumberBox/NumberLabel
@onready var answer_label: Label = $HBox/AnswerLabel

var _normal_number_panel: StyleBoxFlat
var _pressed_number_panel: StyleBoxFlat

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(0, CyberUI.touch_height(CyberConstants.BASE_QUIZ_OPTION_HEIGHT))
	CyberUI.set_separation(hbox, CyberConstants.BASE_SEP_CHROME)
	number_box.custom_minimum_size = CyberUI.scaled_vec2(
		Vector2(CyberConstants.BASE_QUIZ_NUMBER_BOX, CyberConstants.BASE_QUIZ_NUMBER_BOX)
	)
	_apply_style()
	_normal_number_panel = CyberUI.header_bar()
	_pressed_number_panel = CyberUI.header_bar(CyberConstants.CYAN)
	number_box.add_theme_stylebox_override("panel", _normal_number_panel)
	_set_label_colors(CyberConstants.TEXT_WHITE)
	number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	answer_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	answer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button_down.connect(_on_press_state_changed.bind(true))
	button_up.connect(_on_press_state_changed.bind(false))

func configure(index: int, text: String, badge: String = "") -> void:
	number_label.text = badge if not badge.is_empty() else str(index + 1)
	answer_label.text = text

func _apply_style() -> void:
	CyberUI.apply_button_states(self, CyberConstants.CYAN, true, CyberConstants.TEXT_WHITE)

func _on_press_state_changed(pressed: bool) -> void:
	if disabled:
		return
	_set_label_colors(CyberUI.pressed_text_color() if pressed else CyberConstants.TEXT_WHITE)
	number_box.add_theme_stylebox_override(
		"panel",
		_pressed_number_panel if pressed else _normal_number_panel,
	)

func _set_label_colors(color: Color) -> void:
	CyberUI.apply_title(number_label, color, CyberConstants.BASE_FONT_BODY)
	CyberUI.apply_body(answer_label, color, CyberConstants.BASE_FONT_BODY)
