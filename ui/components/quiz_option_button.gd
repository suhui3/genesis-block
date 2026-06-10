extends Button

const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberUI = preload("res://ui/theme/cyber_ui.gd")

@onready var hbox: HBoxContainer = $HBox
@onready var number_box: PanelContainer = $HBox/NumberBox
@onready var number_label: Label = $HBox/NumberBox/NumberLabel
@onready var answer_label: Label = $HBox/AnswerLabel

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(0, CyberUI.touch_height(CyberConstants.BASE_QUIZ_OPTION_HEIGHT))
	CyberUI.set_separation(hbox, CyberConstants.BASE_SEP_CHROME)
	number_box.custom_minimum_size = CyberUI.scaled_vec2(
		Vector2(CyberConstants.BASE_QUIZ_NUMBER_BOX, CyberConstants.BASE_QUIZ_NUMBER_BOX)
	)
	_apply_style()
	number_box.add_theme_stylebox_override("panel", CyberUI.header_bar())
	CyberUI.apply_title(number_label, CyberConstants.TEXT_WHITE, CyberConstants.BASE_FONT_BODY)
	number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	CyberUI.apply_body(answer_label, CyberConstants.TEXT_WHITE, CyberConstants.BASE_FONT_BODY)
	answer_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	answer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

func configure(index: int, text: String, badge: String = "") -> void:
	number_label.text = badge if not badge.is_empty() else str(index + 1)
	answer_label.text = text

func _apply_style() -> void:
	var box := CyberUI.flat_button(CyberConstants.CYAN)
	add_theme_stylebox_override("normal", box)
	add_theme_stylebox_override("hover", box)
	add_theme_stylebox_override("pressed", box)
