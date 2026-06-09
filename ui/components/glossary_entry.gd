extends VBoxContainer

const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberUI = preload("res://ui/theme/cyber_ui.gd")

func _ready() -> void:
	CyberUI.set_separation(self, CyberConstants.BASE_SEP_HEADER)
	$Divider.custom_minimum_size = Vector2(0, 1)
	$Divider.color = CyberConstants.MAGENTA

func configure(term: String, definition: String, use_cyan: bool) -> void:
	$TermLabel.text = term.to_upper()
	CyberUI.apply_title(
		$TermLabel,
		CyberConstants.CYAN if use_cyan else CyberConstants.MAGENTA,
		CyberConstants.BASE_FONT_BODY_LG,
	)
	CyberUI.apply_body($DefinitionLabel, CyberConstants.TEXT_WHITE, CyberConstants.BASE_FONT_SMALL)
	$DefinitionLabel.text = definition
