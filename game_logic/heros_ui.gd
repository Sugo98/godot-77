class_name HeroesUI extends Control

@export var max_health : int = 10
@export var max_food : int = 20

@onready var health_label: Label = $Health
@onready var food_label: Label = $Food
@onready var wood_label: Label = $Wood
@onready var xp_label: Label = $XP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func update_health(x:int):
	health_label.text = "HP: " + str(x) + "/" + str(max_health)

func update_food(x:int):
	food_label.text = "Food: " + str(x) + "/" + str(max_food)

func update_wood(x:int):
	wood_label.text = "Wood: " + str(x)

func update_xp(x:int):
	xp_label.text = "XP: " + str(x)
