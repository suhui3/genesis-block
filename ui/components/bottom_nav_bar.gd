extends PanelContainer

const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberUI = preload("res://ui/theme/cyber_ui.gd")

signal tab_selected(tab_index: int)

const TAB_COUNT := 4

var _active_tab: int = CyberConstants.TAB_MINING
var _tab_entries: Array[Dictionary] = []

@onready var tabs_row: HBoxContainer = $TabsRow

func _ready() -> void:
	custom_minimum_size.y = CyberUI.scaled(CyberConstants.BASE_NAV_HEIGHT)
	add_theme_stylebox_override("panel", CyberUI.outline_panel(CyberConstants.CYAN, CyberConstants.BG_DARK, 1))
	tabs_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs_row.add_theme_constant_override("separation", 0)
	_build_tabs()

func _build_tabs() -> void:
	for i in TAB_COUNT:
		var btn := Button.new()
		btn.flat = true
		btn.focus_mode = Control.FOCUS_NONE
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, CyberUI.touch_height(CyberConstants.BASE_NAV_BUTTON_HEIGHT))
		btn.pressed.connect(_on_tab_pressed.bind(i))
		btn.button_down.connect(_on_tab_press_state.bind(i, true))
		btn.button_up.connect(_on_tab_press_state.bind(i, false))

		var content := VBoxContainer.new()
		content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		content.alignment = BoxContainer.ALIGNMENT_CENTER
		CyberUI.set_separation(content, CyberConstants.BASE_SEP_TIGHT)
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var icon := TextureRect.new()
		icon.custom_minimum_size = CyberUI.scaled_vec2(
			Vector2(CyberConstants.BASE_ICON_NAV, CyberConstants.BASE_ICON_NAV)
		)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var texture := _load_tab_icon(i)
		if texture:
			icon.texture = texture
		else:
			icon.visible = false

		var label := Label.new()
		label.text = CyberConstants.TAB_TITLES[i]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		CyberUI.apply_title(label, CyberConstants.TEXT_WHITE, CyberConstants.BASE_FONT_TAB)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE

		content.add_child(icon)
		content.add_child(label)
		btn.add_child(content)
		tabs_row.add_child(btn)
		_tab_entries.append({"button": btn, "icon": icon, "label": label})

	set_active_tab(_active_tab)

func _load_tab_icon(index: int) -> Texture2D:
	var path: String = CyberConstants.TAB_ICON_PATHS[index]
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D

func set_active_tab(tab_index: int) -> void:
	_active_tab = tab_index
	for i in _tab_entries.size():
		_style_tab(_tab_entries[i], i == tab_index)

func _style_tab(entry: Dictionary, active: bool) -> void:
	CyberUI.apply_tab_button_states(entry.button, active)
	_apply_tab_content_colors(entry, active, false)

func _apply_tab_content_colors(entry: Dictionary, active: bool, pressed: bool) -> void:
	var icon: TextureRect = entry.icon
	var label: Label = entry.label
	var accent := CyberConstants.CYAN if active else CyberConstants.TEXT_WHITE
	var color := CyberUI.pressed_text_color() if pressed else accent
	CyberUI.apply_title(label, color, CyberConstants.BASE_FONT_TAB)
	if icon.texture:
		icon.modulate = color
		icon.visible = true

func _on_tab_press_state(tab_index: int, pressed: bool) -> void:
	if tab_index < 0 or tab_index >= _tab_entries.size():
		return
	var entry: Dictionary = _tab_entries[tab_index]
	if entry.button.disabled:
		return
	_apply_tab_content_colors(entry, tab_index == _active_tab, pressed)

func _on_tab_pressed(tab_index: int) -> void:
	set_active_tab(tab_index)
	tab_selected.emit(tab_index)
