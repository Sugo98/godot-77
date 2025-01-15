class_name Merchant extends Control

@onready var market_slots: Control = $MerchantSlots
@onready var prices_labels: Control = $Prices
@onready var balance_label: Label = $Balance
@onready var confirm_button: Button = $Confirm

@export var star_texture : Texture
@onready var night_sky: Node2D = $NightSky

var game_manager : GameManager
var heroes_manager : HeroesManager
var data : MerchantData

var selling_faces : Array[DiceFace]
var balance : int = 0
var shopping_is_ended := false

func init(d : MerchantData):
	data = d

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(market_slots.get_child_count()):
		var new_face = DiceFace.new()
		var is_a_duplicate := true
		var face_data : FaceData
		while is_a_duplicate:
			face_data = Utils.random_pick( data.face , data.face_probability )
			is_a_duplicate = check_if_is_a_duplicate(face_data)
		new_face.init(face_data)
		selling_faces.append(new_face)
		market_slots.get_child(i).shopkeeper = self
	shopping_is_ended = false
	create_night_sky()
	reset_market()

func check_if_is_a_duplicate(face_data : FaceData) -> bool:
	for face in selling_faces:
		if face.data == face_data: return true
	return false

func reset_market():
	for i in range(market_slots.get_child_count()):
		if not selling_faces[i].is_inside_tree():
			market_slots.get_child(i).add_child(selling_faces[i])
		selling_faces[i].reparent(market_slots.get_child(i))
		selling_faces[i].draggable = true
		prices_labels.get_child(i).text = "XP: " + str(selling_faces[i].data.xp_cost) 
	
	heroes_manager.prepare_for_merchant()
	balance = 0
	update_balance()

func _on_confirm_pressed() -> void:
	shopping_is_ended = true
	heroes_manager.after_shopping(balance)
	game_manager.go_to_next_level()

func face_leaves(id):
	if not selling_faces[id]:
		return
	balance += selling_faces[id].data.xp_cost
	update_balance()

func update_balance():
	if not confirm_button:
		return
	confirm_button.disabled = balance > heroes_manager.xp
	balance_label.text = "Balance: " + str(balance)

func create_night_sky():
	for i in range(400):
		var new_star = Sprite2D.new()
		new_star.texture = star_texture
		new_star.global_position.x = randi_range(0,1920)
		new_star.global_position.y = randi_range(0,1080)
		new_star.scale.x = randf_range(0.08,0.12)
		new_star.scale.y = randf_range(0.08,0.12)
		new_star.rotation = randi_range(0,90)
		new_star.modulate = Color.from_hsv(randf(), 0.1, 0.9,1)
		night_sky.add_child(new_star)
