extends Object
class_name Status

var data_id: String
var duration_left: int

func _init(_data_id: String = "", _duration_left: int = 0):
	data_id = _data_id
	duration_left = _duration_left

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"data_id": data_id,
		"duration_left": duration_left
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Cell:
	var status = Status.new()
	status.data_id = data.get("data_id", "")
	status.duration_left = data.get("duration_left", 0)
	
	return status
