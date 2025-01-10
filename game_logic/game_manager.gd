class_name GameManager extends Node

@export var main_menu_scene : PackedScene

var main_menu

func check_warnings():
	var warnings : Array = []
	if not main_menu_scene:
		warnings.append("Menu Scene not set")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_warnings()
	load_menu()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_menu() -> void:
	main_menu =  main_menu_scene.instantiate()
	add_child(main_menu)

func start_game() -> void:
	main_menu.queue_free()
	print(main_menu)
