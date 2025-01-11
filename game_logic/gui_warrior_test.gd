extends GridContainer

var dice_slots = 5
var faces_loaded = [
	"res://dice_faces/sword.tres",
	"res://dice_faces/shield.tres",
	"res://dice_faces/food.tres",
	"res://dice_faces/wood.tres",
	"res://dice_faces/wheel.tres"
]

func _ready():
	for i in dice_slots:
		var slot = DiceSlot.new()
		slot.init(DiceSlot.Type.HERO, Vector2i(64, 64))
		add_child(slot)
	
	for i in faces_loaded.size():
		var face = DiceFace.new()
		face.init(load(faces_loaded[i]))
		get_child(i).add_child(face)
