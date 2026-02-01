extends Object
class_name Item

var data_id: String
var durability_left: int
# TODO: EffectData for item effects, status effects, attack effects?

func _init(_data_id: String = "", _durability_left: int = 0, _status: Array[Status] = [], _items: Array[Item] = []):
	data_id = _data_id
	durability_left = _durability_left

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"data_id": data_id,
		"durability_left": durability_left
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Item:
	var cell = Cell.new()
	cell.data_id = data.get("data_id", "")
	cell.durability_left = data.get("durability_left", 0)
	
	return cell
