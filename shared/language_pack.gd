extends Reference # Would be nice if this could be a Resource

## State variables ##

var md5sum = ""
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

func get_character_frequency(char):
	""" Return the frequency of a given character """
	return character_counts[char] / total_character_count

func save_binary(binary_path):
	""" Save language pack to a binary file """
	var file = File.new()
	var err = file.open(binary_path, File.WRITE)
	if err:
		print("Could not save binary LanguagePack at '%s'.")
		return err

	file.store_var(md5sum)
	file.store_var(words)
	file.store_var(character_list)
	file.store_var(character_counts)
	file.store_var(total_character_count)
	file.close()

	print("LanguagePack: Saved binary '%s' with md5sum '%s'." % [binary_path, md5sum])

func load_binary(binary_path):
	""" Load language pack from a binary file """
	var file = File.new()
	var err = file.open(binary_path, File.READ)
	if err:
		print("Could not load binary LanguagePack at '%s'.")
		return err

	# The read order should be the same as the save order in save_binary
	md5sum = file.get_var()
	words = file.get_var()
	character_list = file.get_var()
	character_counts = file.get_var()
	total_character_count = file.get_var()
	file.close()

	print("LanguagePack: Loaded binary '%s' with md5sum '%s'." % [binary_path, md5sum])
	return OK

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
	file.close()

	md5sum = file.get_md5(path)

	#print(generate_header())

func generate_header():
	""" Generates a header from the parsed language pack, useful for maintainers """
	var header = ""
	character_list.sort()
	for char in character_list:
		header += "#%s: %s\n" % [char, character_counts[char]]
	return "---\n%s\n---" % header
