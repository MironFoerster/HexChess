# scripts/game_database.gd
extends Node

var abilities: Dictionary[StringName, Resource] = {} #AbilityData
var units: Dictionary[StringName, Resource] = {} #UnitData
var items: Dictionary[StringName, Resource] = {} #ItemData
var terrains: Dictionary[StringName, Resource] = {} #TerrainData

func _ready():
	# Load all resources into the dictionaries
	abilities = _load_entries("res://data/abilities")
	units = _load_entries("res://data/units")
	items = _load_entries("res://data/items")
	terrains = _load_entries("res://data/terrains")

func _load_entries(path: String) -> Dictionary[StringName, Resource]:
	var dict: Dictionary[StringName, Resource] = {}
	var dir := DirAccess.open(path)
	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var resource: Resource = load(path.path_join(file_name))
				if resource:
					dict[file_name.get_basename()] = resource
	return dict
