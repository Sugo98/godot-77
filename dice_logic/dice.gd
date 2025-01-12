class_name Dice extends Node

var faces : Array[DiceFace]
@export var character_class : Global.CharacterClass
@onready var dice_slots: VBoxContainer = $DiceSlots
@onready var slots_for_merchant: HBoxContainer = $SlotsForMerchants
@onready var debug_button: Button = $Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	faces.resize(6)
	load_basic_dice()
	set_faces_owner()
	
	if ("GameManager" == self.get_parent().get_parent().get_name()):
		slots_for_merchant.set_visible(false)
		set_slots_owner(dice_slots)
		roll_dice()
	if ("DiceMerchant" == self.get_parent().get_parent().get_name()):
		dice_slots.set_visible(false)
		debug_button.set_visible(false)
		set_slots_owner(slots_for_merchant)
		load_for_merchant()

func prepare_for_level():
	slots_for_merchant.set_visible(false)
	dice_slots.set_visible(true)
	set_slots_owner(dice_slots)
	roll_dice()

func load_basic_dice():
	var i = 0
	for path in Global.basic_dice_faces:
		var new_face = DiceFace.new()
		new_face.init( load(path) )
		new_face.dice_owner = self
		faces[i] = new_face
		i += 1
	var new_face = DiceFace.new()
	new_face.init( load(Global.basic_dice_faces[0]) )
	faces[5] = new_face

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func free_all_faces():
	for face in faces:
		var parent = face.get_parent()
		if parent:
			parent.remove_child(face)

func roll_dice():
	var result = range(6)
	result.shuffle()
	add_faces_to_slots([result[0], result[1]])

func add_faces_to_slots(f: Array[int]):
	free_all_faces()
	var child = 0
	for i in f:
		dice_slots.get_child(child).add_child(faces[i])
		child += 1

func load_for_merchant():
	free_all_faces()
	for i in range(6):
		slots_for_merchant.get_child(i).add_child(faces[i])

func set_slots_owner(slots: Variant):
	for slot : DiceSlot in slots.get_children():
		slot.set_hero_owner(character_class)

func set_faces_owner():
	for face in faces:
		face.set_hero_owner(character_class)
		face.dice_owner = self

func call_home_other_face(data):
	for face in faces:
		if face == data:
			continue
		if face.is_inside_tree():
			face.come_back_home()
