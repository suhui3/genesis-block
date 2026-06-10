extends RefCounted

const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberFonts = preload("res://ui/theme/cyber_fonts.gd")

static func scaled(value: float) -> int:
	return int(round(value * CyberConstants.UI_SCALE))

static func scaled_f(value: float) -> float:
	return value * CyberConstants.UI_SCALE

static func scaled_vec2(value: Vector2) -> Vector2:
	return Vector2(scaled(value.x), scaled(value.y))

static func touch_height(base_height: float) -> int:
	return maxi(scaled(base_height), scaled(CyberConstants.BASE_BUTTON_HEIGHT))

static func outline_panel(border: Color, bg: Color = CyberConstants.BG_PANEL, width: int = 2) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(width)
	box.set_content_margin_all(scaled(CyberConstants.BASE_PANEL_PADDING))
	return box

static func flat_button(normal_border: Color, _pressed_bg: Color = Color(0.08, 0.1, 0.16, 1.0)) -> StyleBoxFlat:
	return button_state_styleboxes(normal_border)["normal"]

static func _flat_stylebox(border: Color, bg: Color, border_width: int = 2) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_content_margin_all(scaled(CyberConstants.BASE_PANEL_PADDING_SM))
	box.draw_center = true
	return box

static func pressed_text_color() -> Color:
	return CyberConstants.BG_DARK

static func button_state_styleboxes(accent: Color, enabled: bool = true) -> Dictionary:
	var border := accent if enabled else CyberConstants.TEXT_DIM
	var hover_border := border.lightened(0.18) if enabled else CyberConstants.TEXT_DIM
	var pressed_bg := accent if enabled else CyberConstants.TEXT_DIM.darkened(0.2)
	return {
		"normal": _flat_stylebox(border, CyberConstants.BG_PANEL),
		"hover": _flat_stylebox(hover_border, Color(0.10, 0.14, 0.22, 1.0)),
		"pressed": _flat_stylebox(CyberConstants.BG_DARK, pressed_bg),
		"disabled": _flat_stylebox(
			CyberConstants.TEXT_DIM.darkened(0.15),
			Color(0.04, 0.05, 0.08, 0.85),
		),
	}

static func apply_button_states(
	button: Button,
	accent: Color,
	enabled: bool = true,
	normal_font: Variant = null,
) -> void:
	var states := button_state_styleboxes(accent, enabled)
	for state_name in states:
		button.add_theme_stylebox_override(state_name, states[state_name])
	var font: Color = normal_font if normal_font is Color else (accent if enabled else CyberConstants.TEXT_DIM)
	button.add_theme_color_override("font_color", font)
	button.add_theme_color_override("font_hover_color", font.lightened(0.12) if enabled else font)
	button.add_theme_color_override(
		"font_pressed_color",
		pressed_text_color() if enabled else CyberConstants.TEXT_DIM,
	)
	button.add_theme_color_override("font_disabled_color", CyberConstants.TEXT_DIM)

static func _tab_stylebox(border: Color, bg: Color, border_width: int = 2) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_width)
	box.draw_center = true
	return box

static func tab_button_state_styleboxes(active: bool) -> Dictionary:
	if active:
		return {
			"normal": _tab_stylebox(CyberConstants.CYAN, Color(0.55, 0.0, 0.45, 0.85)),
			"hover": _tab_stylebox(
				CyberConstants.CYAN.lightened(0.15),
				Color(0.62, 0.05, 0.50, 0.92),
			),
			"pressed": _tab_stylebox(CyberConstants.BG_DARK, CyberConstants.CYAN),
		}
	var transparent := Color(0, 0, 0, 0)
	return {
		"normal": _tab_stylebox(transparent, transparent, 0),
		"hover": _tab_stylebox(CyberConstants.CYAN, Color(0.10, 0.08, 0.16, 0.55), 1),
		"pressed": _tab_stylebox(CyberConstants.BG_DARK, CyberConstants.CYAN),
	}

static func apply_tab_button_states(button: Button, active: bool) -> void:
	var states := tab_button_state_styleboxes(active)
	for state_name in states:
		button.add_theme_stylebox_override(state_name, states[state_name])
	var font := CyberConstants.CYAN if active else CyberConstants.TEXT_WHITE
	button.add_theme_color_override("font_color", font)
	button.add_theme_color_override("font_hover_color", font.lightened(0.12))
	button.add_theme_color_override("font_pressed_color", pressed_text_color())

static func header_bar(bg: Color = CyberConstants.HEADER_MAGENTA) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.set_content_margin_all(scaled(CyberConstants.BASE_PANEL_PADDING_SM))
	return box

static func scaled_font(base_font_size: int) -> int:
	return int(round(base_font_size * CyberConstants.UI_SCALE * CyberConstants.FONT_SCALE))

static func apply_font(control: Control, font: Font, base_font_size: int) -> void:
	control.add_theme_font_override("font", font)
	control.add_theme_font_size_override("font_size", scaled_font(base_font_size))

static func apply_title(label: Label, color: Color, base_font_size: int = CyberConstants.BASE_FONT_SCREEN_TITLE) -> void:
	label.add_theme_color_override("font_color", color)
	apply_font(label, CyberFonts.BOLD, base_font_size)

static func apply_body(label: Label, color: Color = CyberConstants.TEXT_GRAY, base_font_size: int = CyberConstants.BASE_FONT_BODY) -> void:
	label.add_theme_color_override("font_color", color)
	apply_font(label, CyberFonts.REGULAR, base_font_size)

static func apply_italic(label: Label, color: Color, base_font_size: int = CyberConstants.BASE_FONT_SMALL) -> void:
	label.add_theme_color_override("font_color", color)
	apply_font(label, CyberFonts.ITALIC, base_font_size)

static func apply_button_font(button: Button, base_font_size: int = CyberConstants.BASE_FONT_SMALL, bold: bool = false) -> void:
	apply_font(button, CyberFonts.BOLD if bold else CyberFonts.REGULAR, base_font_size)

static func apply_label_glow(label: Label, color: Color, base_font_size: int = CyberConstants.BASE_FONT_SCREEN_TITLE) -> void:
	apply_title(label, color, base_font_size)

static func apply_mono_label(label: Label, color: Color = CyberConstants.TEXT_GRAY, base_font_size: int = CyberConstants.BASE_FONT_BODY) -> void:
	apply_body(label, color, base_font_size)

static func set_separation(container: BoxContainer, base_separation: int) -> void:
	container.add_theme_constant_override("separation", scaled(base_separation))

static func format_gas(amount: float) -> String:
	return "%s" % int(amount)
