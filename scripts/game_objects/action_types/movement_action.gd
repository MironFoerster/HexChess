extends Action
class_name MovementAction



func _init(_type: String = "", _target_cell_coordinates: Vector2 = Vector2(0, 0)):
	type = _type
	target_cell_coordinates = _target_cell_coordinates

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"type": type,
		"target_cell_coordinates": target_cell_coordinates
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Action:
	var action = Action.new()
	action.type = data.get("type", "")
	action.target_cell_coordinates = data.get("target_cell_coordinates", Vector2(0, 0))
	
	return action
