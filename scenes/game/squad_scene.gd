class_name SquadScene
extends Node


var squad_id : int
var units: Dictionary[int, UnitScene]

func _ready():
	pass

func initialize(_squad_id: int, _units: Dictionary[int, UnitScene]):
	squad_id = _squad_id
	units = _units
	for unit_id in units:
		add_child(units[unit_id])

func add_unit(unit: UnitScene):
	units[unit.unit_id] = unit
	add_child(unit)
