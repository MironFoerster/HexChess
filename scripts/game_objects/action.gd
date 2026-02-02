extends Object
class_name Action

var action_type: String
var target_cell_coordinates: Vector2

func _init(_action_type: String = "", _target_cell_coordinates: Vector2 = Vector2(0, 0)):
	action_type = _action_type
	target_cell_coordinates = _target_cell_coordinates

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"action_type": action_type,
		"target_cell_coordinates": target_cell_coordinates
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Action:
	var action = Action.new()
	action.action_type = data.get("action_type", "")
	action.target_cell_coordinates = data.get("target_cell_coordinates", Vector2(0, 0))
	
	return action
