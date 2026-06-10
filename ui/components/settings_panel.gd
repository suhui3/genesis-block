extends Control

signal closed
signal replay_tutorial_requested
signal quit_to_menu_requested
signal reset_game_requested

const CyberConstants = preload("res://ui/theme/cyber_constants.gd")
const CyberUI = preload("res://ui/theme/cyber_ui.gd")

@onready var background: ColorRect = $Background
@onready var settings_border: PanelContainer = $SettingsBorder
@onready var close_button: Button = $SettingsBorder/SettingsVBox/HeaderRow/CloseButton
@onready var volume_slider: HSlider = $SettingsBorder/SettingsVBox/VolumeSection/VolumeSlider
@onready var volume_value_label: Label = $SettingsBorder/SettingsVBox/VolumeSection/VolumeValueLabel
@onready var replay_button: Button = $SettingsBorder/SettingsVBox/ReplayButton
@onready var quit_button: Button = $SettingsBorder/SettingsVBox/QuitButton
@onready var reset_button: Button = $SettingsBorder/SettingsVBox/ResetButton
@onready var reset_confirm_panel: PanelContainer = $SettingsBorder/SettingsVBox/ResetConfirmPanel
@onready var reset_confirm_label: Label = $SettingsBorder/SettingsVBox/ResetConfirmPanel/ResetConfirmVBox/ResetConfirmLabel
@onready var reset_confirm_button: Button = $SettingsBorder/SettingsVBox/ResetConfirmPanel/ResetConfirmVBox/ResetConfirmActions/ResetConfirmButton
@onready var reset_cancel_button: Button = $SettingsBorder/SettingsVBox/ResetConfirmPanel/ResetConfirmVBox/ResetConfirmActions/ResetCancelButton

func _ready() -> void:
	visible = false
	background.color = Color(0.0392157, 0.054902, 0.101961, 0.96)
	background.gui_input.connect(_on_background_gui_input)
	settings_border.add_theme_stylebox_override(
		"panel",
		CyberUI.outline_panel(CyberConstants.CYAN, CyberConstants.BG_DARK, 2),
	)
	reset_confirm_panel.add_theme_stylebox_override(
		"panel",
		CyberUI.outline_panel(CyberConstants.MAGENTA, CyberConstants.BG_PANEL, 1),
	)
	CyberUI.apply_title(
		$SettingsBorder/SettingsVBox/HeaderRow/TitleLabel,
		CyberConstants.CYAN,
		CyberConstants.BASE_FONT_TITLE,
	)
	CyberUI.apply_body(
		$SettingsBorder/SettingsVBox/VolumeSection/VolumeLabel,
		CyberConstants.TEXT_WHITE,
		CyberConstants.BASE_FONT_BODY,
	)
	CyberUI.apply_body(volume_value_label, CyberConstants.TEXT_GRAY, CyberConstants.BASE_FONT_SMALL)
	CyberUI.apply_body(reset_confirm_label, CyberConstants.TEXT_WHITE, CyberConstants.BASE_FONT_BODY)
	CyberUI.set_separation($SettingsBorder/SettingsVBox, CyberConstants.BASE_SEP_SECTION)
	CyberUI.set_separation($SettingsBorder/SettingsVBox/ResetConfirmPanel/ResetConfirmVBox, CyberConstants.BASE_SEP_COMPACT)
	CyberUI.set_separation(
		$SettingsBorder/SettingsVBox/ResetConfirmPanel/ResetConfirmVBox/ResetConfirmActions,
		CyberConstants.BASE_SEP_COMPACT,
	)
	_style_action_button(close_button, CyberConstants.TEXT_GRAY, "X", CyberConstants.BASE_FONT_BODY)
	_style_action_button(replay_button, CyberConstants.CYAN, "REPLAY TUTORIAL")
	_style_action_button(quit_button, CyberConstants.CYAN, "QUIT TO MAIN MENU")
	_style_action_button(reset_button, CyberConstants.MAGENTA, "RESET GAME")
	_style_action_button(reset_confirm_button, CyberConstants.MAGENTA, "CONFIRM RESET", CyberConstants.BASE_FONT_SMALL, true)
	_style_action_button(reset_cancel_button, CyberConstants.TEXT_GRAY, "CANCEL", CyberConstants.BASE_FONT_SMALL, true)
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.05
	volume_slider.value_changed.connect(_on_volume_changed)
	close_button.pressed.connect(_on_close_pressed)
	replay_button.pressed.connect(_on_replay_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	reset_confirm_button.pressed.connect(_on_reset_confirm_pressed)
	reset_cancel_button.pressed.connect(_on_reset_cancel_pressed)
	CyberUI.wire_button_sound(close_button, GameAudio.play_ui_click, "settings_close")
	CyberUI.wire_button_sound(replay_button, GameAudio.play_ui_click, "settings_replay")
	CyberUI.wire_button_sound(quit_button, GameAudio.play_ui_click, "settings_quit")
	CyberUI.wire_button_sound(reset_button, GameAudio.play_ui_click, "settings_reset")
	CyberUI.wire_button_sound(reset_confirm_button, GameAudio.play_ui_click, "settings_reset_confirm")
	CyberUI.wire_button_sound(reset_cancel_button, GameAudio.play_ui_click, "settings_reset_cancel")

func show_settings() -> void:
	_reset_confirm_visible(false)
	volume_slider.value = GameSettings.master_volume
	_update_volume_label(GameSettings.master_volume)
	visible = true

func hide_settings() -> void:
	_reset_confirm_visible(false)
	visible = false
	closed.emit()

func _style_action_button(
	button: Button,
	accent: Color,
	text: String,
	base_font: int = CyberConstants.BASE_FONT_SMALL,
	bold: bool = false,
) -> void:
	button.text = text
	button.custom_minimum_size.y = CyberUI.touch_height(CyberConstants.BASE_BUTTON_HEIGHT)
	CyberUI.apply_button_states(button, accent, true)
	CyberUI.apply_button_font(button, base_font, bold)

func _reset_confirm_visible(show_confirm: bool) -> void:
	reset_confirm_panel.visible = show_confirm
	reset_button.visible = not show_confirm

func _update_volume_label(linear: float) -> void:
	volume_value_label.text = "%d%%" % int(round(linear * 100.0))

func _on_volume_changed(value: float) -> void:
	GameSettings.set_master_volume(value)
	_update_volume_label(value)

func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_settings()

func _on_close_pressed() -> void:
	hide_settings()

func _on_replay_pressed() -> void:
	visible = false
	replay_tutorial_requested.emit()

func _on_quit_pressed() -> void:
	visible = false
	quit_to_menu_requested.emit()

func _on_reset_pressed() -> void:
	_reset_confirm_visible(true)

func _on_reset_cancel_pressed() -> void:
	_reset_confirm_visible(false)

func _on_reset_confirm_pressed() -> void:
	visible = false
	reset_game_requested.emit()
