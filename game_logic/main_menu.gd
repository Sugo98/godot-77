class_name MainMenu extends Control

var game_manager : GameManager

@export var game_menu: PanelContainer
@export var settings_menu: PanelContainer
@export var music_stream_player: AudioStreamPlayer
@export var sfx_stream_player : AudioStreamPlayer

@onready var animation_buttons = {
	"slow" : %SlowAnimation,
	"medium" : %MediumAnimation,
	"fast" : %FastAnimation
}

var master_bus
var music_bus
var sfx_bus


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	master_bus = AudioServer.get_bus_index("Master")
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")
	prepare_menu()
	_on_slow_animation_pressed()

func prepare_menu() :
	settings_menu.hide()
	music_stream_player.play()

func _on_start_game_pressed() -> void:
	game_manager.start_game()
	music_stream_player.stop()
	

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
	sfx_stream_player.play()
	$AudioStreamPlayer2.play()


func _on_en_lan_pressed() -> void:
	TranslationServer.set_locale("en")


func _on_it_lan_pressed() -> void:
	TranslationServer.set_locale("it")


func _on_slow_animation_pressed() -> void:
	Utils.basic_wait_time = Global.slow_animation_time
	animation_buttons["slow"].theme_type_variation = ""
	animation_buttons["medium"].theme_type_variation = "Inactive"
	animation_buttons["fast"].theme_type_variation = "Inactive"

func _on_medium_animation_pressed() -> void:
	Utils.basic_wait_time = Global.medium_animation_time
	animation_buttons["slow"].theme_type_variation = "Inactive"
	animation_buttons["medium"].theme_type_variation = ""
	animation_buttons["fast"].theme_type_variation = "Inactive"


func _on_fast_animation_pressed() -> void:
	Utils.basic_wait_time = Global.fast_animation_time
	animation_buttons["slow"].theme_type_variation = "Inactive"
	animation_buttons["medium"].theme_type_variation = "Inactive"
	animation_buttons["fast"].theme_type_variation = ""
