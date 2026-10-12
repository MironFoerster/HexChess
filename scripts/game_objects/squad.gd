extends RefCounted
class_name Squad

var squad_id: int

var saved_squad_id: int = -1
var lobby_player_id: int = -1
var display_name: String
var is_ai_controlled: bool

var leader_pair_name: StringName = ""
var active_leader_choice: int = -1
var units: Dictionary[int, Unit] = {}

var next_unit_id = 0

func _init(
	_leader_pair_name: StringName = "",
	_active_leader_choice: int = -1,
	_units: Dictionary[int, Unit] = {},
):
	leader_pair_name = _leader_pair_name
	active_leader_choice = _active_leader_choice
	units = _units
	while next_unit_id in units.keys():
		next_unit_id += 1

func add_unit(unit: Unit): # overwrites unit_id
	units[next_unit_id] = unit
	unit.unit_id = next_unit_id
	while next_unit_id in units.keys():
		next_unit_id += 1


func to_dict() -> Dictionary[StringName, Variant]:
	var _units = {}
	for key in units.keys():
		_units[key] = units[key].to_dict()
	return {
		"leader_pair_name": leader_pair_name,
		"active_leader_choice": active_leader_choice,
		"units": _units
	}


static func from_dict(dict: Dictionary[StringName, Variant]) -> Squad:
	
	var dicts_array = dict.get("units", [])
	var _units = []
	for squad_unit_dict in dicts_array:
		_units.append(Unit.from_dict(squad_unit_dict))
		
	var unit = Unit.new(
		dict.get("leader_pair_name", ""),
		dict.get("active_leader_choice", -1),
		_units
	)

	return unit
