class_name DiceFace
extends TextureRect

@export var data: FaceData
var dice_owner : Dice
var hero_owner : Global.CharacterClass

func init(d: FaceData) -> void:
	data = d

func _ready():
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture = data.texture
	tooltip_text = "%s\n%s" % [data.name, data.description]

func can_be_placed(slot : DiceSlot.Type):
	match slot:
		DiceSlot.Type.ENEMY:
			return data.sword
		DiceSlot.Type.FOOD:
			return data.food
		DiceSlot.Type.WOOD:
			return data.wood
		DiceSlot.Type.CARAVAN:
			return (data.shield or data.wheel) 
		DiceSlot.Type.ROAD:
			return data.wheel

func _process(delta:float) -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		modulate.a=1

func _get_drag_data(at_position: Vector2):
	set_drag_preview(make_drag_preview(at_position))
	modulate.a = 0
	return self

func make_drag_preview(at_position: Vector2):
	var t = TextureRect.new()
	t.texture = texture
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = size
	t.modulate.a = 1 # transparency
	t.z_index = 1
	t.position = Vector2(-at_position)
	
	var c = Control.new()
	c.add_child(t)
	
	return c

func set_hero_owner(o : Global.CharacterClass) -> void :
	hero_owner = o

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			come_back_home()

func come_back_home():
	for slot in dice_owner.dice_slots.get_children():
		if slot.get_child_count() == 0:
			reparent(slot)
			return
