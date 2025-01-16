class_name HeroesUI extends Control

@export var max_health : int = 10
@export var max_food : int = 20

@export var health_bar: ProgressBar
@export var health_label : Label
@export var food_bar: ProgressBar
@export var food_label : Label
@export var wood_label: Label
@export var xp_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.max_value = max_health
	food_bar.max_value = max_food

func update_health(x:int):
	health_bar.value = x
	health_label.text = tr("HEALTH_BAR_LABEL") + ": " + str(x) # + "/" + str(max_health)

func update_food(x:int):
	food_bar.value = x
	food_label.text = tr("FOOD_BAR_LABEL") + ": " + str(x) # + "/" + str(max_food)

func update_wood(x:int):
	wood_label.text = str(x)

func update_xp(x:int):
	xp_label.text = str(x)
