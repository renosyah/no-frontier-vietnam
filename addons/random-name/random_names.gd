extends Node
class_name RandomNameGenerator
# Some syllables commonly found in names (mix of Western + neutral phonetics)
const syllables = [
	"an", "ar", "al", "ben", "dar", "el", "en", "er",
	"fin", "gal", "han", "il", "jon", "ka", "le", "lin",
	"mor", "na", "or", "ra", "rin", "sa", "ta", "thal",
	"ul", "val", "wen"
]

# Optional endings so names feel natural
const  endings = ["a", "e", "i", "o", "u", "ia", "iel", "or", "on", "us"]

static func generate_name(min_syllables: int = 2, max_syllables: int = 3) -> String:
	var name = ""
	var count = randi() % (max_syllables - min_syllables + 1) + min_syllables
	
	for i in range(count):
		name += syllables[randi() % syllables.size()]
	
	# Add ending sometimes
	if randf() < 0.7:
		name += endings[randi() % endings.size()]
	
	# Capitalize first letter
	return name.capitalize()
