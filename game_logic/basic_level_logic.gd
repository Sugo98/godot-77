class_name LevelLogic extends Control

@onready var enemy_slots : Control = $EnemySlots
@onready var wood_slots: Control = $WoodSlots
@onready var food_slots: Control = $FoodSlots
@onready var road_slots: Control = $RoadSlots
@onready var caravan_slots: Control = $CaravanSlots

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
