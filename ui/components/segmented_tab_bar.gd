extends PanelContainer

const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberUI = preload("res://ui/theme/cyber_ui.gd")

signal tab_selected(tab_index: int)

@onready var segments_row: HBoxContainer = $SegmentsRow

var _labels: PackedStringArray = []
var _active_tab: int = 0
var _buttons: Array[Button] = []

func _ready() -> void:
	custom_minimum_size.y = CyberUI.touch_height(CyberConstants.BASE_BUTTON_HEIGHT)
	add_theme_stylebox_override(
		"panel",
		CyberUI.outline_panel(CyberConstants.MAGENTA, CyberConstants.BG_DARK, 1),
	)
	segments_row.add_theme_constant_override("separation", 0)

func configure(labels: PackedStringArray, initial_tab: int = 0) -> void:
	_labels = labels
	_active_tab = clampi(initial_tab, 0, maxi(labels.size() - 1, 0))
	_rebuild_segments()

func set_active_tab(tab_index: int) -> void:
	if tab_index < 0 or tab_index >= _buttons.size():
		return
	_active_tab = tab_index
	_refresh_styles()

func set_blocked(blocked: bool) -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP if blocked else Control.MOUSE_FILTER_PASS
	for button in _buttons:
		button.disabled = blocked

func _rebuild_segments() -> void:
	for child in segments_row.get_children():
		child.queue_free()
	_buttons.clear()
	for i in _labels.size():
		if i > 0:
			segments_row.add_child(_make_divider())
		var button := Button.new()
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.text = _labels[i]
		button.pressed.connect(_on_segment_pressed.bind(i))
		CyberUI.apply_button_font(button, CyberConstants.BASE_FONT_TAB, true)
		segments_row.add_child(button)
		_buttons.append(button)
	_refresh_styles()

func _make_divider() -> Control:
	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(CyberUI.scaled(1), 0)
	divider.size_flags_vertical = Control.SIZE_EXPAND_FILL
	divider.color = CyberConstants.MAGENTA
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return divider

func _refresh_styles() -> void:
	for i in _buttons.size():
		_style_segment(_buttons[i], i == _active_tab)

func _style_segment(button: Button, active: bool) -> void:
	var box := StyleBoxFlat.new()
	if active:
		box.bg_color = Color(0.55, 0.0, 0.45, 0.85)
		box.border_color = CyberConstants.CYAN
		box.set_border_width_all(2)
	else:
		box.bg_color = Color(0, 0, 0, 0)
		box.border_color = Color(0, 0, 0, 0)
	button.add_theme_stylebox_override("normal", box)
	button.add_theme_stylebox_override("hover", box.duplicate())
	button.add_theme_stylebox_override("pressed", box.duplicate())
	button.add_theme_stylebox_override("disabled", box.duplicate())
	button.add_theme_color_override(
		"font_color",
		CyberConstants.CYAN if active else CyberConstants.TEXT_WHITE,
	)
	button.add_theme_color_override("font_disabled_color", CyberConstants.TEXT_DIM)

func _on_segment_pressed(tab_index: int) -> void:
	if tab_index == _active_tab:
		return
	set_active_tab(tab_index)
	tab_selected.emit(tab_index)
