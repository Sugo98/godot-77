class_name FaceData extends Resource

@export var name: String
@export_multiline var description: String
@export var texture: Texture2D

@export var character_class : Global.CharacterClass


@export_category("Shop")
@export var xp_cost : int

@export_category("Basic Values")
@export var sword : int
@export var shield : int
@export var food : int
@export var wood : int
@export var wheel : int

@export_category("Special Values")
@export var fire_ball : int
@export var smoke : int
@export var jolly : int #alambicco
@export var spikes : int
@export var stun: bool
@export var wall_ice : bool
@export var wood_discount : bool
