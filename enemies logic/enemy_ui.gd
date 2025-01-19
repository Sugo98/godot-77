extends Control

@export var hp_bar: HBoxContainer
@export var attack_label: Label
@export var food_steal_icon : PanelContainer
@export var wood_steal_icon : PanelContainer
@export var shield_icon : PanelContainer

func init(atk, max_hp, food, wood, shield) -> void:
	var container = hp_bar.get_parent()
	container.size = Vector2( max_hp * 32 + 16, 32)
	container.position.x = (-container.size.x/2)
	for i in range(max_hp):
		var new_rect = ColorRect.new()
		new_rect.color = Global.luigi_green_light
		new_rect.size_flags_horizontal = SIZE_EXPAND_FILL
		hp_bar.add_child(new_rect)
	update_atk(atk)
	
	food_steal_icon.set_visible( food )
	food_steal_icon.tooltip_text = "%s\n%s" % [tr("STEAL_FOOD"), tr("STEAL_FOOD_DESC")]
	wood_steal_icon.set_visible( wood )
	wood_steal_icon.tooltip_text = "%s\n%s" % [tr("STEAL_WOOD"), tr("STEAL_WOOD_DESC")]
	shield_icon.set_visible( shield )
	shield_icon.tooltip_text = "%s\n%s" % [tr("ENEMY_SHIELD"), tr("ENEMY_SHIELD_DESC")]

func update_hp(x):
	for i  in hp_bar.get_child_count():
		var rect = hp_bar.get_child(i)
		rect.color = Global.luigi_green_light if i < x else Global.luigi_green_dark 
	pass

func update_atk(x):
	if x<0: x=0
	attack_label.text = ": " + str(x)
	
