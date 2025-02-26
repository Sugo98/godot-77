class_name LevelLogic extends Node

var game_manager : GameManager

const bridge_discounted_cost = Global.bridge_discount_repair_cost
const bridge_cost = Global.bridge_repair_cost
const offset_x = 100

@onready var background: Sprite2D = $Background
@onready var enemy_slots_container : Control = $EnemyZone/EnemySlots
@onready var enemy_pivots_container: Node2D = $EnemyZone/EnemyPivots
@onready var wood_slots_container: Control = $WoodSlots
@onready var food_slots_container: Control = $FoodSlots
@onready var road_slots_container: Control = $RoadSlots
@onready var caravan_slots_container: Control = $CaravanSlots
@onready var back_ground_music: AudioStreamPlayer = $BackGroundMusic

@export var road_label: Label
@export var road_progress_bar : ProgressBar
@export var sfx : Array[AudioStreamPlayer]
@onready var animation_timer: Timer = $AnimationTimer
@onready var blocker: Control = $Blocker
@export var obstacle_icon : PanelContainer
@export var desert_icon : PanelContainer
@export var bridge_icon : PanelContainer
@export var you_died : ColorRect
@export var lose_button : Button

var enemy_slots : Array[DiceSlot]
var enemy_pivots: Array[Node]
var wood_slots: Array[DiceSlot]
var food_slots: Array[DiceSlot]
var road_slots: Array[DiceSlot]
var caravan_slots: Array[DiceSlot]

@export var enemy_scene : PackedScene
var heroes_manager : HeroesManager
var active_enemies : Dictionary
var t : float = 0.5 # basic_wait_time

var data : LevelData
var road : int
var danger : int
var danger_multiplier : float
var danger_threshold : float
var freeze : bool

func init(d : LevelData):
	data = d
	road = data.length_of_the_road
	road_progress_bar.max_value = road
	danger = data.starting_danger
	danger_threshold = data.danger_threshold
	danger_multiplier = 1.0
	
func _ready() -> void:
	fill_array()
	show_slots()
	spawn_initial_enemy()
	decrase_road(0) #update road label
	start_playing_music()
	blocker.hide()
	background.texture = data.back_ground_texture
	back_ground_music.stream = data.soundtrack
	back_ground_music.play()

func show_slots(): 
	for slot : DiceSlot in caravan_slots:
		slot.tooltip_text = tr("CARAVAN_SLOT")
	for slot : DiceSlot in wood_slots:
		if 1 - slot.get_index() < data.wood_slots:
			slot.show()
			if data.food_consumption > 2: slot.self_modulate = Color.BURLYWOOD
			slot.tooltip_text = tr("WOOD_SLOT")
			if data.mod_wood : slot.theme_type_variation = "Plus_1"
		else:
			slot.hide()
	for slot : DiceSlot in food_slots:
		if slot.get_index() < data.food_slots:
			slot.show()
			if data.food_consumption > 2: slot.self_modulate = Color.BURLYWOOD
			slot.tooltip_text = tr("FOOD_SLOT")
			if data.mod_food : slot.theme_type_variation = "Plus_1"
		else:
			slot.hide()
	if data.road_obstacle:
		obstacle_icon.show()
		obstacle_icon.tooltip_text = "%s\n%s" % [tr("ROAD_OBSTACLE"), tr("ROAD_OBSTACLE_DESC")]
	if data.food_consumption > 2:
		desert_icon.show()
		desert_icon.tooltip_text = "%s\n%s" % [tr("DESERT_ICON"), tr("DESERT_ICON_DESC")]
	if data.broken_bridge:
		bridge_icon.show()
		bridge_icon.tooltip_text = "%s\n%s" % [tr("BROKEN_BRIDGE"), tr("BROKEN_BRIDGE_DESC")]
	if not data.boss_level:
		for i in range (road_slots.size()):
			var slot = road_slots[i]
			if i < data.road_slots:
				slot.show()
				if data.food_consumption > 2: slot.self_modulate = Color.BURLYWOOD
				slot.tooltip_text = tr("ROAD_SLOT")
			else:
				slot.hide()
	else:
		road_slots_container.hide()
		road_progress_bar.hide()
		enemy_slots_container.position += Vector2.DOWN * 150
		enemy_pivots_container.position += Vector2.DOWN * 75

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
		if slot is DiceSlot:
			array.append( slot as DiceSlot)
	return array

