extends Object
class_name Command

var command_type: String
var target_coords: Vector2i

func _init(_command_type: String = "", _target_coords: Vector2i = Vector2i(0, 0)):
	command_type = _command_type
	target_coords = _target_coords

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"command_type": command_type,
		"target_coords": target_coords
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Command:
	var command = Command.new()
	command.command_type = data.get("command_type", "")
	command.target_coords = data.get("target_coords", Vector2i(0, 0))
	
	return command
