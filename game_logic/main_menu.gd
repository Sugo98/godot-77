class_name MainMenu extends Control

var game_manager : GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_start_game_pressed() -> void:
	game_manager.start_game()
