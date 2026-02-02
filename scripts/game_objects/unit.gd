extends Object
class_name Unit

var unit_type: String
var feature: String
var status: Array[Status] = []
var items: Array[Item] = []

func _init(_unit_type: String = "", _feature: String = "", _status: Array[Status] = [], _items: Array[Item] = []):
	unit_type = _unit_type
	feature = _feature
	status = _status.duplicate()  # ensure we get a copy
	items = _items.duplicate()    # ensure we get a copy

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"unit_type": unit_type,
		"feature": feature,
		"status": status.map(func (s): s.to_dict()),  # assuming Status has to_dict()
		"items": items.map(func (i): i.to_dict())     # assuming Item has to_dict()
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Cell:
	var cell = Cell.new()
	cell.unit_type = data.get("unit_type", "")
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
