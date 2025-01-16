extends Control

@export var hp_bar: HBoxContainer
@export var attack_label: Label

func init(atk, max_hp) -> void:
	var container = hp_bar.get_parent()
	container.size = Vector2( max_hp * 32 + 32  , 32)
	container.position.x = (-container.size.x/2)
	for i in range(max_hp):
		var new_rect = ColorRect.new()
		new_rect.color = Global.hp_green_color
		new_rect.size_flags_horizontal = SIZE_EXPAND_FILL
		hp_bar.add_child(new_rect)
	update_atk(atk)

func update_hp(x):
	for i  in hp_bar.get_child_count():
		var rect = hp_bar.get_child(i)
		rect.color = Global.hp_green_color if i < x else Global.hp_red_color 
	pass#hp_label.text = "HP: " + str(x) + "/" + str(y)

func update_atk(x):
	attack_label.text = ": " + str(x)
