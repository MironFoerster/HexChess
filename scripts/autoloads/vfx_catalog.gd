extends Node


var vfx: Dictionary[StringName, PackedScene] = {}

func _ready():
	vfx = _load_entries("res://scenes/vfx")

func _load_entries(path: String) -> Dictionary[StringName, PackedScene]:
	var dict: Dictionary[StringName, PackedScene] = {}
	var dir := DirAccess.open(path)
	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(".tscn") or file_name.ends_with(".scn"):
				var scene: PackedScene = load(path.path_join(file_name))
				if scene:
					dict[file_name.get_basename()] = scene
	return dict
