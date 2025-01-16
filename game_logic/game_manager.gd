class_name GameManager extends Node

@export var main_menu_scene : PackedScene
@export var level_scene : PackedScene
@export var merchant_scene : PackedScene
@export var heroes_manager_scene : PackedScene
@export var main_canvas : CanvasLayer

@export var journey_data : Journey
var journey_stops : Array[Resource]

var actual_stop : Node
var heroes_manager : HeroesManager

var main_menu : MainMenu 

func check_warnings():
	var warnings : Array = []
	if not main_menu_scene:
		warnings.append("Menu Scene not set")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Utils.main_canvas = main_canvas
	check_warnings()
	main_menu = main_menu_scene.instantiate()
	main_menu.game_manager = self
	main_canvas.add_child(main_menu)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func load_menu() -> void:
	main_menu.prepare_main_menu()

func start_new_game() -> void:
	heroes_manager = heroes_manager_scene.instantiate()
	main_canvas.add_child(heroes_manager)
	main_canvas.move_child(heroes_manager,0)
	journey_stops = journey_data.stops.duplicate()
	go_to_next_level()

func go_to_next_level():
	if actual_stop:
		actual_stop.queue_free()
	var next_stop = journey_stops.front()
	if next_stop is LevelData:
		load_level(next_stop)
	if next_stop is MerchantData:
		load_merchant(next_stop)
	journey_stops.pop_front()

func load_level(data : LevelData) -> void:
	var level : LevelLogic = level_scene.instantiate()
	level.init(data)
	level.heroes_manager = heroes_manager
	level.game_manager = self
	actual_stop = level
	main_canvas.add_child(level)
	main_canvas.move_child(level, 1)
	heroes_manager.prepare_for_level()
	main_menu.pause_button.show()

func load_merchant(data : MerchantData) -> void:
	var merchant : Merchant = merchant_scene.instantiate()
	merchant.init(data)
	merchant.heroes_manager = heroes_manager
	merchant.game_manager = self
	actual_stop = merchant
	main_canvas.add_child(merchant)
	main_canvas.move_child(heroes_manager,-1)
	heroes_manager.prepare_for_merchant()
	main_menu.pause_button.hide()
	
func quit_game():
	actual_stop.queue_free()
	actual_stop = null
	heroes_manager.queue_free()
	load_menu()
