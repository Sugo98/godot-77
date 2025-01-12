class_name LevelLogic extends Control

@onready var enemy_slots : Control = $EnemyZone/EnemySlots
@onready var enemy_pivots: Node2D = $EnemyZone/EnemyPivots
@onready var wood_slots: Control = $WoodSlots
@onready var food_slots: Control = $FoodSlots
@onready var road_slots: Control = $RoadSlots
@onready var caravan_slots: Control = $CaravanSlots

@export var enemy_scene : PackedScene

var active_enemies : Array[Enemy]

var data : LevelData
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for slot : DiceSlot in wood_slots.get_children():
		if slot.get_index() < data.wood_slots:
			slot.show()
		else:
			slot.hide()
	for slot : DiceSlot in food_slots.get_children():
		if slot.get_index() < data.food_slots:
			slot.show()
		else:
			slot.hide()
	for slot : DiceSlot in road_slots.get_children():
		if slot.get_index() < data.road_slots:
			slot.show()
		else:
			slot.hide()

func init(d : LevelData):
	data = d

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	for pivot : Marker2D in enemy_pivots.get_children():
		if pivot.get_child_count() == 0:
			pivot.add_child(new_enemy)
			active_enemies.append(new_enemy)
			return
		
