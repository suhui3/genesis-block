extends Control

signal skipped
signal continued

const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberUI = preload("res://ui/theme/cyber_ui.gd")

const DIM_COLOR := Color(0.02, 0.03, 0.06, 0.78)
const HOLE_PADDING := 8
const RING_PADDING := 4
const TOOLTIP_GAP := 12
const TOOLTIP_MAX_WIDTH := 320

var _target: Control
var _pulse_tween: Tween

@onready var dim_top: ColorRect = $DimTop
@onready var dim_left: ColorRect = $DimLeft
@onready var dim_right: ColorRect = $DimRight
@onready var dim_bottom: ColorRect = $DimBottom
@onready var highlight_ring: PanelContainer = $HighlightRing
@onready var tooltip_panel: PanelContainer = $TooltipPanel
@onready var tooltip_title: Label = $TooltipPanel/TooltipVBox/TooltipTitle
@onready var tooltip_body: Label = $TooltipPanel/TooltipVBox/TooltipBody
@onready var next_button: Button = $TooltipPanel/TooltipVBox/NextButton
@onready var skip_button: Button = $SkipButton

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for dim in [dim_top, dim_left, dim_right, dim_bottom]:
		dim.color = DIM_COLOR
		dim.mouse_filter = Control.MOUSE_FILTER_STOP
	highlight_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	tooltip_panel.add_theme_stylebox_override(
		"panel",
		CyberUI.outline_panel(CyberConstants.CYAN, CyberConstants.BG_DARK, 2),
	)
	CyberUI.apply_title(tooltip_title, CyberConstants.CYAN, CyberConstants.BASE_FONT_BODY_LG)
	CyberUI.apply_body(tooltip_body, CyberConstants.TEXT_GRAY, CyberConstants.BASE_FONT_BODY)
	CyberUI.set_separation(tooltip_panel.get_node("TooltipVBox"), CyberConstants.BASE_SEP_TIGHT)
	skip_button.flat = true
	skip_button.focus_mode = Control.FOCUS_NONE
	CyberUI.apply_button_states(skip_button, CyberConstants.TEXT_DIM, true)
	CyberUI.apply_button_font(skip_button, CyberConstants.BASE_FONT_CAPTION)
	skip_button.text = "Skip"
	skip_button.pressed.connect(_on_skip_pressed)
	next_button.visible = false
	next_button.text = "Next"
	CyberUI.apply_button_states(next_button, CyberConstants.CYAN, true)
	CyberUI.apply_button_font(next_button, CyberConstants.BASE_FONT_SMALL, true)
	next_button.pressed.connect(_on_next_pressed)
	get_viewport().size_changed.connect(_on_viewport_resized)

func show_step(target: Control, title: String, body: String, show_next: bool = false) -> void:
	_target = target
	tooltip_title.text = title
	tooltip_body.text = body
	next_button.visible = show_next
	visible = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	await get_tree().process_frame
	_reposition()
	await get_tree().process_frame
	_reposition()
	_start_pulse()

func hide_overlay() -> void:
	_stop_pulse()
	_target = null
	visible = false

func _on_skip_pressed() -> void:
	skipped.emit()

func _on_next_pressed() -> void:
	continued.emit()

func _on_viewport_resized() -> void:
	if visible and _target:
		_reposition()

func _reposition() -> void:
	if not _target or not is_instance_valid(_target):
		return
	var hole := _get_hole_rect()
	_layout_dim_panels(hole)
	_layout_highlight_ring(hole)
	_layout_tooltip(hole)
	_layout_skip_button()

func _get_hole_rect() -> Rect2:
	var target_rect := _target.get_global_rect()
	var pad := float(CyberUI.scaled(HOLE_PADDING))
	return Rect2(
		target_rect.position - Vector2(pad, pad),
		target_rect.size + Vector2(pad * 2.0, pad * 2.0),
	)

func _layout_dim_panels(hole: Rect2) -> void:
	var overlay_rect := get_global_rect()
	var local_hole := Rect2(hole.position - overlay_rect.position, hole.size)
	dim_top.position = Vector2.ZERO
	dim_top.size = Vector2(overlay_rect.size.x, maxf(0.0, local_hole.position.y))
	dim_left.position = Vector2(0.0, local_hole.position.y)
	dim_left.size = Vector2(
		maxf(0.0, local_hole.position.x),
		local_hole.size.y,
	)
	dim_right.position = Vector2(local_hole.position.x + local_hole.size.x, local_hole.position.y)
	dim_right.size = Vector2(
		maxf(0.0, overlay_rect.size.x - local_hole.position.x - local_hole.size.x),
		local_hole.size.y,
	)
	dim_bottom.position = Vector2(0.0, local_hole.position.y + local_hole.size.y)
	dim_bottom.size = Vector2(
		overlay_rect.size.x,
		maxf(0.0, overlay_rect.size.y - local_hole.position.y - local_hole.size.y),
	)

func _layout_highlight_ring(hole: Rect2) -> void:
	var ring_pad := float(CyberUI.scaled(RING_PADDING))
	var overlay_rect := get_global_rect()
	var local_hole := Rect2(hole.position - overlay_rect.position, hole.size)
	highlight_ring.position = local_hole.position - Vector2(ring_pad, ring_pad)
	highlight_ring.size = local_hole.size + Vector2(ring_pad * 2.0, ring_pad * 2.0)

func _layout_tooltip(hole: Rect2) -> void:
	var overlay_rect := get_global_rect()
	var local_hole := Rect2(hole.position - overlay_rect.position, hole.size)
	var gap := float(CyberUI.scaled(TOOLTIP_GAP))
	var margin := float(CyberUI.scaled(CyberConstants.BASE_MARGIN))
	var max_width := float(CyberUI.scaled(TOOLTIP_MAX_WIDTH))
	tooltip_panel.custom_minimum_size = Vector2(max_width, 0.0)
	tooltip_panel.size = Vector2(max_width, 0.0)
	var tooltip_size := tooltip_panel.get_combined_minimum_size()
	var place_above := local_hole.position.y > overlay_rect.size.y * 0.55
	var x := clampf(
		local_hole.position.x + local_hole.size.x * 0.5 - tooltip_size.x * 0.5,
		margin,
		overlay_rect.size.x - tooltip_size.x - margin,
	)
	var y := local_hole.position.y - tooltip_size.y - gap if place_above else (
		local_hole.position.y + local_hole.size.y + gap
	)
	y = clampf(y, margin, overlay_rect.size.y - tooltip_size.y - margin)
	tooltip_panel.position = Vector2(x, y)
	tooltip_panel.size = tooltip_size

func _layout_skip_button() -> void:
	var margin := float(CyberUI.scaled(CyberConstants.BASE_MARGIN))
	skip_button.position = Vector2(
		size.x - skip_button.size.x - margin,
		margin,
	)

func _start_pulse() -> void:
	_stop_pulse()
	highlight_ring.add_theme_stylebox_override(
		"panel",
		CyberUI.outline_panel(CyberConstants.CYAN, Color(0, 0, 0, 0), 2),
	)
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(
		highlight_ring,
		"modulate",
		Color(1.4, 1.0, 1.4, 1.0),
		0.55,
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(
		highlight_ring,
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		0.55,
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _stop_pulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
		_pulse_tween = null
	highlight_ring.modulate = Color.WHITE
