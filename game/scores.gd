extends Control

## Exports ##

export(NodePath) var game_path = @"../../.."
export(int) var max_word_list_entries = 20

## State variables ##

var word_list = []
onready var game = get_node(game_path)
onready var score = get_node("score")
onready var past_scores = get_node("past_scores")

## Callbacks ##

func _ready():
	game.connect("score_changed", self, "add_word")

## Functions ##

func add_word(word, word_score):
	""" Add a word to the word list """
	word_list.push_front("%s - %d" % [word, word_score])
	if word_list.size() > max_word_list_entries:
		word_list.resize(max_word_list_entries)

	var joined_word_list = ""
	for entry in word_list:
		joined_word_list += entry + "\n"
	past_scores.set_text(joined_word_list)

	update_score()

func update_score():
	""" Update the score label """
	score.set_text("%06d pts" % game.total_score)
