class_name Enemy extends Node2D

@export var data: EnemyData
@export var hp_label: Label
@export var attack_label: Label
@export var sprite2D: Sprite2D

var hp : int

func init(d: EnemyData) -> void:
	data = d

func _ready():
	if not data:
		return
	sprite2D.texture = data.texture
	hp = data.max_hp
	update_label()

func update_label():
	hp_label.text = "HP: " + str(hp) + "/" + str(data.max_hp)
	attack_label.text = "ATK: " + str(data.attack)
