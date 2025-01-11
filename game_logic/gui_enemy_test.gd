extends CanvasLayer

var dice_slots = 2
var faces_loaded = [ ]

func _ready():
	for i in dice_slots:
		var slot = DiceSlot.new()
		slot.init(FaceData.Type.SWORD, Vector2i(64, 64))
		%EnemySlots.add_child(slot)
	
	for i in faces_loaded.size():
		var face = DiceFace.new()
		face.init(load(faces_loaded[i]))
		%EnemySlots.get_child(i).add_child(face)
