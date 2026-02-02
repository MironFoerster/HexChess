extends Object
class_name Map

var cells: Dictionary[Vector2i, Cell]

func _init():
	pass
	
func setCell(coords: Vector2i, cell: Cell):
	cells[coords] = cell

func to_dict() -> Dictionary[Vector2i, Variant]:
	var _cells: Dictionary[Vector2i, Variant] = {}
	for key in cells.keys():
		_cells[key] = cells[key].to_dict()

	return _cells


static func from_dict(data: Dictionary[Vector2i, Variant]) -> Map:
	var map = Map.new()

	for key in data.keys():
		map.cells[key] = Cell.from_dict(data[key])

	return map
