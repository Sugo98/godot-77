extends Panel

@onready var previous: Button = $Previous
@onready var next: Button = $Next
@onready var close: Button = $Close
@onready var page_control: Control = $PageControl

@onready var starting_index : int = 0

func _ready() -> void:
	var pages = page_control.get_children()
	for page in pages:
		page.hide()
	pages[starting_index].show()
	previous.disabled = true
	next.disabled = false

func _on_previous_button_down() -> void:
	var pages = page_control.get_children()
	pages[starting_index].hide()
	starting_index -= 1
	pages[starting_index].show()
	if (starting_index == 0):
		previous.disabled = true
	next.disabled = false

func _on_next_button_down() -> void:
	var pages = page_control.get_children()
	pages[starting_index].hide()
	starting_index += 1
	pages[starting_index].show()
	if (starting_index == len(pages) - 1):
		next.disabled = true
	previous.disabled = false

func _on_close_button_down() -> void:
	starting_index = 1
