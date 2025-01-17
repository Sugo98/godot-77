class_name GlobalUtils extends Node

var main_canvas : CanvasLayer

func random_pick( elements , probabilities ) :
	var n = min(elements.size(), probabilities.size())
	var p = probabilities.duplicate()
	for i in range(n-1):
		p[i+1] += p[i]
	var k = randi_range(0,p[n-1])
	for i in range(n):
		if k <= p[i]:
			return elements[i]
	return elements[0]

func create_text_feedback(text : String, position : Vector2):
	var new_feedback = TextFeedback.new()
	main_canvas.add_child(new_feedback)
	new_feedback.init(text, position)

var basic_wait_time : float = 0.5

func roll_animation(face : TextureRect, pos : Vector2):
	face.global_position = pos
	main_canvas.add_child(face)
	face.rotation = - PI * 3
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	var time = ( 1 + randf() ) * basic_wait_time
	tween.tween_property(face,"rotation",0, time)
	await tween.finished
	main_canvas.remove_child(face)
