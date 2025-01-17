class_name Dice extends Node

var faces : Array[DiceFace]
@export var character_class : Global.CharacterClass
@export var hero_texture : Texture2D

@export var level_stuff : MarginContainer
@export var merchant_stuff : MarginContainer

@export var dice_slots: BoxContainer
@export var slots_for_merchant: HBoxContainer
@export var sprite_2d : TextureRect

@export var dice_roll_sfx : Node
var roll_sfx : Array[AudioStreamPlayer]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	faces.resize(6)
	load_basic_dice()
	load_sfx_array()
	sprite_2d.texture = hero_texture

func prepare_for_level():
	merchant_stuff.set_visible(false)
	level_stuff.set_visible(true)
	set_slots_owner(dice_slots)
	set_faces_owner()
	roll_dice()

func prepare_for_merchant():
	merchant_stuff.set_visible(true)
	level_stuff.set_visible(false)
	set_slots_owner(slots_for_merchant)
	load_for_merchant()

func load_basic_dice():
	var i = 0
	for path in Global.basic_dice_faces:
		var new_face = DiceFace.new()
		new_face.init( load(path) )
		new_face.dice_owner = self
		faces[i] = new_face
		i += 1
	var last_face = DiceFace.new()
	last_face.init( load(Global.sixth_face[ character_class ]) )
	faces[5] = last_face

func load_sfx_array():
	for sound in dice_roll_sfx.get_children():
		roll_sfx.append(sound)

func free_all_slots():
	for face in faces:
		face.show()
		face.modulate = Color.WHITE
		var parent = face.get_parent()
		if parent:
			parent.remove_child(face)

func roll_dice():
	var result = range(6)
	result.shuffle()
	play_roll_dice_sfx()
	add_faces_to_slots([result[0], result[1]])
	for slot in dice_slots.get_children():
		slot.get_child(0).roll_animation()

func add_faces_to_slots(f: Array[int]):
	free_all_slots()
	var child = 0
	for i in f:
		faces[i].draggable = true
		var slot = dice_slots.get_child(child)
		slot.add_child(faces[i])
		child += 1

func load_for_merchant():
	free_all_slots()
	for i in range(6):
		faces[i].draggable = false
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

func save_new_dice():
	for i in range(6):
		faces[i] = slots_for_merchant.get_child(i).get_child(0)

func play_roll_dice_sfx():
	var sfx = roll_sfx[randi()%roll_sfx.size()]
	sfx.volume_db = -10
	sfx.pitch_scale = randf_range(0.8, 1.2)
	var delay = randf_range(0,0.5)
	await get_tree().create_timer(delay).timeout
	sfx.play()
