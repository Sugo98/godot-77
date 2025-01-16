extends Control

@export var hp_label: HBoxContainer
@export var attack_label: Label

func _ready() -> void:
	init(0,1)

func init(atk, max_hp) -> void:
	var container = hp_label.get_parent()
	container.size = Vector2( max_hp * 32 + 32  , 32)
	container.position.x = -(size.x/2)
	print(container.size, container.position)
	for i in range(max_hp):
		var new_rect = ColorRect.new()
		new_rect.color = Global.hp_green_color
		new_rect.size_flags_horizontal = SIZE_EXPAND_FILL
		hp_label.add_child(new_rect)

func update_hp(x,y):
	pass#hp_label.text = "HP: " + str(x) + "/" + str(y)

func update_atk(x):
	attack_label.text = "ATK: " + str(x)
