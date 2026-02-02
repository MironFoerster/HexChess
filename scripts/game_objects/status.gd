extends Object
class_name Status

var status_type: String
var duration_left: int

func _init(_status_type: String = "", _duration_left: int = 0):
	status_type = _status_type
	duration_left = _duration_left

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"status_type": status_type,
		"duration_left": duration_left
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Cell:
	var status = Status.new()
	status.status_type = data.get("status_type", "")
	status.duration_left = data.get("duration_left", 0)
	
	return status
