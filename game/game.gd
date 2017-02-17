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
		if letter == selection_letters.back(): # last letter, unselect
			selection_letters.pop_back()
			selection_string = selection_string.substr(0, selection_string.length() - 1)
			letter.set_highlight(false)
		else: # discard whole selection
			for letter in selection_letters:
				letter.set_highlight(false)
			selection_letters = []
			selection_string = ""
	elif selection_string.empty() or letter.adjoins(selection_letters.back()):
		selection_letters.append(letter)
		selection_string += letter.get_character()
		letter.set_highlight(true)
	print(selection_string)

	if language_pack.has_word(selection_string):
		print("%s is a valid word." % selection_string)
