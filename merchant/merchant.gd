class_name Merchant extends Control

@onready var market_slots: Control = $MerchantSlots

var game_manager : GameManager
var heroes_manager : HeroesManager
var data : MerchantData

func init(d : MerchantData):
	data = d

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_slots_owner(market_slots)
	for slot in market_slots.get_children():
		var new_face = DiceFace.new()
		var face = Utils.random_pick( data.face , data.face_probability )
		new_face.init(face)
		slot.add_child(new_face)

func set_slots_owner(slots: Variant):
	for slot : DiceSlot in slots.get_children():
		slot.set_hero_owner(Global.CharacterClass.Fighter)
