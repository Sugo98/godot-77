class_name DiceSlot
extends PanelContainer

enum Type {HERO, ENEMY, FOOD, WOOD, CARAVAN, ROAD, SHOP}

@export var type : Type
@export var is_shopping : bool = false

var hero_owner : Global.CharacterClass = Global.CharacterClass.Any
var shopkeeper : Merchant

func init(t: Type, cms: Vector2i) -> void:
	type = t
	custom_minimum_size = cms

func _can_drop_data(_at_position: Vector2, data: Variant):
	if data is not DiceFace or type == Type.SHOP:
		return false
	if type == Type.HERO:
		if data.hero_owner == Global.CharacterClass.Any:
			return true
		return (hero_owner == data.hero_owner)
	return data.can_be_placed(type)

func _drop_data(_at_position: Vector2, data: Variant):
	if get_child_count() > 0:
		var item = get_child(0)
		if item == data:
			return
		if not is_shopping and data.hero_owner == item.hero_owner:
			return false 
		if is_shopping:
			item.get_parent().remove_child(item)
		else:
			item.come_back_home()
	if hero_owner != data.hero_owner and data.hero_owner != Global.CharacterClass.Any:
		data.dice_owner.call_home_other_face(data)
	data.reparent(self)
	if is_shopping:
		data.draggable = false

func set_hero_owner(o : Global.CharacterClass) -> void :
	hero_owner = o

func face_leaves():
	if shopkeeper and get_child_count() == 0 and get_parent():
		shopkeeper.face_leaves(get_parent().get_index())
