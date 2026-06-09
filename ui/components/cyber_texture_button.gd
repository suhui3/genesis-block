@tool
extends TextureButton

const DESIGN_WIDTH := 720.0

func _ready() -> void:
	_configure()
	_apply_fixed_size()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_fixed_size()

func _configure() -> void:
	stretch_mode = STRETCH_SCALE
	ignore_texture_size = true
	focus_mode = FOCUS_NONE
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if texture_hover == null:
		texture_hover = texture_normal
	if texture_pressed == null:
		texture_pressed = texture_normal

func _apply_fixed_size() -> void:
	if texture_normal == null:
		return
	var tex_size := texture_normal.get_size()
	var scale := _get_ui_scale()
	custom_minimum_size = Vector2(tex_size.x * scale, tex_size.y * scale)

func _get_ui_scale() -> float:
	if Engine.is_editor_hint():
		return 1.0
	var viewport_width := get_viewport_rect().size.x
	if viewport_width <= 0.0:
		viewport_width = DESIGN_WIDTH
	return viewport_width / DESIGN_WIDTH
