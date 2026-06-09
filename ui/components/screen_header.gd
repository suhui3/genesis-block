extends VBoxContainer

const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberUI = preload("res://ui/theme/cyber_ui.gd")

@onready var title_label: Label = $TitleLabel
@onready var underline: ColorRect = $Underline

func _ready() -> void:
	CyberUI.apply_title(title_label, CyberConstants.CYAN, CyberConstants.BASE_FONT_SCREEN_TITLE)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	CyberUI.set_separation(self, CyberConstants.BASE_SEP_HEADER)
	underline.custom_minimum_size = Vector2(0, CyberUI.scaled(CyberConstants.BASE_UNDERLINE))
	underline.color = CyberConstants.MAGENTA

func set_title(text: String) -> void:
	title_label.text = text
