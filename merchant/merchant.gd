class_name Merchant extends Control

@onready var market_slots: Control = $MerchantSlots
@onready var prices_labels: Control = $Prices
@onready var balance_label: Label = $Balance

var game_manager : GameManager
var heroes_manager : HeroesManager
var data : MerchantData

var selling_faces : Array[DiceFace]
var balance : int = 0

func init(d : MerchantData):
	data = d

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(market_slots.get_child_count()):
		var new_face = DiceFace.new()
		var face_data = Utils.random_pick( data.face , data.face_probability )
		new_face.init(face_data)
		selling_faces.append(new_face)
		market_slots.get_child(i).shopkeeper = self
	
	reset_market()

func reset_market():
	for i in range(market_slots.get_child_count()):
		selling_faces[i].reparent(market_slots.get_child(i))
		selling_faces[i].draggable = true
		market_slots.get_child(i).add_child(selling_faces[i])
		prices_labels.get_child(i).text = "XP: " + str(selling_faces[i].data.xp_cost) 
	
	heroes_manager.prepare_for_merchant()
	balance = 0
	update_balance()

func _on_confirm_pressed() -> void:
	pass # Replace with function body.

func face_leaves(id):
	balance += selling_faces[id].data.xp_cost
	update_balance()

func update_balance():
	balance_label.text = "Balance: " + str(balance)
