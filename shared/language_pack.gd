extends Reference # Would be nice if this could be a Resource

## State variables ##

var words = {}
var character_list = []
var character_counts = {}
var total_character_count = 0.0

## Methods ##

func add_word(word, count_characters = false):
	""" Add a word to the dictionary """
	words[word] = true

	if count_characters:
		for char in word:
			if !character_counts.has(char):
				character_counts[char] = 0.0
				character_list.push_back(char)
			character_counts[char] += 1.0
			total_character_count += 1.0

func has_word(word):
	return (word in words)

func pick_random_character():
	""" Pick a character from the available characters, respecting frequencies """
	var picked = randf() * total_character_count
	for char in character_list:
		picked -= character_counts[char]
		if picked <= 0:
			return char
	return ""

func get_character_list():
	""" Get the language's character list """
	return character_list

# FIXME: Rename to load when possible
func parse_file(path, min_word_length = 3, max_word_length = 100):
	""" Parse a language pack file, filtering only words between min_word_length and max_word_length """
	var count_characters = true
	var file_part = 0

	var file = File.new()
	file.open(path, File.READ)

	while !file.eof_reached():
		var line = file.get_line()

		if line == "" or line.begins_with("//"):
			pass

		elif line == "---":
			file_part += 1
			continue

		elif file_part == 1: # Header
			var parts = line.split(":")

			if parts.size() == 2 and parts[0].begins_with("#"):
				count_characters = false

				var char = parts[0].right(1)
				if !character_counts.has(char):
					character_counts[char] = 0.0
					character_list.push_back(char)

				character_counts[char] += float(parts[1].strip_edges())
				total_character_count += float(parts[1].strip_edges())

			else:
				print("Invalid header line: ", line)

		else: # Outside of any other parts of the file
			var word = line.strip_edges()
			if word.length() >= min_word_length and word.length() <= max_word_length:
				add_word(word, count_characters)

	#print(generate_header())

func generate_header():
	""" Generates a header from the parsed language pack, useful for maintainers """
	var header = ""
	character_list.sort()
	for char in character_list:
		header += "#%s: %s\n" % [char, character_counts[char]]
	return "---\n%s\n---" % header
