class_name Tutorial extends ColorRect

@onready var previous: Button = $Previous
@onready var next: Button = $Next
@onready var close: Button = $Close
@onready var page_control: Control = $PageControl

@onready var starting_index : int = 0
var pages : Array[Node]

func _ready() -> void:
	pages = page_control.get_children()

func hide_all_pages():
	for page in pages:
		page.hide()

func open_tutorial() -> void:
	show()
	starting_index = 0
	hide_all_pages()
	pages[starting_index].show()
	previous.disabled = true
	next.disabled = false

func _on_previous_button_down() -> void:
	pages[starting_index].hide()
	starting_index -= 1
	pages[starting_index].show()
	if (starting_index == 0):
		previous.disabled = true
	next.disabled = false

func _on_next_button_down() -> void:
	pages[starting_index].hide()
	starting_index += 1
	pages[starting_index].show()
	if (starting_index == len(pages) - 1):
		next.disabled = true
	previous.disabled = false

func _on_close_button_down() -> void:
	starting_index = 0
	hide_all_pages()
	hide()