func debug_spawn_enemy():
	spawn_random_enemy()

func solve_turn():
	blocker.show()
	set_basic_wait_time()
	await solve_hunger()
	await solve_wood_slots()
	await solve_food_slots()
	await solve_caravan_slots()
	await solve_enemies_slots()
	await solve_road_slots()
	if heroes_manager.check_game_over():
		game_over()
		return
	if check_end():
		await next_level()
	else:
		reset_turn()
		await update_danger()
	blocker.hide()

func solve_hunger():
	heroes_manager.eat(data.food_consumption)
	Utils.create_text_feedback("-" + str(data.food_consumption) + " " + tr("FOOD_NAME"), heroes_manager.caravan_position)
	await wait_time(t)

func solve_wood_slots():
	for slot:DiceSlot in wood_slots:
		if slot.get_child_count() == 0:
			continue
		var face : DiceFace = slot.get_child(0)
		var x = face.data.wood + face.data.jolly + data.mod_wood
		if x < 0 : x = 0
		Utils.create_text_feedback("+" + str(x) + " " + tr("WOOD_NAME"), slot.global_position)
		heroes_manager.increase_wood(x)
		if face.data.carrot:
			await wait_time(t/2)
			Utils.create_text_feedback("+" + str(1) + " " + tr("FOOD_NAME"), slot.global_position)
			heroes_manager.increase_food(1)
		face.hide()
		await wait_time(t)

func solve_food_slots():
	for slot:DiceSlot in food_slots:
		if slot.get_child_count() == 0:
			continue
		var face : DiceFace = slot.get_child(0)
		var x = face.data.food + face.data.jolly + data.mod_food
		if x < 0 : x = 0
		Utils.create_text_feedback("+" + str(x) + " " + tr("FOOD_NAME"), slot.global_position)
		face.hide()
		heroes_manager.increase_food(x)
		await wait_time(t)

func solve_caravan_slots():
	for slot:DiceSlot in caravan_slots:
		if slot.get_child_count() == 0:
			continue
		var face : DiceFace = slot.get_child(0)
		if face.data.shield or face.data.jolly:
			var x = face.data.shield + face.data.jolly
			Utils.create_text_feedback("+" + str(x) + " " + tr("SHIELD"), slot.global_position)
			heroes_manager.increase_shield(x)
			var y = face.data.spikes
			if y:
				heroes_manager.increase_spikes(y)
				if x: await  wait_time(0.3)
				Utils.create_text_feedback("+" + str(y) + " " + tr("SPIKES"), slot.global_position)
		if face.data.wheel:
			face.hide()
			heroes_manager.repair(face.data.wheel, face.data.wood_discount, slot.global_position)
		await wait_time(t)

func solve_enemies_slots():
	if there_is_wall_ice():
		await freeze_everything()
		return
	await solve_area_effects()
	await solve_single_enemy_slots()

func solve_single_enemy_slots():
	for slot in active_enemies:
		var enemy : Enemy = active_enemies[slot]
		if slot.get_child_count() and enemy.is_alive: #if there is a dice
			var face = slot.get_child(0)
			await resolve_attack_dice(face, enemy)
		#counter_attack
		if enemy.can_attack(slot) : await enemy_attack(enemy)

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
			await wait_time(t)
		
		if is_wood_enough:
			while( obstacle and x):
				obstacle -= 1
				x -= 1
			Utils.create_text_feedback("-" + str(x) + " " + tr("DISTANCE"), slot.global_position)
			decrase_road(x)
		
		face.hide()
		await wait_time(t)

