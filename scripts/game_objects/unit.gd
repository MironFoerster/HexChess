extends RefCounted
class_name Unit

var unit_id: int = -1
var unit_type: String
var owner_id: int
var coords: Vector2i
var health: int
var status: Array[Status] = []
var items: Array[Item] = []


func _init(
	_unit_type: String = "",
	_coords: Vector2i = Vector2i(0, 0),
	_owner_id: int = -1,
	_health: int = 0,
	_status: Array[Status] = [],
	_items: Array[Item] = []
):
	unit_type = _unit_type
	coords = _coords
	owner_id = _owner_id
	health = _health
	status = _status.duplicate()  # ensure we get a copy
	items = _items.duplicate()    # ensure we get a copy


func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"unit_id": unit_id,
		"unit_type": unit_type,
		"owner_id": owner_id,
		"coords": coords,
		"health": health,
		"status": status.map(func (s): s.to_dict()),  # assuming Status has to_dict()
		"items": items.map(func (i): i.to_dict())     # assuming Item has to_dict()
	}


static func from_dict(dict: Dictionary[StringName, Variant]) -> Unit:
	var unit = Unit.new()

	unit.unit_id = dict.get("unit_id", -1)
	unit.unit_type = dict.get("unit_type", "")
	unit.owner_id = dict.get("owner_id", -1)
	unit.coords = dict.get("coords", Vector2i(0, 0))
	unit.health = dict.get("health", 0)

	# Reconstruct arrays of Status and Item
	var status_array = dict.get("status", [])
	unit.status.clear()
	for status_dict in status_array:
		unit.status.append(Status.from_dict(status_dict))

	var items_array = dict.get("items", [])
	unit.items.clear()
	for item_dict in items_array:
		unit.items.append(Item.from_dict(item_dict))

	return unit
