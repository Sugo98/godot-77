class_name EndGameScreen extends ColorRect

@export var star_container : Node2D
@export var star_texture : Texture2D
@export var fader : ColorRect
@export var quote : VBoxContainer
@export var thanks : VBoxContainer
@export var credits : VBoxContainer
@export var back_button : PanelContainer
var game_manager : GameManager

var animation_time_1 := 1.0
var animation_time_2 := 1.0
var animation_time_3 := 2.0
var offset_x := 400

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thanks.hide()
	credits.hide()
	create_night_sky()
	fade_in()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func create_night_sky():
	for i in range(400):
		var new_star = Sprite2D.new()
		new_star.texture = star_texture
		new_star.global_position.x = randi_range(0,1920)
		new_star.global_position.y = randi_range(0,1080)
		var dim = randf_range(0.1,0.4)
		new_star.scale = Vector2.ONE * dim
		new_star.rotation = randi_range(0,90)
		var h = randf()
		var s = randf() *0.33
		var v = 0.9
		new_star.modulate = Color.from_hsv(h,s,v,1)
		star_container.add_child(new_star)


func _on_back_to_menu_pressed() -> void:
	game_manager.quit_game()

func fade_in():
	fader.show()
	var tween = create_tween()
	tween.tween_property(fader, "modulate:a",0,1)
	await tween.finished
	for row in quote.get_children():
		var tween2 = create_tween()
		tween2.tween_property(row, "modulate:a",1,animation_time_1)
		await tween2.finished
		await get_tree().create_timer(animation_time_2).timeout
	var tween3 = create_tween()
	tween3.tween_property(quote, "position:x", quote.position.x - offset_x, animation_time_1)
	await tween3.finished
	
	var tween4 = create_tween()
	tween4.tween_property(thanks,"position:y",thanks.position.y,animation_time_3)
	tween4.tween_property(credits,"position:y",credits.position.y,animation_time_3)
	thanks.position.y += 1000
	credits.position.y += 1000
	thanks.show()
	credits.show()
	await tween4.finished
	var tween5 = create_tween()
	tween5.tween_property(back_button, "modulate:a",1,animation_time_1)

	fader.hide()
