class_name LevelData extends Resource

@export var name: String
@export_multiline var description: String
@export var back_ground_texture: Texture2D

@export_category("Necessary Road")
@export var length_of_the_road : int
@export var boss_level : bool

@export_category("Enemy")
@export var enemy : Array[EnemyData]
@export var enemy_probability : Array[int]
@export var initial_enemy : Array[EnemyData]
@export var base_danger : int
@export var random_danger : int
@export var danger_threshold : int
@export var danger_shrink : int

@export_category("Number of Slots")
@export var road_slots : int
@export var food_slots : int
@export var wood_slots : int

@export_category("Modifier")
@export var mod_wood : int
@export var mod_food : int
@export var road_obstacle : int
@export var broken_bridge : bool = false
@export var dragon_level : bool = false
