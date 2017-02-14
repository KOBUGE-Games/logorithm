extends Node

const LanguagePack = preload("res://shared/language_pack.gd")

## State variables ##

var loaded_packs = {}
var packs = {}

## Callbacks ##

func _ready():
	register_language_pack("en", "res://shared/languages/en.txt")

## Methods ##

func register_language_pack(language, path):
	""" Registers a language pack, therefore noting it is available """
	packs[language] = path

func get_language_pack(language):
	""" Gets a language pack from cache; loads it if it isn't present yet """
	if !loaded_packs.has(language):
		load_language_pack(language)
	return loaded_packs[language]

func load_language_pack(language):
	""" Loads a language pack registered with register_language_pack into cache """
	assert(packs.has(language))
	var language_pack = LanguagePack.new()
	language_pack.parse_file(packs[language])
	loaded_packs[language] = language_pack
