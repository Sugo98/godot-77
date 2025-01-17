class_name TextFeedback extends Label

var up_to :int = 100
var square_side = 64

func _ready() -> void:
	theme_type_variation = "TextFeedback"
	z_index = 3	
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)

func init(t : String, p : Vector2) -> void:
	text = t
	position = p
	position.x -= (size.x - square_side) / 2
	do_the_animation()

func do_the_animation():
	var t = Utils.basic_wait_time
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", position.y-up_to, t/2)
	tween.tween_property(self, "modulate:a", 0, t)
	await tween.finished
