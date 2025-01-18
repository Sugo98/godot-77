class_name MainMenu extends Control

var game_manager : GameManager

@export var title : Label
@export var game_menu: PanelContainer
@export var settings_menu: PanelContainer
@export var pause_menu : PanelContainer
@export var pause_button : PanelContainer
@export var music_stream_player: AudioStreamPlayer
@export var sfx_stream : Array[AudioStreamPlayer]
@export var blocker : ColorRect
@export var caravan : Node2D

@onready var animation_buttons = {
	"slow" : %SlowAnimation,
	"medium" : %MediumAnimation,
	"fast" : %FastAnimation
}

var master_bus
var music_bus
var sfx_bus

@export var pause_icon : Array[Texture2D]
var pause : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_mode(PROCESS_MODE_ALWAYS)
	master_bus = AudioServer.get_bus_index("Master")
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")
	prepare_main_menu()
	_on_slow_animation_pressed()
	default_volume()

func default_volume() -> void:
	%MasterSlider.value = 0.5
	%MusicSlider.value = 0.75
	%SFXSlider.value = 0.75

func prepare_main_menu() :
	pause = false
	get_tree().set_pause(pause)
	title.show()
	game_menu.show()
	settings_menu.hide()
	pause_menu.hide()
	pause_button.hide()
	blocker.hide()
	caravan.show()
	caravan.do_the_shake()
	music_stream_player.play()


func prepare_for_game():
	pause = false
	get_tree().set_pause(pause)
	game_menu.hide()
	settings_menu.hide()
	pause_menu.hide()
	caravan.hide()
	pause_button.show()
	%PauseButton.icon = pause_icon[ int(pause) ]
	title.hide()

func _on_start_game_pressed() -> void:
	game_manager.start_new_game()
	prepare_for_game()
	music_stream_player.stop()
	

func open_settings() -> void:
	if settings_menu.visible :
		_on_close_pressed()
		return
	settings_menu.show()
	pause_button.hide()
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
	if pause: pause_button.show()


func _on_reset_pressed() -> void:
	default_volume()
	_on_slow_animation_pressed()

func _on_en_lan_pressed() -> void:
	TranslationServer.set_locale("en")

func _on_it_lan_pressed() -> void:
	TranslationServer.set_locale("it")

func _on_slow_animation_pressed() -> void:
	Utils.basic_wait_time = Global.slow_animation_time
	animation_buttons["slow"].theme_type_variation = "SmallButton"
	animation_buttons["medium"].theme_type_variation = "Inactive"
	animation_buttons["fast"].theme_type_variation = "Inactive"

func _on_medium_animation_pressed() -> void:
	Utils.basic_wait_time = Global.medium_animation_time
	animation_buttons["slow"].theme_type_variation = "Inactive"
	animation_buttons["medium"].theme_type_variation = "SmallButton"
	animation_buttons["fast"].theme_type_variation = "Inactive"


func _on_fast_animation_pressed() -> void:
	Utils.basic_wait_time = Global.fast_animation_time
	animation_buttons["slow"].theme_type_variation = "Inactive"
	animation_buttons["medium"].theme_type_variation = "Inactive"
	animation_buttons["fast"].theme_type_variation = "SmallButton"

func _on_sfx_pressed() -> void:
	sfx_stream[randi_range(0,sfx_stream.size()-1)].play()


func _on_pause_button_pressed() -> void:
	pause_button.show()
	pause = not pause
	get_tree().set_pause(pause)
	%PauseButton.icon = pause_icon[ int(pause) ]
	blocker.set_visible(pause)
	pause_menu.set_visible(pause)


func _on_resume_game_pressed() -> void:
	settings_menu.hide()
	_on_pause_button_pressed()


func _on_quit_game_pressed() -> void:
	game_manager.quit_game()
