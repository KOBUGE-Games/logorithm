extends Panel

## Signals ##

signal letter_selected(letter, is_drag)

## Exports ##

export(NodePath) var letter_grid_path = @"../letter_grid"
export(float) var min_drag_distance = 5

## State variables ##

var dragging = false
var drag_start = Vector2()
onready var letter_grid = get_node(letter_grid_path)

## Callbacks ##

func _ready():
	# Resize to match the grid
	var size = letter_grid.get_size()
	set_size(size)
	set_pos(-size / 2)
	if is_a_parent_of(letter_grid):
		letter_grid.set_pos(size / 2)

func _input_event(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				dragging = true
				drag_start = event.pos
			else:
				dragging = false
				if drag_start.distance_to(event.pos) < min_drag_distance:
					select_at_event(event, false)
				else:
					emit_signal("letter_selected", null, false)
	
	if event.type == InputEvent.MOUSE_MOTION and dragging:
		if drag_start.distance_to(event.pos) > min_drag_distance:
			select_at_event(event, true)

func select_at_event(event, is_drag):
	""" Helper function to select letters """
	var letter = letter_grid.get_letter_at_pos(event.pos)
	if letter != null and !letter.is_queued_for_deletion():
		emit_signal("letter_selected", letter, is_drag)
		accept_event()
