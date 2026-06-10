extends Node

const SOUND_PATHS := {
	"ui_click": "res://ui/audio/ui_click.mp3",
	"mining_validate_block": "res://ui/audio/mining_validate_block.mp3",
	"upgrade": "res://ui/audio/upgrade.mp3",
	"correct_answer": "res://ui/audio/correct_answer.mp3",
	"wrong_answer": "res://ui/audio/wrong_answer.mp3",
}

var _players: Dictionary = {}

func _ready() -> void:
	for sound_id in SOUND_PATHS:
		var player := AudioStreamPlayer.new()
		player.name = sound_id
		player.bus = "UI"
		add_child(player)
		var path: String = SOUND_PATHS[sound_id]
		if ResourceLoader.exists(path):
			player.stream = load(path)
		_players[sound_id] = player

func play_ui_click() -> void:
	_play("ui_click")

func play_mining_validate() -> void:
	_play("mining_validate_block")

func play_upgrade() -> void:
	_play("upgrade")

func play_correct_answer() -> void:
	_play("correct_answer")

func play_wrong_answer() -> void:
	_play("wrong_answer")

func _play(sound_id: String) -> void:
	var player: AudioStreamPlayer = _players.get(sound_id)
	if player == null or player.stream == null:
		return
	player.stop()
	player.play()
