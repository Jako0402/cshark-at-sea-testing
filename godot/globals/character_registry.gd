extends Node

var roster: Dictionary[String, CharacterData] = {
	"cshark": preload("res://entities/characters/cshark/cshark.tres"),
	"ocaml": preload("res://entities/characters/ocaml/ocaml.tres")
}

func get_character(id: String) -> CharacterData:
	if roster.has(id):
		return roster[id]
		
	push_warning("Attempted to load invalid character: " + id + ". Defaulting to cshark.")
	return roster["cshark"] # Always have a safe fallback!