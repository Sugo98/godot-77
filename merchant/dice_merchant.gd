class_name Merchant extends Control

@onready var market_slots: VBoxContainer = $MainCanvas/MarketSlots

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_slots_owner(market_slots)
	for slot in market_slots.get_children():
		var new_face = DiceFace.new()
		var path = Global.merchant_dice_faces.pick_random()
		new_face.init(load(path))
		slot.add_child(new_face)

func set_slots_owner(slots: Variant):
	for slot : DiceSlot in slots.get_children():
		slot.set_hero_owner(Global.CharacterClass.Fighter)
