class_name TextFeedback extends Label

var up_to :int = 100
var square_side = 64

func _ready() -> void:
	add_theme_font_size_override("font_size",30)
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)

func init(t : String, p : Vector2) -> void:
	text = t
	position = p
	position.x -= (size.x - square_side) / 2
	do_the_animation()

func do_the_animation():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", position.y-up_to, 0.2)
	tween.tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
