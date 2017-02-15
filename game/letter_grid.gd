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
			add_letter(Vector2(column, row))

func clean_grid():
	""" Cleans the whole grid """
	for position in letters:
		# TODO: Add animations
		letters[position].queue_free()
		letters.erase(position)

func add_letter(position):
	""" Helper to add a letter at a given position """
	var letter = letter_scene.instance()
	letter.set_pos((position - Vector2(width - 1, height - 1) / 2) * letter_spacing)
	letter.set_character(language_pack.pick_random_character())
	
	add_child(letter)
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

func get_size():
	""" Helper to get the size taken by the grid """
	return Vector2(width, height) * letter_spacing