func decrase_road(x):
	road -= x
	road_progress_bar.value = road_progress_bar.max_value - road
	road_label.text = tr("DISTANCE_LABEL") + ": " + str(road)

func next_level():
	blocker.show()
	await wait_time(0.5)
	game_manager.go_to_next_level()

func reset_turn():
	danger_multiplier = move_toward(danger_multiplier, data.danger_multiplier_max, data.danger_multiplier_step)
	heroes_manager.reset_turn()
	for slot in enemy_slots:
		if not active_enemies.has(slot):
			continue
		var enemy : Enemy = active_enemies[slot]
		enemy.reset_turn()
		if enemy.is_queued_for_deletion() : active_enemies.erase(slot)

func spawn_random_enemy():
	if data.boss_level:
		return
	var enemy_data : EnemyData = Utils.random_pick( data.enemy , data.enemy_probability )
	spawn_enemy(enemy_data)
	reduce_danger(enemy_data.xp_value)

func reduce_danger(x : int):
	danger -= x * 10 #+ 2 * ( x * x - 1)

func spawn_initial_enemy():
	if data.boss_level:
		spawn_big_enemy(data.initial_enemy[0])
		return
	for enemy_data in data.initial_enemy:
		spawn_enemy(enemy_data)

func spawn_enemy(enemy_data : EnemyData):
	var new_enemy : Enemy = enemy_scene.instantiate()
	new_enemy.init(enemy_data)
	for i in range( enemy_slots.size() ):
		var pivot : Marker2D = enemy_pivots[i]
		var slot : DiceSlot = enemy_slots[i]
		if not active_enemies.has(slot):
			pivot.add_child(new_enemy)
			new_enemy.reset_turn()
			enemy_slots[i].show()
			enemy_slots[i].tooltip_text = tr("ENEMY_SLOT")
			new_enemy.dice_slots.append(slot)
			active_enemies[ slot ] = new_enemy
			await wait_time(t)
			return

func spawn_big_enemy(enemy_data : EnemyData):
	var new_enemy : Enemy = enemy_scene.instantiate()
	new_enemy.init(enemy_data)
	var size = enemy_data.size
	var x0 = 1 if size == 1 else 0
	enemy_pivots[x0].add_child(new_enemy)
	new_enemy.reset_turn()
	for i in range(size+1):
		enemy_slots[i+x0].show()
		new_enemy.dice_slots.append(enemy_slots[i+x0])
		active_enemies[ enemy_slots[i+x0] ] = new_enemy
	new_enemy.position.x += offset_x * size
	await wait_time(t)
	return

func kill_enemy(enemy : Enemy):
	#var slots = enemy.dice_slots
	await enemy.kill()
	heroes_manager.gain_xp(enemy.data.xp_value)

func update_danger():
	if freeze:
		freeze = false
		return
	danger += int( (data.base_danger + randi_range(0, data.random_danger) ) * danger_multiplier )
	if danger >= danger_threshold:
		while danger > 0:
			spawn_random_enemy()

func wait_time(time):
	animation_timer.set_wait_time(time)
	animation_timer.start()
	await animation_timer.timeout
	return

func cast_fire_ball(x:int) -> void:
	for slot in active_enemies:
		var enemy : Enemy = active_enemies[slot]
		if enemy.dice_slots.back() == slot:
			if enemy.inflict_damage(x, "fire"): kill_enemy(enemy)
	sfx[0].play()
	await wait_time(2*t)

func there_is_wall_ice() -> bool:
	for slot:DiceSlot in enemy_slots:
		if slot.get_child_count()==0: #if there are no dice
			continue
		var face : DiceFace = slot.get_child(0)
		if face.data.wall_ice:
			slot.remove_child(face)
			sfx[1].play()
			return true
	return false

func freeze_everything() -> void:
	freeze = true
	for slot:DiceSlot in active_enemies:
		if slot.get_child_count() > 0:
			slot.get_child(0).freeze_animation()
	for slot in active_enemies:
		active_enemies[slot].freeze_animation()
	await wait_time(2*t)
	return

