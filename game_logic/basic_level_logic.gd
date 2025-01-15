class_name LevelLogic extends Node

var game_manager : GameManager

const bridge_discounted_cost = Global.bridge_discount_repair_cost
const bridge_cost = Global.bridge_repair_cost
const offset_x = 100

@onready var enemy_slots_container : Control = $EnemyZone/EnemySlots
@onready var enemy_pivots_container: Node2D = $EnemyZone/EnemyPivots
@onready var wood_slots_container: Control = $WoodSlots
@onready var food_slots_container: Control = $FoodSlots
@onready var road_slots_container: Control = $RoadSlots
@onready var caravan_slots_container: Control = $CaravanSlots
@onready var back_ground_music: AudioStreamPlayer = $BackGroundMusic

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
var danger_threshold : float

func init(d : LevelData):
	data = d
	road = data.length_of_the_road
	danger_threshold = data.danger_threshold_max
	
func _ready() -> void:
	fill_array()
	show_slots()
	spawn_initial_enemy()
	decrase_road(0) #update road label
	start_playng_music()
	blocker.hide()
	back_ground_music.stream = data.soundtrack
	back_ground_music.play()

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
	if not data.boss_level:
		for slot : DiceSlot in road_slots:
			if slot.get_index() < data.road_slots:
				slot.show()
			else:
				slot.hide()
	else:
		road_slots_container.hide()
		road_label.hide()
		enemy_slots_container.position += Vector2.DOWN * 150
		enemy_pivots_container.position += Vector2.DOWN * 150

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
	spawn_random_enemy()

func solve_turn():
	blocker.show()
	basic_wait_time = Utils.basic_wait_time
	await solve_hunger()
	await solve_wood_slots()
	await solve_food_slots()
	await solve_caravan_slots()
	await solve_enemies_slots()
	await solve_road_slots()
	reset_turn()
	if check_end():
		await next_level()
	else:
		await update_danger()
	blocker.hide()

func solve_hunger():
	heroes_manager.eat(Global.food_consumption)
	Utils.create_text_feedback("-" + str(Global.food_consumption) +" Food", heroes_manager.caravan_position)
	await wait_time(basic_wait_time)

func solve_wood_slots():
	for slot:DiceSlot in wood_slots:
		if slot.get_child_count() == 0:
			continue
		var face : DiceFace = slot.get_child(0)
		var x = face.data.wood + face.data.jolly + data.mod_wood
		if x < 0 : x = 0
		Utils.create_text_feedback("+" + str(x) +" Wood", slot.global_position)
		heroes_manager.increase_wood(x)
		if face.data.carrot:
			await wait_time(basic_wait_time/2)
			Utils.create_text_feedback("+" + str(1) +" Food", slot.global_position)
			heroes_manager.increase_food(1)
		face.hide()
		await wait_time(basic_wait_time)

func solve_food_slots():
	for slot:DiceSlot in food_slots:
		if slot.get_child_count() == 0:
			continue
		var face : DiceFace = slot.get_child(0)
		var x = face.data.food + face.data.jolly + data.mod_food
		if x < 0 : x = 0
		Utils.create_text_feedback("+" + str(x) +" Food", slot.global_position)
		face.hide()
		heroes_manager.increase_food(x)
		await wait_time(basic_wait_time)

func solve_caravan_slots():
	for slot:DiceSlot in caravan_slots:
		if slot.get_child_count() == 0:
			continue
		var face : DiceFace = slot.get_child(0)
		if face.data.shield or face.data.jolly:
			var x = face.data.shield + face.data.jolly
			Utils.create_text_feedback("+" + str(x) +" Shield", slot.global_position)
			heroes_manager.increase_shield(x)
			var y = face.data.spikes
			if y:
				heroes_manager.increase_spikes(y)
				if x: await  wait_time(0.3)
				Utils.create_text_feedback("+" + str(y) +" Spikes", slot.global_position)
		if face.data.wheel:
			face.hide()
			heroes_manager.repair(face.data.wheel, face.data.wood_discount, slot.global_position)
		await wait_time(basic_wait_time)

func solve_enemies_slots():
	if there_is_wall_ice():
		await freeze_all_enemies()
	await solve_area_effects()
	for slot:DiceSlot in enemy_slots:
		if not active_enemies.has(slot): #if there is no enemy skip
			continue
		var enemy : Enemy = active_enemies[slot]
		if slot.get_child_count(): #if there is a dice
			var face = slot.get_child(0)
			await resolve_attack_dice(face, enemy)
		if enemy and enemy.is_alive and slot == enemy.dice_slots.back(): #counter_attack
			var dmg = enemy.attack()
			if dmg:
				heroes_manager.suffer_damage(dmg)
			check_spikes(enemy)
			if enemy.is_alive and not enemy.stun:
				await enemy_steal(enemy)
		await wait_time(basic_wait_time)
	for slot in active_enemies:
		active_enemies[slot].reset_stats()

func solve_road_slots():
	var obstacle = data.road_obstacle
	for slot:DiceSlot in road_slots:
		if slot.get_child_count() == 0:
			continue
		var face : DiceFace = slot.get_child(0)
		var x = face.data.wheel + face.data.jolly
		
		var is_wood_enough : bool = true
		if data.broken_bridge:
			var c = bridge_discounted_cost if face.data.wood_discount else bridge_cost
			is_wood_enough = heroes_manager.can_repair_bridge(c, slot.global_position)
			await wait_time(0.25)
		
		if is_wood_enough:
			while( obstacle and x):
				obstacle -= 1
				x -= 1
			Utils.create_text_feedback("-" + str(x) +" Distance", slot.global_position)
			decrase_road(x)

		face.hide()
		print("Face Hide")
		await wait_time(basic_wait_time)

