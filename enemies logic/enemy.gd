class_name Enemy extends Node2D

@export var data: EnemyData
@export var hp_label: Label
@export var attack_label: Label
@export var sprite2D: Sprite2D

@export var attack_animation_x : int = 75

var dice_slots : Array[DiceSlot]
var hp : int
var turn_atk: int
var stun: bool
var shield : int
var is_alive: bool = true

func init(d: EnemyData) -> void:
	data = d

func _ready():
	if not data:
		return
	sprite2D.texture = data.texture
	hp = data.max_hp
	update_label()
	eneter_animation()

func reset_stats():
	turn_atk = data.attack
	shield = data.shield
	stun = false

func update_label():
	hp_label.text = "HP: " + str(hp) + "/" + str(data.max_hp)
	attack_label.text = "ATK: " + str(data.attack)

func inflict_damage(damage) -> bool: #return true if the enemy is killed
	while( shield and damage):
		shield -= 1
		damage -= 1
	red_flash()
	hp -= damage
	update_label()
	if hp <= 0:
		return true
	return false

func inflict_area_damage(damage) -> bool: #return true if the enemy is killed
	red_flash()
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

func kill() -> void :
	var tween = get_tree().create_tween()
	tween.tween_property(sprite2D, "modulate:a", 0 ,1)
	await tween.finished
	for slot in dice_slots:
		slot.hide()
	queue_free()

func attack() -> int:
	var tween = get_tree().create_tween()
	tween.tween_property(sprite2D, "position:x", -attack_animation_x ,0.1)
	tween.tween_property(sprite2D, "position:x", 0 ,0.1)
	return turn_atk

func red_flash() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(sprite2D, "modulate", Color.RED ,0.1)
	tween.tween_property(sprite2D, "modulate", Color.WHITE ,0.1)

func eneter_animation() -> void:
	sprite2D.position.x = 50
	sprite2D.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(sprite2D, "position:x", 0 ,0.1)
	tween.parallel().tween_property(sprite2D, "modulate:a", 1 ,0.15)
	
