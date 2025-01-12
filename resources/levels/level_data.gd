class_name LevelData extends Resource

@export var name: String
@export_multiline var description: String
@export var back_ground_texture: Texture2D

@export_category("Necessary Road")
@export var length_of_the_road : int

@export_category("Enemy")
@export var enemy : Array[EnemyData]
@export var enemy_probability : Array[int]

@export_category("Number of Slots")
@export var road_slots : int
@export var food_slots : int
@export var wood_slots : int
