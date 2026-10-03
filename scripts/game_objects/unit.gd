extends RefCounted
class_name Unit

var unit_id: int

var unit_type: Types.UnitType
var owner_id: int
var level: int

func _init(
	_unit_id: int = -1,
	_unit_type: Types.UnitType = Types.UnitType.WARRIOR, # TODO something more sensible as default
	_owner_id: int = -1,
	_level: int = 0
):
	unit_id = _unit_id
	unit_type = _unit_type
	owner_id = _owner_id
	level = _level


func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"unit_id": unit_id,
		"unit_type": unit_type,
		"owner_id": owner_id,
		"level": level,
	}


static func from_dict(dict: Dictionary[StringName, Variant]) -> Unit:
	var squad_unit = Unit.new(
		dict.get("unit_id", -1),
		dict.get("unit_type", ""),
		dict.get("owner_id", -1),
		dict.get("level", 0),
	)

	return squad_unit
