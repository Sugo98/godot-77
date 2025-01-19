extends Node2D

@export var caravan_sprite : Sprite2D
@export var wheel_1 : Sprite2D
@export var wheel_2 : Sprite2D


@export var going_backward : int
@export var destination : int
@export var time_1 : float
@export var time_2 : float
@export var shaking_offset : float
@export var shaking_time :float
@export var shaking_rotation : float
@export var rotation_time : float
var stand_position : Vector2
var basic_time : float

func _ready():
	stand_position = position
	#do_the_the_shake()
	
func new_level():
	position = stand_position
	caravan_sprite.rotation = 0
	caravan_sprite.position = Vector2.ZERO
	show()

func do_the_animation():
	do_the_shake()
	rotate_wheels(1)
	basic_time = Utils.basic_wait_time
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:x", position.x - going_backward, time_1*basic_time)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(self, "position:x", destination, time_2*basic_time)
	await tween.finished

func do_the_shake():
	while(visible):
		var new_offset = Vector2(0, randf_range(-shaking_offset,0))
		var new_rotation = deg_to_rad( randf_range(-shaking_rotation, shaking_rotation) )
		var tween = create_tween()
		tween.tween_property(caravan_sprite, "position", new_offset, shaking_time)
		tween.set_parallel().tween_property(caravan_sprite, "rotation", new_rotation, shaking_time)
		await tween.finished

func rotate_wheels(x : float):
	while(visible):
		wheel_1.rotation = 0
		wheel_2.rotation = 0
		var tween = create_tween().set_parallel()
		tween.tween_property(wheel_1, "rotation", 2*PI, rotation_time * x)
		tween.tween_property(wheel_2, "rotation", 2*PI, rotation_time * x)
		await tween.finished
