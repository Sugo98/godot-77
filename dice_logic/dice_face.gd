class_name DiceFace
extends TextureRect

var data : FaceData
var equivalent_rect : TextureRect

var dice_owner : Dice
var hero_owner : Global.CharacterClass
var draggable : bool = true
var root : Window

func init(d: FaceData) -> void:
	data = d
	if data : hero_owner = data.character_class

func _ready():
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if data :
		texture = data.texture
		var title = tr(data.name)
		if data.character_class != Global.CharacterClass.Any:
			title += " (" + tr(Utils.get_class_name(data.character_class)) + ")"
		tooltip_text = "%s\n%s" % [title, tr(data.description)]
		prepare_equivalen_rect()
	root = get_tree().get_root()

func prepare_equivalen_rect():
	equivalent_rect = TextureRect.new()
	equivalent_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	equivalent_rect.size = Vector2.ONE * 128
	equivalent_rect.pivot_offset = Vector2.ONE * 64
	equivalent_rect.texture = texture
	equivalent_rect.modulate.a = 1
	equivalent_rect.z_index = 3

func can_be_placed(slot : DiceSlot.Type):
	if data.jolly:
		return true
	match slot:
		DiceSlot.Type.ENEMY:
			return (data.sword or 
					data.fire_ball or
					data.wall_ice or
					data.smoke)
		DiceSlot.Type.FOOD:
			return data.food
		DiceSlot.Type.WOOD:
			return data.wood
		DiceSlot.Type.CARAVAN:
			return (data.shield or data.wheel) 
		DiceSlot.Type.ROAD:
			return data.wheel

func _process(_delta: float) -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		modulate.a=1

func _get_drag_data(at_position: Vector2):
	if not draggable:
		return false
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
	t.z_index = 100
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
	show()
	if hero_owner == get_parent().hero_owner:
		return
	for slot in dice_owner.dice_slots.get_children():
		if slot.get_child_count() == 0:
			reparent(slot)
			return

func freeze_animation():
	var time = Utils.basic_wait_time
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.DODGER_BLUE , time)
	

func roll_animation():
	self_modulate.a = 0
	await get_tree().process_frame
	await Utils.roll_animation(equivalent_rect, global_position)
	self_modulate.a = 1
