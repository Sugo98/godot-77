class_name EnemyData extends Resource

enum Size{Small, Big, Huge}
@export var name : String
@export var texture : Texture2D

@export_category("Basic Values")

@export var size : Size
@export var max_hp : int
@export var attack : int
@export var xp_value : int
