tool 
extends Node2D

## Exports ##

export(String) var character = "A" setget set_character, get_character
export(bool) var highlight = false setget set_highlight, is_highlighted

## Nodes ##

onready var backdrop = get_node("backdrop")
onready var label = get_node("label")

## Callbacks ##

func _ready():
	set_character(character)

## Getters/Setters ##

func set_character(new_character):
	""" Sets the character displayed of the letter """
	character = new_character
	if label: # Might get called while still outside the tree
		label.set_text(character.to_upper())

func get_character(new_character):
	""" Gets the character last set by set_character """
	return character

func set_highlight(new_highlight):
	highlight = new_highlight
	if backdrop:
		backdrop.set_hidden(highlight)

func is_highlighted():
	return highlight
