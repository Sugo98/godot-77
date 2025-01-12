class_name HeroesManager extends Node

@export var max_health : int
@export var max_food : int
@export var max_wood : int
@export var heroes_ui: HeroesUI


var health : int
var food : int
var wood : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	maximize_variables()

func maximize_variables():
	health = max_health
	food = max_food
	update_all_labels()

func update_all_labels():
	heroes_ui.update_food(food)
	heroes_ui.update_health(health)
	heroes_ui.update_wood(wood)

func eat(x : int):
	food -= x
	if food < 0 :
		print("game over")
	heroes_ui.update_food(food)

func increase_food(x):
	food = clamp(food+x, 0, max_food)
	heroes_ui.update_food(food)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
