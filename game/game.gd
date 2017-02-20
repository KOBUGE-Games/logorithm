extends Node2D

## State variables ##

onready var language_pack = LanguagePackManager.get_language_pack("en")

var total_score = 0

var selection_letters = []
var selection_string = ""
var valid_word = false

## Callbacks ##

func _ready():
	pass

## Functions ##

func score_word():
	""" Calculate score based on characters weight (1/frequency) and length of word """
	# TODO: Make a real balanced scoring algorithm
	var char_weights = []
	for letter in selection_letters:
		char_weights.append(1.0 / language_pack.get_character_frequency(letter.get_character()))
	char_weights.sort() # Higher weights give higher score (non-linear scoring)

	var word_score = 0
	var e = exp(1)
	for i in range(char_weights.size()):
		word_score += 0.4 * log(e * (i + 1)) * pow(char_weights[i], 0.9)
	word_score = int(word_score)
	total_score += word_score

	print("Word score: %d" % word_score)
	print("Total score: %d" % total_score)

	get_node("letter_grid").free_letters(selection_letters)
	selection_letters = []
	selection_string = ""

func on_letter_selected(letter):
	""" Handle the letter_selected signal from the letter nodes """
	var orig_selection = []
	for letter in selection_letters:
		orig_selection.append(letter)
	var orig_valid = valid_word

	if letter in selection_letters:
		if letter == selection_letters.back(): # last selected letter
			if valid_word: # confirm word, get points
				score_word()
			else: # unselect letter
				selection_letters.pop_back()
				selection_string = selection_string.substr(0, selection_string.length() - 1)
		else: # discard whole selection
			selection_letters = []
			selection_string = ""
	elif selection_string.empty() or letter.adjoins(selection_letters.back()): # add new letter
		selection_letters.append(letter)
		selection_string += letter.get_character()
		letter.set_highlight(true)
	else:
		return

	if language_pack.has_word(selection_string):
		print("%s is a valid word." % selection_string)
		valid_word = true
	elif valid_word:
		valid_word = false

	# Clear animations
	for letter in orig_selection:
		if !letter.is_queued_for_deletion():
			letter.reset()
	for letter in selection_letters:
		letter.set_highlight(true)
		if valid_word:
			letter.get_node("animation").play("glow")
	if valid_word:
		selection_letters.back().get_node("outline").show()
