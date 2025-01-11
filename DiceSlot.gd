class_name DiceSlot
extends PanelContainer

@export var type: FaceData.Type

func init(t: FaceData.Type, cms: Vector2i) -> void:
	type = t
	custom_minimum_size = cms

func _can_drop_data(_at_position: Vector2, data: Variant):
	if data is DiceFace:
		if type == FaceData.Type.ANY:
			if get_child_count() == 0:
				return true
			else :
				if type == data.get_parent().type:
					return true
				return get_child(0).data.type == data.data.type
		else:
			return data.data.type == type
	else:
		false

func _drop_data(_at_position: Vector2, data: Variant):
	if get_child_count() > 0:
		var item = get_child(0)
		if item == data:
			return
		item.reparent(data.get_parent())
	data.reparent(self)