func solve_area_effects() -> void:
	var smoke_faces : Array[DiceFace]
	for slot:DiceSlot in enemy_slots:
		if slot.get_child_count()==0: #if there are no dice
			continue
		var face : DiceFace = slot.get_child(0)
		if face.data.smoke:
			face.hide()
			smoke_faces.append(face)
		if face.data.fire_ball:
			face.hide()
			await cast_fire_ball(face.data.fire_ball)
			slot.remove_child(face)
	# RESOLVE TOTAL SMOKE 
	if smoke_faces:
		var tot_smoke :int = 0
		for face in smoke_faces:
			tot_smoke += face.data.smoke
			face.get_parent().remove_child(face)
		for slot in active_enemies:
			var enemy : Enemy = active_enemies[slot]
			if enemy.dice_slots.back() == slot : enemy.add_smoke(tot_smoke)
		await wait_time(2*t)

func resolve_attack_dice(face:DiceFace, enemy:Enemy) :
	face.hide()
	var damage = face.data.sword + face.data.jolly
	if face.data.stun:
		if enemy.data.size == 0:
			enemy.set_stun(true)
		else:
			enemy.reduce_attack(1)
	if face.data.food:
		Utils.create_text_feedback("+" + str(face.data.food) + " " + tr("FOOD_NAME"), face.global_position)
		heroes_manager.increase_food(face.data.food)
	if enemy.inflict_damage(damage, "sword"): await kill_enemy(enemy)
	await wait_time(t)

func enemy_attack(enemy : Enemy):
	var dmg = await enemy.attack()
	if dmg: heroes_manager.suffer_damage(dmg)
	check_spikes(enemy)
	await enemy_steal(enemy)
	await wait_time(t)

func check_spikes(enemy : Enemy):
	var spikes = heroes_manager.spikes
	if not spikes: return
	if enemy.inflict_damage(spikes, "spike"): await kill_enemy(enemy)

func enemy_steal(enemy : Enemy):
	var x = enemy.data.steal_food
	if x:
		heroes_manager.increase_food(-x)
		Utils.create_text_feedback("-" + str(x) + " " + tr("FOOD_NAME"), heroes_manager.caravan_position)
		await wait_time(t)
	x = enemy.data.steal_wood
	if x:
		heroes_manager.increase_wood(-x)
		Utils.create_text_feedback("-" + str(x) + " " + tr("WOOD_NAME"), heroes_manager.caravan_position)
		await wait_time(t)

func check_end() -> bool:
	if data.boss_level:
		for slot in active_enemies:
			if active_enemies[slot].is_alive: return false
		return true
	else:
		return (road <= 0)

func start_playing_music():
	back_ground_music.process_mode = Node.PROCESS_MODE_ALWAYS
	back_ground_music.stream = data.soundtrack
	back_ground_music.play()

func set_basic_wait_time():
	t = Utils.basic_wait_time
	for slot in active_enemies:
		active_enemies[slot].t = t

func clear_ui():
	set_basic_wait_time()
	blocker.show()
	var tween = create_tween().set_parallel(true)
	tween.tween_property(enemy_slots_container, "modulate:a", 0, t)
	tween.tween_property(wood_slots_container, "modulate:a", 0, t)
	tween.tween_property(food_slots_container, "modulate:a", 0, t)
	tween.tween_property(road_slots_container, "modulate:a", 0, t)
	tween.tween_property(caravan_slots_container, "modulate:a", 0, t)
	tween.tween_property(road_progress_bar, "modulate:a",0,t)
	tween.tween_property(obstacle_icon, "modulate:a",0,t)
	await wait_time(t)

func game_over():
	you_died.show()
	blocker.show()
	var tween = create_tween()
	tween.tween_property(you_died, "modulate:a", 0.9, 2)
	await  tween.finished
	await  wait_time(1)
	lose_button.show()
	tween = create_tween()
	tween.tween_property(lose_button, "modulate:a", 1, 1)
	await lose_button.pressed
	game_manager.quit_game()
