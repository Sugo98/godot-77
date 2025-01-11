class_name Dice extends Node2D

var faces : Array[DiceFace2]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	faces.resize(6)
	for i in range(6):
		var new_face = DiceFace.new()
		new_face.init( load("res://dice_faces/shield.tres") )
		faces[i] = new_face
	add_child(faces[0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
