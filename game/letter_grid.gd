extends Node2D

## Exports ##

export(PackedScene) var letter_scene # The scene to use for individual letters
export(int) var width = 10 # Size of the playing field on X
export(int) var height = 10 # Size of the playing field on Y
export(Vector2) var letter_spacing = Vector2(60, 60) # Spacing between centers of individual letters
export(float) var click_radius_multiplier = 0.8 # Multiplier for the click radius (1 = circle with letter_spacing radius)

## State variables ##

var letters = {}
onready var language_pack = LanguagePackManager.get_language_pack("en")

## Callbacks ##

func _ready():
	randomize()
	regenerate_grid()

## Helper functions ##

func regenerate_grid():
	""" Regenerates the whole grid, making sure to clean it too """
	clean_grid()
	for row in range(height):
		for column in range(width):
			var column_offset = height * abs(column - width / 2) / 9.0
			add_letter(Vector2(column, row), Vector2(column, row - height - column_offset))

func clean_grid():
	""" Cleans the whole grid """
	for position in letters:
		# TODO: Add animations
		letters[position].queue_free()
		letters.erase(position)

func add_letter(position, animate_from = position):
	""" Helper to add a letter at a given position """
	var letter = letter_scene.instance()
	letter.set_pos(get_letter_screen_position(animate_from))
	letter.set_character(language_pack.pick_random_character())

	add_child(letter)
	
	letter.animate_to(get_letter_screen_position(position))
	
	letter.position = position
	letters[position] = letter

func get_letter_at_pos(position):
	""" Helper to get the letter at a given _global_ position """
	var local_position = position / letter_spacing - Vector2(0.5, 0.5)
	var snapped_position = local_position.snapped(Vector2(1, 1))
	var distance = local_position.distance_to(snapped_position)

	if letters.has(snapped_position) and distance < 0.5 * click_radius_multiplier:
		return letters[snapped_position]
	else:
		return null

func free_letters(letters_array):
	""" Removes the given letters from private dictionary """
	var removed_positions = []
	for letter in letters_array:
		removed_positions.push_back(letter.position)
		if letters.has(letter.position):
			letters.erase(letter.position)
		letter.queue_free()
	
	reorder_grid(removed_positions)
	respawn_letters(removed_positions)

func reorder_grid(removed_positions): # Virtual
	""" Reorders the grid, given a list of removed positions """
	var max_removed_elements = []
	max_removed_elements.resize(width)
	for column in range(width):
		max_removed_elements[column] = 0
	
	for position in removed_positions:
		max_removed_elements[position.x] = max(max_removed_elements[position.x], position.y)
	
	for column in range(width):
		var move_down = 0
		for row in range(max_removed_elements[column], 0 - 1, -1):
			if !letters.has(Vector2(column, row)):
				move_down += 1
			else:
				var letter = letters[Vector2(column, row)]
				move_letter(letter, letter.position + Vector2(0, move_down))

func respawn_letters(removed_positions): # Virtual
	""" Adds new letters, given a list of removed positions """
	removed_positions.sort()
	var removed_counts = []
	removed_counts.resize(width)
	for column in range(width):
		removed_counts[column] = 0
	
	for position in removed_positions:
		var from = Vector2(position.x, position.y - height - 1)
		add_letter(Vector2(position.x, removed_counts[position.x]), from)
		removed_counts[position.x] += 1

func move_letter(letter, target_position):
	letters.erase(letter.position)
	letter.position = target_position
	letters[letter.position] = letter
	letter.animate_to(get_letter_screen_position(letter.position))

func get_letter_screen_position(letter_position):
	return (letter_position - Vector2(width - 1, height - 1) / 2) * letter_spacing

func get_size():
	""" Helper to get the size taken by the grid """
	return Vector2(width, height) * letter_spacing
