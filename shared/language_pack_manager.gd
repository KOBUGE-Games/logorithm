extends Node

const LanguagePack = preload("res://shared/language_pack.gd")

const binary_path = "user://language_pack-%s.res"
const config_path = "user://language_packs.cfg"

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

	var must_parse = true
	if has_valid_binary_pack(language):
		must_parse = language_pack.load_binary(binary_path % language) # returns OK if success

	if must_parse:
		language_pack.parse_file(packs[language])
		language_pack.save_binary(binary_path % language)
		var cfg = ConfigFile.new()
		cfg.load(config_path)
		cfg.set_value("md5sums", language, language_pack.md5sum)
		cfg.save(config_path)

	loaded_packs[language] = language_pack

## Helpers ##

func has_valid_binary_pack(language):
	var file = File.new()
	if !file.file_exists(binary_path % language):
		file.close()
		return false
	file.close()

	var cfg = ConfigFile.new()
	if cfg.load(config_path):
		return false
	var bin_md5sum = cfg.get_value("md5sums", language)
	var src_md5sum = file.get_md5(packs[language])

	return (bin_md5sum == src_md5sum)
