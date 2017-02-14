extends Node2D

const letter_scene = preload("res://objects/letter.tscn")

export(int) var width = 10
export(int) var height = 10
export(Vector2) var letter_spacing = Vector2(60, 60)

var letters = {}

func _ready():
	regenerate_grid()

func regenerate_grid():
	randomize()
	for row in range(height):
		for column in range(width):
			add_tile(Vector2(row, column))

func add_tile(position):
	var letter = letter_scene.instance()
	letter.set_pos((position - Vector2(width - 1, height - 1) / 2) * letter_spacing)
	letter.set_letter("ABCDEFGHIJKLMNOPQRSTUVWXYZ"[randi() % 26])
	add_child(letter)
	
	letters[position] = letter
