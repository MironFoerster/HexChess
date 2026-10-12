extends RefCounted
class_name Unit

var unit_id: int
var squad_id: int

var unit_type: Types.UnitType
var coords: Vector2i
var health: int
var status: Array[Status] = []
var items: Array[Item] = []

var level: int

func _init(
	_unit_id: int = -1,
	_squad_id: int = -1,
	_unit_type: Types.UnitType = Types.UnitType.WARRIOR, # TODO something more sensible as default
	_coords: Vector2i = Vector2i(0, 0),
	_health: int = 0,
	_status: Array[Status] = [],
	_items: Array[Item] = [],
	_level: int = 0
):
	unit_id = _unit_id
	squad_id = _squad_id
	unit_type = _unit_type
	level = _level
	coords = _coords
	health = _health
	status = _status.duplicate()  # ensure we get a copy
	items = _items.duplicate()    # ensure we get a copy


func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"unit_id": unit_id,
		"unit_type": unit_type,
		"level": level,
	}


static func from_dict(dict: Dictionary[StringName, Variant]) -> Unit:
	var squad_unit = Unit.new(
		dict.get("unit_id", -1),
		dict.get("unit_type", ""),
		dict.get("level", 0),
	)

	return squad_unit
