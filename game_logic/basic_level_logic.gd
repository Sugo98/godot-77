class_name LevelLogic extends Node

var game_manager : GameManager

@onready var enemy_slots_container : Control = $EnemyZone/EnemySlots
@onready var enemy_pivots_container: Node2D = $EnemyZone/EnemyPivots
@onready var wood_slots_container: Control = $WoodSlots
@onready var food_slots_container: Control = $FoodSlots
@onready var road_slots_container: Control = $RoadSlots
@onready var caravan_slots_container: Control = $CaravanSlots

@onready var road_label: Label = $RoadLabel
@onready var animation_timer: Timer = $AnimationTimer
@onready var blocker: Control = $Blocker

var enemy_slots : Array[DiceSlot]
var enemy_pivots: Array[Node]
var wood_slots: Array[DiceSlot]
var food_slots: Array[DiceSlot]
var road_slots: Array[DiceSlot]
var caravan_slots: Array[DiceSlot]

@export var enemy_scene : PackedScene
var heroes_manager : HeroesManager
var active_enemies : Dictionary
var basic_wait_time : float = 0.5

var data : LevelData
var road : int
var danger : int
var danger_threshold : int

func init(d : LevelData):
	data = d
	road = data.length_of_the_road
	danger_threshold = data.danger_threshold
	
func _ready() -> void:
	fill_array()
	show_slots()
	decrase_road(0) #update road label
	blocker.hide()

func show_slots(): 
	for slot : DiceSlot in wood_slots:
		if slot.get_index() < data.wood_slots:
			slot.show()
		else:
			slot.hide()
	for slot : DiceSlot in food_slots:
		if slot.get_index() < data.food_slots:
			slot.show()
		else:
			slot.hide()
	for slot : DiceSlot in road_slots:
		if slot.get_index() < data.road_slots:
			slot.show()
		else:
			slot.hide()

func fill_array():
	enemy_slots = parse_slots(enemy_slots_container)
	enemy_pivots = enemy_pivots_container.get_children()
	wood_slots = parse_slots(wood_slots_container)
	food_slots = parse_slots(food_slots_container)
	road_slots = parse_slots(road_slots_container)
	caravan_slots = parse_slots(caravan_slots_container)

func parse_slots(slots_container) -> Array[DiceSlot]:
	var array : Array[DiceSlot]
	for slot in slots_container.get_children():
		array.append( slot as DiceSlot)
	return array

func debug_spawn_enemy():
	spawn_enemy()

func solve_turn():
	blocker.show()
	await solve_hunger()
	await solve_food_slots()
	await solve_wood_slots()
	await solve_caravan_slots()
	await solve_enemies_slots()
	await solve_road_slots()
	await update_danger()
	reset_turn()
	blocker.hide()

func solve_hunger():
	heroes_manager.eat(1)
	await wait_time(basic_wait_time)

func solve_food_slots():
	for slot:DiceSlot in food_slots:
		if slot.get_child_count() == 0:
			continue
		var face : DiceFace = slot.get_child(0)
		Utils.create_text_feedback("+" + str(face.data.food) +" Food", slot.global_position)
		face.hide()
		heroes_manager.increase_food(face.data.food)
		await wait_time(basic_wait_time)

func solve_wood_slots():
	for slot:DiceSlot in wood_slots:
		if slot.get_child_count() == 0:
			continue
		var face : DiceFace = slot.get_child(0)
		heroes_manager.increase_wood(face.data.wood)
		await wait_time(basic_wait_time)

func solve_caravan_slots():
	for slot:DiceSlot in caravan_slots:
		if slot.get_child_count() == 0:
			continue
		var face : DiceFace = slot.get_child(0)
		heroes_manager.increase_shield(face.data.shield)
		heroes_manager.repair(face.data.wheel)
		await wait_time(basic_wait_time)

func solve_enemies_slots():
	for slot:DiceSlot in enemy_slots:
		if not active_enemies.has(slot):
			continue
		var enemy = active_enemies[slot]
		var damage = 0
		if slot.get_child_count():
			var face : DiceFace = slot.get_child(0)
			damage = face.data.sword
		if enemy.inflict_damage(damage):
			kill_enemy(enemy)
		else:
			heroes_manager.inflict_damage(enemy.data.attack)
		await wait_time(basic_wait_time)

func solve_road_slots():
	for slot:DiceSlot in road_slots:
		if slot.get_child_count() == 0:
			continue
		var face : DiceFace = slot.get_child(0)
		decrase_road(face.data.wheel)
		await wait_time(basic_wait_time)

func decrase_road(x):
	road -= x
	road_label.text = "Road: " + str(road)
	if road <= 0:
		next_level()

func next_level():
	game_manager.go_to_next_level()

func reset_turn():
	heroes_manager.reset_turn()

func spawn_enemy():
	var enemy_data = Utils.random_pick( data.enemy , data.enemy_probability )
	var new_enemy = enemy_scene.instantiate()
	new_enemy.init(enemy_data)
	for i in range( enemy_pivots.size() ):
		var pivot : Marker2D = enemy_pivots[i]
		if pivot.get_child_count() == 0:
			pivot.add_child(new_enemy)
			enemy_slots[i].show()
			new_enemy.dice_slot = enemy_slots[i]
			active_enemies[ enemy_slots[i] ] = new_enemy
			await wait_time(basic_wait_time)
			return

func kill_enemy(enemy : Enemy):
	var slot = enemy.dice_slot
	slot.hide()
	enemy.queue_free()
	active_enemies.erase(slot)
	await wait_time(basic_wait_time)

func update_danger():
	danger += data.base_danger + randi_range(0, data.random_danger)
	var spawn := false
	while danger >= danger_threshold:
		danger -= danger_threshold
		spawn_enemy()
		spawn = true
	if spawn == true:
		danger_threshold -= data.danger_shrink
	if danger_threshold <= 0:
		danger_threshold == 1

func wait_time(t):
	animation_timer.set_wait_time(t)
	animation_timer.start()
	await animation_timer.timeout
	return
