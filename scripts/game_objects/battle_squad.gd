extends RefCounted
class_name BattleSquad

var lobby_player_id: int = -1
var display_name: String
var is_ai_controlled: bool

var battle_squad_id: int

var leader_pair_name: StringName = ""
var active_leader_choice: int = -1
var squad_units: Array[BattleUnit] = []


func _init(
	_leader_pair_name: StringName = "",
	_active_leader_choice: int = -1,
	_squad_units: Array[BattleUnit] = [],
):
	leader_pair_name = _leader_pair_name
	active_leader_choice = _active_leader_choice
	squad_units = _squad_units


func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"leader_pair_name": leader_pair_name,
		"active_leader_choice": active_leader_choice,
		"squad_units": squad_units.map(func (su): su.to_dict())     # assuming Item has to_dict()
	}


static func from_dict(dict: Dictionary[StringName, Variant]) -> BattleSquad:
	
	var dicts_array = dict.get("squad_units", [])
	var _squad_units = []
	for squad_unit_dict in dicts_array:
		_squad_units.append(BattleSquad.from_dict(squad_unit_dict))
		
	var unit = BattleSquad.new(
		dict.get("leader_pair_name", ""),
		dict.get("active_leader_choice", -1),
		_squad_units
	)

	return unit
