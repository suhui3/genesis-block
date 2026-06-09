extends PanelContainer

const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberUI = preload("res://ui/theme/cyber_ui.gd")

@onready var hbox: HBoxContainer = $HBox
@onready var amount_label: Label = $HBox/AmountLabel

func _ready() -> void:
	custom_minimum_size.y = CyberUI.scaled(CyberConstants.BASE_GAS_BAR_HEIGHT)
	add_theme_stylebox_override("panel", CyberUI.outline_panel(CyberConstants.MAGENTA))
	CyberUI.set_separation(hbox, CyberConstants.BASE_SEP_CHROME)
	_setup_icon()
	var caption := $HBox/CaptionLabel as Label
	CyberUI.apply_body(caption, CyberConstants.TEXT_WHITE, CyberConstants.BASE_FONT_SMALL)
	caption.text = "AVAILABLE GAS"
	CyberUI.apply_title(amount_label, CyberConstants.CYAN, CyberConstants.BASE_FONT_GAS_AMOUNT)
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	amount_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _setup_icon() -> void:
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = CyberUI.scaled_vec2(
		Vector2(CyberConstants.BASE_ICON_GAS, CyberConstants.BASE_ICON_GAS)
	)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var texture := _load_gas_icon()
	if texture:
		icon.texture = texture
		icon.modulate = CyberConstants.CYAN
	else:
		icon.visible = false
	hbox.add_child(icon)
	hbox.move_child(icon, 0)

func _load_gas_icon() -> Texture2D:
	if not ResourceLoader.exists(CyberConstants.GAS_ICON_PATH):
		return null
	return load(CyberConstants.GAS_ICON_PATH) as Texture2D

func set_gas(amount: float) -> void:
	amount_label.text = CyberUI.format_gas(amount)
