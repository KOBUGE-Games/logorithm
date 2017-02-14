extends Node2D

export(String) var letter = "A" setget set_letter, get_letter
onready var label = get_node("label")



func _ready():
	set_letter(letter)

func set_letter(new_letter):
	letter = new_letter
	if label:
		label.set_text(letter)

func get_letter(new_letter):
	return letter