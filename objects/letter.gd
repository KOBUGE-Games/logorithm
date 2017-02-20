tool
extends Node2D

## Signals ##

signal letter_selected(letter)

## Exports ##

export(String) var character = "A" setget set_character, get_character
export(Color) var backdrop_color = Color(0.15, 0.15, 0.17, 1)
export(Color) var highlight_color = Color(0.40, 0.40, 0.30, 1)
export(bool) var highlight = false setget set_highlight, is_highlighted

## Nodes ##

onready var backdrop = get_node("backdrop")
onready var label = get_node("label")

## Callbacks ##

func _ready():
	set_character(character)
	set_highlight(false)
	# FIXME: Use a cleaner way to access the game scene
	connect("letter_selected", get_node("/root/game"), "on_letter_selected")

## Getters/Setters ##

func set_character(new_character):
	""" Sets the character displayed of the letter """
	character = new_character
	if label: # Might get called while still outside the tree
		label.set_text(character.to_upper())

func get_character():
	""" Gets the character last set by set_character """
	return character

func set_highlight(new_highlight):
	highlight = new_highlight
	if backdrop:
		backdrop.set_frame_color(highlight_color if highlight else backdrop_color)

func is_highlighted():
	return highlight

## Functions ##

func adjoins(some_letter):
	""" Helper to check the letter is adjacent to the one given as argument """
	var distance = self.get_pos() - some_letter.get_pos()
	# FIXME: Dehardcode those ugly numbers, ideally expose coordinates from letter_grid
	return (abs(distance.x) < 61 and abs(distance.y) < 61)

func select():
	""" Handles an attempt at (un)selecting the letter """
	emit_signal("letter_selected", self)

func reset():
	""" Resets letter node to default visual state """
	set_highlight(false)
	get_node("outline").hide()
	get_node("animation").stop()
