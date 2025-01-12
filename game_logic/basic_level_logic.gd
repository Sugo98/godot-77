class_name LevelLogic extends Control

@onready var enemy_slots_container : Control = $EnemyZone/EnemySlots
@onready var enemy_pivots_container: Node2D = $EnemyZone/EnemyPivots
@onready var wood_slots_container: Control = $WoodSlots
@onready var food_slots_container: Control = $FoodSlots
@onready var road_slots_container: Control = $RoadSlots
@onready var caravan_slots_container: Control = $CaravanSlots

var enemy_slots : Array[DiceSlot]
var enemy_pivots: Array[Node]
var wood_slots: Array[DiceSlot]
var food_slots: Array[DiceSlot]
var road_slots: Array[DiceSlot]
var caravan_slots: Array[DiceSlot]

@export var enemy_scene : PackedScene
var heroes_manager : HeroesManager

var active_enemies : Array[Enemy]

var data : LevelData
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fill_array()
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
	wood_slots = parse_slots(wood_slots_container) as Array[DiceSlot]
	food_slots = parse_slots(food_slots_container) as Array[DiceSlot]
	road_slots = parse_slots(road_slots_container) as Array[DiceSlot]
	caravan_slots = parse_slots(caravan_slots_container) as Array[DiceSlot]

func parse_slots(slots_container) -> Array[DiceSlot]:
	var array : Array[DiceSlot]
	for slot in slots_container.get_children():
		array.append( slot as DiceSlot)
	return array

func init(d : LevelData):
	data = d

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func debug_spawn_enemy():
	for enemy in active_enemies:
		enemy.reparent(self)
		enemy.queue_free()
	active_enemies = []
	for i in range( 3 ):
		spawn_enemy()

func spawn_enemy():
	var enemy_data = Utils.random_pick( data.enemy , data.enemy_probability )
	var new_enemy = enemy_scene.instantiate()
	new_enemy.init(enemy_data)
	for pivot : Marker2D in enemy_pivots:
		if pivot.get_child_count() == 0:
			pivot.add_child(new_enemy)
			active_enemies.append(new_enemy)
			return

func solve_turn():
	solve_hunger()
	solve_caravan_slots()
	solve_enemies_slots()
	solve_food_slots()
	solve_wood_slots()
	solve_road_slots()

func solve_hunger():
	heroes_manager.eat(1)

func solve_caravan_slots():
	pass

func solve_enemies_slots():
	pass

func solve_food_slots():
	for slot:DiceSlot in food_slots:
		if slot.get_child_count() == 0:
			continue
		var face : DiceFace = slot.get_child(0)
		var food_increase = face.data.food
		heroes_manager.increase_food(food_increase)

func solve_wood_slots():
	pass

func solve_road_slots():
	pass
