class_name GameManager extends Node

@export var main_menu_scene : PackedScene
@export var level_scene : PackedScene
@export var merchant_scene : PackedScene
@export var heroes_manager_scene : PackedScene

@export var main_canvas : CanvasLayer

var active_level : LevelLogic
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
	heroes_manager = heroes_manager_scene.instantiate()
	main_menu = main_menu_scene.instantiate()
	load_menu()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func load_menu() -> void:
	main_menu.game_manager = self
	main_canvas.add_child(main_menu)

func start_game() -> void:
	main_canvas.remove_child(main_menu)
	main_canvas.add_child(heroes_manager)
	#load_level( load( "res://resources/levels/plain.tres" ))
	load_merchant( load("res://resources/merchant/base.tres"))

func load_level(data : LevelData) -> void:
	var level : LevelLogic = level_scene.instantiate()
	level.init(data)
	level.heroes_manager = heroes_manager
	level.game_manager = self
	main_canvas.add_child(level)
	heroes_manager.prepare_for_level()

func go_to_next_level():
	pass

func load_merchant(data : MerchantData) -> void:
	var merchant : Merchant = merchant_scene.instantiate()
	merchant.init(data)
	merchant.heroes_manager = heroes_manager
	merchant.game_manager = self
	main_canvas.add_child(merchant)
	heroes_manager.prepare_for_merchant()
	
