extends Panel

## Exports ##

export(NodePath) var letter_grid_path = @"../letter_grid"

## State variables ##

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
		if event.button_index == BUTTON_LEFT and event.is_pressed() and !event.is_echo():
			var letter = letter_grid.get_letter_at_pos(event.pos)
			if letter != null:
				letter.select()
				accept_event()
