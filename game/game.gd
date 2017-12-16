extends Node2D

## Signals ##

signal score_changed(last_word, last_word_score)

## State variables ##

onready var language_pack = LanguagePackManager.get_language_pack("en")

var total_score = 0

var selection_letters = []
var selection_string = ""
var valid_word = false

## Callbacks ##

func _ready():
	get_node("gui_layer/gui/drag_panel").connect("letter_selected", self, "update_selection")

## Functions ##

func score_word():
	""" Calculate score based on characters weight (1/frequency), special letters and length of word """
	# TODO: Make a real balanced scoring algorithm
	var special_count = 0
	var word_score = 0
	for letter in selection_letters:
		word_score += log(1.0 / language_pack.get_character_frequency(letter.get_character()))
		if letter.is_special():
			special_count += 1

	word_score *= exp((selection_letters.size() - 2) / 3) * 10
	word_score *= exp(special_count)

	word_score = int(word_score)
	total_score += word_score

	emit_signal("score_changed", selection_string, word_score)

	get_node("letter_grid").free_letters(selection_letters)
	selection_letters = []
	selection_string = ""

func update_selection(letter, is_drag):
	""" Handle the letter_selected signal from the drag panel """
	var orig_selection = []
	for letter in selection_letters:
		orig_selection.append(letter)
	var orig_valid = valid_word

	if letter == null:
		if valid_word:
			score_word() # Just score
	elif letter in selection_letters:
		if is_drag:
			if letter == selection_letters.back(): # same letter
				return
			if selection_letters.size() > 1 and letter == selection_letters[selection_letters.size() - 2]:
				# unselect letter
				selection_letters.pop_back()
				selection_string = selection_string.substr(0, selection_string.length() - 1)
		else:
			if letter == selection_letters.back(): # last selected letter
				if valid_word: # confirm word, get points
					score_word()
				else: # unselect letter
					selection_letters.pop_back()
					selection_string = selection_string.substr(0, selection_string.length() - 1)
			else: # discard whole selection
				selection_letters = []
				selection_string = ""
	elif selection_letters.size() == 0 or letter.adjoins(selection_letters.back()): # add new letter
		selection_letters.append(letter)
		selection_string += letter.get_character()
		letter.set_highlight(true)
	elif is_drag: # remake selection
		selection_letters = [letter]
		selection_string = letter.get_character()
		letter.set_highlight(true)
	else:
		return

	valid_word = language_pack.has_word(selection_string)

	# Clear animations
	for letter in orig_selection:
		if !letter.is_queued_for_deletion():
			letter.reset()
	for i in range(selection_letters.size()):
		var letter = selection_letters[i]
		letter.set_highlight(true)
		if i + 1 < selection_letters.size():
			letter.set_next_direction(selection_letters[i + 1].position - letter.position)
		if valid_word:
			letter.get_node("animation").play("glow")
	if valid_word:
		selection_letters.back().get_node("outline").show()
