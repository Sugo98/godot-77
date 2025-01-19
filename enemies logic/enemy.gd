class_name Enemy extends Node2D

var data: EnemyData
@export var ui : Control
@export var sprite2D: Sprite2D
@export var sounds : Array[AudioStreamPlayer]
@export var stun_animation : Sprite2D

@export var attack_animation_x : int = 75

var dice_slots : Array[DiceSlot]
var hp : int
var turn_atk: int
var stun: bool
var shield : int
var is_alive: bool = true
var t : float = Utils.basic_wait_time

func init(d: EnemyData) -> void:
	data = d

func _ready():
	if not data:
		return
	sprite2D.texture = data.texture
	hp = data.max_hp
	update_label()
	eneter_animation()
	ui.init(data.attack, data.max_hp, data.steal_food, data.steal_wood, data.shield)
	if data.size > 0:
		ui.position.y -= 75
		

func reset_turn():
	if not is_alive:
		queue_free()
		return
	turn_atk = data.attack
	shield = data.shield
	var tween = create_tween()
	tween.tween_property(sprite2D, "modulate", Color.WHITE, t)
	set_stun(false)
	update_label()

func inflict_damage(damage:int, type:String) -> bool: #return true if the enemy is killed
	while( shield and damage):
		shield -= 1
		damage -= 1
	hp -= damage
	red_flash()
	update_label()
	play_sound_effect(type)
	if hp <= 0: return true
	return false


func freeze_animation():
	var tween = create_tween()
	tween.tween_property(sprite2D, "modulate", Color.STEEL_BLUE,t)

func add_smoke(x:int):
	var tween = create_tween()
	tween.tween_property(sprite2D, "modulate",Color.DIM_GRAY,t)
	tween.tween_property(sprite2D, "modulate",Color.WHITE,t)
	turn_atk -= x
	if turn_atk < 0 : set_stun(true)
	update_label()

func kill() -> void :
	is_alive = false
	var tween = create_tween()
	tween.tween_property(sprite2D, "modulate:a", 0 ,t)
	await tween.finished
	Utils.create_text_feedback("+" + str(data.xp_value) + " XP",global_position)
	for slot in dice_slots:
		slot.hide()
	ui.hide()

func attack() -> int:
	var time = t/5
	var tween = create_tween()
	tween.tween_property(sprite2D, "position:x", -attack_animation_x ,time)
	tween.tween_property(sprite2D, "position:x", 0 ,time)
	play_attack_sfx(time)
	await tween.step_finished
	return turn_atk

func red_flash() -> void:
	var tween = create_tween()
	tween.tween_property(sprite2D, "modulate", Color.RED ,t/3)
	tween.tween_property(sprite2D, "modulate", Color.WHITE , t/3)

func eneter_animation() -> void:
	var time = t/2
	sprite2D.position.x = 50
	sprite2D.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(sprite2D, "position:x", 0 ,time)
	tween.parallel().tween_property(sprite2D, "modulate:a", 1 ,time)

func play_attack_sfx(delay : float):
	await get_tree().create_timer(delay).timeout
	var attack_sfx = sounds[0]
	attack_sfx.pitch_scale = randf_range(0.6,1.2)
	attack_sfx.play()

func set_stun(value : bool) -> void:
	stun_animation.set_visible(value)
	stun = value

func reduce_attack(x : int) -> void:
	turn_atk -= x
	if turn_atk < 0 : set_stun(true)
	update_label()

func can_attack(slot) -> bool:
	return (is_alive and
			slot == dice_slots.back() and
			not stun)

func update_label():
	ui.update_hp(hp)
	ui.update_atk(turn_atk)

func play_sound_effect(type : String):
	match type:
		"sword": sounds[1].play()
		"spike":
			await get_tree().create_timer(t/5).timeout
			sounds[2].play()
