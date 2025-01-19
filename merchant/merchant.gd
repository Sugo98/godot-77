class_name Merchant extends Control

@export var market_slots: Array[DiceSlot]
@export var prices_labels: Array[Label]
@export var balance_label: Label
@export var confirm_button: Button
@export var background_music: AudioStreamPlayer
@export var shadow : Sprite2D
@export var fader : Sprite2D
@export var blocker : Control

@export var star_texture : Texture
@onready var night_sky: Node2D = $NightSky

@export_category("Rolling Around")
@export var roll_offset : float
@export var roll_time : float

var game_manager : GameManager
var heroes_manager : HeroesManager
var data : MerchantData

var selling_faces : Array[DiceFace]
var balance : int = 0
var shopping_is_ended := false

func init(d : MerchantData):
	data = d

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(market_slots.size()):
		var new_face = DiceFace.new()
		var is_a_duplicate := true
		var face_data : FaceData
		while is_a_duplicate:
			face_data = Utils.random_pick( data.face , data.face_probability )
			is_a_duplicate = check_if_is_a_duplicate(face_data)
		new_face.init(face_data)
		selling_faces.append(new_face)
		market_slots[i].shopkeeper = self
	shopping_is_ended = false
	for slot in market_slots:
		slot.is_shopping = true
	start_back_ground_music()
	create_night_sky()
	fade_in()
	reset_market()
	roll_around()

func check_if_is_a_duplicate(face_data : FaceData) -> bool:
	for face in selling_faces:
		if face.data == face_data: return true
	return false

func reset_market():
	for i in range(market_slots.size()):
		if not selling_faces[i].is_inside_tree():
			market_slots[i].add_child(selling_faces[i])
		selling_faces[i].reparent(market_slots[i])
		selling_faces[i].draggable = true
		prices_labels[i].text = str(selling_faces[i].data.xp_cost) 
	
	heroes_manager.prepare_for_merchant()
	balance = 0
	update_balance()

func _on_confirm_pressed() -> void:
	blocker.show()
	shopping_is_ended = true
	await fade_out()
	heroes_manager.after_shopping(balance)
	game_manager.go_to_next_level()

func face_leaves(id):
	if not selling_faces[id]:
		return
	balance += selling_faces[id].data.xp_cost
	update_balance()

func update_balance():
	if not confirm_button:
		return
	confirm_button.disabled = balance > heroes_manager.xp
	balance_label.text = tr("TOTAL_COST") + ": " + str(balance)

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
		night_sky.add_child(new_star)


func start_back_ground_music():
	background_music.volume_db = -80
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(background_music, "volume_db", 0, 1)
	background_music.play()

func fade_in():
	var tween = create_tween()
	tween.tween_property(fader, "modulate:a", 0, Utils.basic_wait_time)

func fade_out():
	var tween = create_tween()
	tween.tween_property(fader, "modulate:a", 1, Utils.basic_wait_time)
	await tween.finished
	await get_tree().create_timer(Utils.basic_wait_time/4).timeout

func roll_around():
	roll_around_x()
	roll_around_y()

func roll_around_x():
	while(true):
		var new_offset = randf_range(-roll_offset,roll_offset)
		var time = randf_range(0.7,1)
		var tween = create_tween().set_trans(Tween.TRANS_QUAD)
		tween.tween_property(shadow, "offset:x", new_offset, time)
		await tween.finished
		
func roll_around_y():
	while(true):
		var new_offset = randf_range(-roll_offset,roll_offset)
		var time = randf_range(0.7,1)
		var tween = create_tween().set_trans(Tween.TRANS_QUAD)
		tween.tween_property(shadow, "offset:y", new_offset, time)
		await tween.finished
