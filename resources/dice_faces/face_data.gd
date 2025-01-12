class_name FaceData extends Resource

@export var name: String
@export_multiline var description: String
@export var texture: Texture2D

@export var character_class : Global.CharacterClass

@export_category("Basic Values")
@export var sword : int
@export var shield : int
@export var food : int
@export var wood : int
@export var wheel : int

@export_category("Shop")
@export var xp_cost : int

@export var special_effect : Callable
