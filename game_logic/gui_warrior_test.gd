extends CanvasLayer

var dice_slots = 2
var faces_loaded = [
	"res://dice_faces/sword.tres",
	"res://dice_faces/shield.tres"
]

func _ready():
	for i in dice_slots:
		var slot = DiceSlot.new()
		slot.init(FaceData.Type.ANY, Vector2i(64, 64))
		%WarriorDices.add_child(slot)
	
	for i in faces_loaded.size():
		var face = DiceFace.new()
		face.init(load(faces_loaded[i]))
		%WarriorDices.get_child(i).add_child(face)
