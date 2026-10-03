extends RefCounted
class_name Squad

var saved_squad_id: int = -1
var squad_id: int

var royal_house_name: StringName = ""
var active_royal_choice: int = -1
var units: Array[Unit] = []


func _init(
	_royal_house_name: StringName = "",
	_active_royal_choice: int = -1,
	_units: Array[Unit] = [],
):
	royal_house_name = _royal_house_name
	active_royal_choice = _active_royal_choice
	units = _units


func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"royal_house_name": royal_house_name,
		"active_royal_choice": active_royal_choice,
		"units": units.map(func (u): u.to_dict())     # assuming Item has to_dict()
	}


static func from_dict(dict: Dictionary[StringName, Variant]) -> BattleUnit:
	
	var dicts_array = dict.get("units", [])
	var _units = []
	for squad_unit_dict in dicts_array:
		_units.append(Unit.from_dict(squad_unit_dict))
		
	var unit = BattleUnit.new(
		dict.get("royal_house_name", ""),
		dict.get("active_royal_choice", -1),
		_units
	)

	return unit
