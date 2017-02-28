tool
extends Node2D

## Exports ##

export(String) var character = "A" setget set_character, get_character
export(Color) var backdrop_color = Color(0.15, 0.15, 0.17, 1)
export(Color) var highlight_color = Color(0.40, 0.40, 0.30, 1)
export(bool) var highlight = false setget set_highlight, is_highlighted
export(Vector2) var next_direction = Vector2(0, 0) setget set_next_direction, get_next_direction
export(float) var animation_acceleration = 1

## State Variables ##

var position = Vector2()
var animation_position_target = Vector2()
var animation_velocity = Vector2()

## Nodes ##

onready var backdrop = get_node("backdrop")
onready var label = get_node("label")
onready var animation = get_node("animation")
onready var outline = get_node("outline")
onready var marker = get_node("marker")

## Callbacks ##

func _ready():
	animation_position_target = get_pos()
	set_character(character)
	set_highlight(false)
	set_next_direction(next_direction)

func _process(delta):
	var new_position = get_pos() + animation_velocity * delta
	var direction = (animation_position_target - get_pos()).normalized()
	var new_direction = (animation_position_target - new_position).normalized()

	if direction.dot(new_direction) < -0.5: # If the direction reverses, we must have passed the target
		set_pos(animation_position_target) # Snap
		animation_velocity = Vector2()
		set_process(false)
	else:
		set_pos(new_position)
		animation_velocity += direction * animation_acceleration * delta

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
	""" Sets the highlight state """
	highlight = new_highlight
	if backdrop:
		backdrop.set_frame_color(highlight_color if highlight else backdrop_color)

func is_highlighted():
	""" Gets the highlight state """
	return highlight


func set_next_direction(new_next_direction):
	""" Set the direction to the next letter in the chain """
	next_direction = new_next_direction
	if marker:
		marker.set_pos(next_direction * backdrop.get_size() / 2)
		marker.set_rot(Vector2(0, -1).angle_to(next_direction))
		marker.set_hidden(next_direction.length_squared() < 0.01)

func get_next_direction():
	""" Get the direction to the next letter in the chain """
	return next_direction


## Functions ##

func adjoins(some_letter):
	""" Helper to check the letter is adjacent to the one given as argument """
	var distance = self.position - some_letter.position
	return (abs(distance.x) < 1.01 and abs(distance.y) < 1.01) and self != some_letter

func is_moving():
	""" Helper to check if the letter is currently moving (to disable selection) """
	var distance = animation_position_target - get_pos()
	return (abs(distance.x) > 0.01 or abs(distance.y) > 0.01)

func animate_to(target):
	animation_position_target = target
	set_process(is_moving())

func reset():
	""" Resets letter node to default visual state """
	set_highlight(false)
	set_next_direction(Vector2())
	outline.hide()
	animation.stop()
