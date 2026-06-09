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

static func flat_button(normal_border: Color, pressed_bg: Color = Color(0.08, 0.1, 0.16, 1.0)) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = CyberConstants.BG_PANEL
	box.border_color = normal_border
	box.set_border_width_all(2)
	box.set_content_margin_all(scaled(CyberConstants.BASE_PANEL_PADDING_SM))
	box.draw_center = true
	return box

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
