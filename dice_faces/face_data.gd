class_name FaceData
extends Resource

enum Type {ANY, SWORD, SHIELD}

@export var type: Type
@export var name: String
@export_multiline var description: String
@export var texture: Texture2D
