class_name Enemy extends Node2D

var data: EnemyData
@export var ui : Control
@export var sprite2D: Sprite2D
@export var attack_sfx : AudioStreamPlayer

@export var attack_animation_x : int = 75

var dice_slots : Array[DiceSlot]
var hp : int
var turn_atk: int
var stun: bool
var shield : int
var is_alive: bool = true
var t : float = Utils.basic_wait_time
var tween : Tween

func init(d: EnemyData) -> void:
	data = d

func _ready():
	if not data:
		return
	sprite2D.texture = data.texture
	hp = data.max_hp
	tween = create_tween()
	update_label()
	eneter_animation()
	ui.init(data.attack, data.max_hp)

func reset_turn():
	if not is_alive:
		queue_free()
		return
	turn_atk = data.attack
	shield = data.shield
	if not tween.is_valid(): tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0)
	set_stun(false)
	update_label()

func inflict_damage(damage:int, _type:String) -> bool: #return true if the enemy is killed
	while( shield and damage):
		shield -= 1
		damage -= 1
	hp -= damage
	red_flash()
	update_label()
	if hp <= 0: return true
	return false


func freeze_animation():
	if not tween.is_valid(): tween = create_tween()
	tween.tween_property(sprite2D, "modulate", Color.STEEL_BLUE,t)

func add_smoke(x:int):
	if not tween.is_valid(): tween = create_tween()
	tween.tween_property(sprite2D, "modulate",Color.DIM_GRAY,t)
	tween.tween_property(sprite2D, "modulate",Color.WHITE,t)
	turn_atk -= x
	if turn_atk < 0 : set_stun(true)
	update_label()

func kill() -> void :
	is_alive = false
	if not tween.is_valid(): tween = create_tween()
	tween.tween_property(sprite2D, "modulate:a", 0 ,t)
	await tween.finished
	#ui.hide()
	for slot in dice_slots:
		slot.hide()

func attack() -> int:
	if not tween.is_valid(): tween = create_tween()
	tween.tween_property(sprite2D, "position:x", -attack_animation_x ,t)
	tween.tween_property(sprite2D, "position:x", 0 ,t)
	play_attack_sfx(t)
	await tween.step_finished
	return turn_atk

func red_flash() -> void:
	if not tween.is_valid(): tween = create_tween()
	tween.tween_property(sprite2D, "modulate", Color.RED ,t/3)
	tween.tween_property(sprite2D, "modulate", Color.WHITE , t/3)

func eneter_animation() -> void:
	sprite2D.position.x = 50
	sprite2D.modulate.a = 0
	if not tween.is_valid(): tween = create_tween()
	tween.tween_property(sprite2D, "position:x", 0 ,t)
	tween.parallel().tween_property(sprite2D, "modulate:a", 1 ,t)

func play_attack_sfx(delay : float):
	await get_tree().create_timer(delay).timeout
	attack_sfx.pitch_scale = randf_range(0.6,1.2)
	attack_sfx.play()

func set_stun(value : bool) -> void:
	stun = value

func can_attack(slot) -> bool:
	return (is_alive and
			slot == dice_slots.back() and
			not stun)

func update_label():
	ui.update_hp(hp, data.max_hp)
	ui.update_atk(turn_atk)
