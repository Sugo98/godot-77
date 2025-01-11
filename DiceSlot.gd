class_name DiceSlot
extends PanelContainer

enum Type {HERO, ENEMY, FOOD, WOOD, CARAVAN, ROAD}

@export var type: Type

func init(t: Type, cms: Vector2i) -> void:
	type = t
	custom_minimum_size = cms

func _can_drop_data(_at_position: Vector2, data: Variant):
	if data is not DiceFace:
		return false
	return data.can_be_placed(type)

func _drop_data(_at_position: Vector2, data: Variant):
	if get_child_count() > 0:
		var item = get_child(0)
		if item == data:
			return
		item.reparent(data.get_parent())
	data.reparent(self)
