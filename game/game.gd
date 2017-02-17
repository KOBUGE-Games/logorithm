extends Node2D

## State variables ##

onready var language_pack = LanguagePackManager.get_language_pack("en")

var selection_letters = []
var selection_string = ""

## Callbacks ##

func _ready():
	pass

## Functions ##

func on_letter_selected(letter):
	if letter in selection_letters:
		selection_letters.erase(letter)
		selection_string = ""
		for letter in selection_letters:
			selection_string += letter.get_character()
	else:
		selection_letters.append(letter)
		selection_string += letter.get_character()

	if language_pack.has_word(selection_string):
		print("%s is a valid word." % selection_string)
