extends Object
class_name Cell

var terrain_data_id: String
var feature: String
var status: Array[Status] = []
var items: Array[Item] = []

func _init(_terrain_data_id: String = "", _feature: String = "", _status: Array[Status] = [], _items: Array[Item] = []):
	terrain_data_id = _terrain_data_id
	feature = _feature
	status = _status.duplicate()  # ensure we dont pass by reference
	items = _items.duplicate()    # ensure we dont pass by reference

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"terrain_data_id": terrain_data_id,
		"feature": feature,
		"status": status.map(func (s): s.to_dict()),
		"items": items.map(func (i): i.to_dict())
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Cell:
	var cell = Cell.new()
	cell.terrain_data_id = data.get("terrain_data_id", "")
	cell.feature = data.get("feature", "")
	
	# Reconstruct arrays of Status and Item
	var status_array = data.get("status", [])
	cell.status = []
	for s_data in status_array:
		cell.status.append(Status.from_dict(s_data))
	
	var items_array = data.get("items", [])
	cell.items = []
	for i_data in items_array:
		cell.items.append(Item.from_dict(i_data))
	
	return cell