func decrase_road(x):
	road -= x
	road_label.text = "Distance: " + str(road)

func next_level():
	await wait_time(0.5)
	game_manager.go_to_next_level()

func reset_turn():
	print("Reset Turn")
	heroes_manager.reset_turn()

func spawn_random_enemy():
	if data.boss_level:
		return
	var enemy_data = Utils.random_pick( data.enemy , data.enemy_probability )
	spawn_enemy(enemy_data)

func spawn_initial_enemy():
	if data.boss_level:
		spawn_big_enemy(data.initial_enemy[0])
		return
	for enemy_data in data.initial_enemy:
		spawn_enemy(enemy_data)

func spawn_enemy(enemy_data : EnemyData):
	var new_enemy : Enemy = enemy_scene.instantiate()
	new_enemy.init(enemy_data)
	for i in range( enemy_pivots.size() ):
		var pivot : Marker2D = enemy_pivots[i]
		if pivot.get_child_count() == 0:
			pivot.add_child(new_enemy)
			new_enemy.reset_stats()
			enemy_slots[i].show()
			new_enemy.dice_slots.append(enemy_slots[i])
			active_enemies[ enemy_slots[i] ] = new_enemy
			await wait_time(basic_wait_time)
			return

func spawn_big_enemy(enemy_data : EnemyData):
	var new_enemy : Enemy = enemy_scene.instantiate()
	new_enemy.init(enemy_data)
	var size = enemy_data.size
	enemy_pivots[0].add_child(new_enemy)
	new_enemy.reset_stats()
	for i in range(size+1):
		enemy_slots[i].show()
		new_enemy.dice_slots.append(enemy_slots[i])
		active_enemies[ enemy_slots[i] ] = new_enemy
	new_enemy.position.x += offset_x * size
	await wait_time(basic_wait_time)
	return

func kill_enemy(enemy : Enemy):
	var slots = enemy.dice_slots
	heroes_manager.gain_xp(enemy.data.xp_value)
	enemy.is_alive = false
	await enemy.kill()
	for slot in slots:
		active_enemies.erase(slot)

func update_danger():
	danger += data.base_danger + randi_range(0, data.random_danger)
	var spawn := false
	while danger >= danger_threshold:
		danger -= danger_threshold
		spawn_random_enemy()
		spawn = true
	if spawn == true:
		danger_threshold = lerp(danger_threshold, data.danger_threshold_min, 0.25 )

func wait_time(t):
	animation_timer.set_wait_time(t)
	animation_timer.start()
	await animation_timer.timeout
	return

func cast_fire_ball(x:int) -> void:
	for slot in enemy_slots:
		if not active_enemies.has(slot): #if there is no enemy skip
			continue
		var enemy : Enemy = active_enemies[slot]
		if enemy.inflict_area_damage(x):
			kill_enemy(enemy)

func there_is_wall_ice() -> bool:
	for slot:DiceSlot in enemy_slots:
		if slot.get_child_count()==0: #if there are no dice
			continue
		var face : DiceFace = slot.get_child(0)
		if face.data.wall_ice:
			return true
	return false

func freeze_all_enemies() -> void:
	for slot in active_enemies:
		active_enemies[slot].freeze()
	await wait_time(basic_wait_time)
	return

func solve_area_effects() -> void:
	var tot_smoke :int = 0
	for slot:DiceSlot in enemy_slots:
		if slot.get_child_count()==0: #if there are no dice
			continue
		var face : DiceFace = slot.get_child(0)
		if face.data.smoke:
			face.hide()
			tot_smoke += face.data.smoke
		if face.data.fire_ball:
			face.hide()
			cast_fire_ball(face.data.fire_ball)
	# RESOLVE TOTAL 
	if tot_smoke:
		for slot in active_enemies:
			active_enemies[slot].smoke(tot_smoke)
		await wait_time(basic_wait_time)

func resolve_attack_dice(face:DiceFace, enemy:Enemy) :
	face.hide()
	var damage = face.data.sword + face.data.jolly
	if face.data.stun:
		enemy.stun = true
	if face.data.food:
		Utils.create_text_feedback("+" + str(face.data.food) +" Food", face.global_position)
		heroes_manager.increase_food(face.data.food)
	if enemy.inflict_damage(damage):
		kill_enemy(enemy)
	await wait_time(basic_wait_time)

func check_spikes(enemy : Enemy):
	var spikes = heroes_manager.spikes
	if not spikes:
		return
	if enemy.inflict_damage(spikes):
		kill_enemy(enemy)

func enemy_steal(enemy : Enemy):
	var x = enemy.data.steal_food
	if x:
		heroes_manager.increase_food(-x)
		Utils.create_text_feedback("-" + str(x) +" Food", heroes_manager.caravan_position)
		await wait_time(0.3)
	x = enemy.data.steal_wood
	if x:
		heroes_manager.increase_wood(-x)
		Utils.create_text_feedback("-" + str(x) +" Wood", heroes_manager.caravan_position)
		
func check_end() -> bool:
	if data.boss_level:
		return active_enemies.is_empty()
	else:
		return (road <= 0)

func start_playng_music():
	back_ground_music.stream = data.soundtrack
	back_ground_music.play()
