class_name MainMenu extends Control

var game_manager : GameManager

@onready var game_menu: VBoxContainer = $"Game Menu"
@onready var settings_menu: VBoxContainer = $"Settings Menu"
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var master_bus
var music_bus
var sfx_bus


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	master_bus = AudioServer.get_bus_index("Master")
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")
	prepare_menu()

func prepare_menu() :
	settings_menu.hide()
	audio_stream_player.play()

func _on_start_game_pressed() -> void:
	game_manager.start_game()
	audio_stream_player.stop()
	

func open_settings() -> void:
	settings_menu.show()
	%MasterSlider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
	%MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	%SFXSlider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		sfx_bus,
		linear_to_db(value)
	)

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		music_bus,
		linear_to_db(value)
	)

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		master_bus,
		linear_to_db(value)
	)


func _on_close_pressed() -> void:
	settings_menu.hide()


func _on_reset_pressed() -> void:
	%MasterSlider.value = 1
	%MusicSlider.value = 1
	%SFXSlider.value = 1


func _on_debug_pressed() -> void:
	$AudioStreamPlayer2.play()
