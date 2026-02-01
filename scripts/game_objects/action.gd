extends Object
class_name Action

var data_id: String
var target_cell_coordinates: Vector2

func _init(_data_id: String = "", _target_cell_coordinates: Vector2 = Vector2(0, 0)):
	data_id = _data_id
	target_cell_coordinates = _target_cell_coordinates

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"data_id": data_id,
		"target_cell_coordinates": target_cell_coordinates
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Action:
	var action = Action.new()
	action.data_id = data.get("data_id", "")
	action.target_cell_coordinates = data.get("target_cell_coordinates", Vector2(0, 0))
	
	return action
