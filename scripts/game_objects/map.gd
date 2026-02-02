extends Object
class_name Map

var cells: Dictionary[Vector2i, Cell]

func _init():
	pass

func to_dict() -> Dictionary[Vector2i, Variant]:
	var _cells: Dictionary[Vector2i, Variant] = {}
	for key in cells.keys():
		_cells[key] = cells[key].to_dict()

	return _cells


static func from_dict(data: Dictionary[Vector2i, Variant]) -> Map:
	var map = Map.new()

	var _cells: Dictionary[Vector2i, Cell] = {}
	for key in data.keys():
		_cells[key] = data[key].from_dict()

	map.cells = _cells
	return map
