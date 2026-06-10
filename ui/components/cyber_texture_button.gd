@tool
extends TextureButton

const DESIGN_WIDTH := 720.0

const MODULATE_NORMAL := Color(1, 1, 1, 1)
const MODULATE_HOVER := Color(1.14, 1.14, 1.2, 1)
const MODULATE_PRESSED := Color(0.22, 1.0, 1.0, 1)

func _ready() -> void:
	_configure()
	_apply_fixed_size()
	if not Engine.is_editor_hint():
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		button_down.connect(_on_button_down)
		button_up.connect(_on_button_up)

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

func _on_mouse_entered() -> void:
	if disabled:
		return
	modulate = MODULATE_HOVER

func _on_mouse_exited() -> void:
	modulate = MODULATE_NORMAL

func _on_button_down() -> void:
	if disabled:
		return
	modulate = MODULATE_PRESSED

func _on_button_up() -> void:
	if disabled:
		modulate = MODULATE_NORMAL
		return
	var hovered := get_global_rect().has_point(get_global_mouse_position())
	modulate = MODULATE_HOVER if hovered else MODULATE_NORMAL
