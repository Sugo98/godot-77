class_name Enemy extends Node2D

@export var data: EnemyData
@export var hp_label: Label
@export var attack_label: Label
@export var sprite2D: Sprite2D

var dice_slot : DiceSlot
var hp : int
var turn_atk: int

func init(d: EnemyData) -> void:
	data = d

func _ready():
	if not data:
		return
	sprite2D.texture = data.texture
	hp = data.max_hp
	update_label()

func reset_stats():
	turn_atk = data.attack

func update_label():
	hp_label.text = "HP: " + str(hp) + "/" + str(data.max_hp)
	attack_label.text = "ATK: " + str(data.attack)

func inflict_damage(damage) -> bool:
	#return true if the enemy is killed
	hp -= damage
	update_label()
	if hp <= 0:
		return true
	return false

func inflict_area_damage(damage) -> bool:
	hp -= damage
	update_label()
	if hp <= 0:
		return true
	return false

func freeze():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite2D, "modulate:a",0.3,0.3)
	tween.tween_property(sprite2D, "modulate:a",1,0.3)

func smoke(x:int):
	var tween = get_tree().create_tween()
	tween.tween_property(sprite2D, "modulate",Color.DIM_GRAY,0.3)
	tween.tween_property(sprite2D, "modulate",Color.WHITE,0.3)
	turn_atk -= x
