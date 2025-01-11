class_name Dice extends Node

var faces : Array[DiceFace]
@export var character_class : Global.CharacterClass
@onready var dice_slots: VBoxContainer = $DiceSlots


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_slot_owner()
	faces.resize(6)
	load_basic_dice()
	throw_dice()

func load_basic_dice():
	var i = 0
	for path in Global.basic_dice_faces:
		var new_face = DiceFace.new()
		new_face.init( load(path) )
		new_face.set_hero_owner( character_class )
		new_face.dice_owner = self
		faces[i] = new_face
		i += 1
	var new_face = DiceFace.new()
	new_face.init( load(Global.basic_dice_faces[0]) )
	faces[5] = new_face

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func free_all_faces():
	for face in faces:
		var parent = face.get_parent()
		if parent:
			parent.remove_child(face)

func throw_dice():
	var result = range(6)
	result.shuffle()
	add_faces_to_slots(result[0], result[1])

func add_faces_to_slots(a:int, b:int):
	free_all_faces()
	dice_slots.get_child(0).add_child( faces[a] )
	dice_slots.get_child(1).add_child( faces[b] )

func set_slot_owner():
	for slot : DiceSlot in dice_slots.get_children():
		slot.set_hero_owner( character_class )

func call_home_other_face(data):
	for face in faces:
		if face == data:
			continue
		if face.is_inside_tree():
			face.come_back_home()
