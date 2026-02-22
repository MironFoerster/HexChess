class_name Effect
extends RefCounted


var effect_type: String
var duration: float
var target_cell_coordinates: Vector2i
var data: Dictionary[StringName, Variant]
var child_effects: Array[Effect]

func _init(_effect_type: String = "", _duration: float = 0.0,  _target_cell_coordinates: Vector2i = Vector2i(0, 0), _data: Dictionary[StringName, Variant] = {}):
	effect_type = _effect_type
	duration = _duration
	target_cell_coordinates = _target_cell_coordinates
	data = _data

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"effect_type": effect_type,
		"duration": duration,
		"target_cell_coordinates": target_cell_coordinates,
		"data": data
	}

static func from_dict(dict: Dictionary[StringName, Variant]) -> Effect:
	var effect = Effect.new()
	effect.effect_type = dict.get("effect_type", "")
	effect.duration = dict.get("duration", 0.0)
	effect.target_cell_coordinates = dict.get("target_cell_coordinates", Vector2i(0, 0))
	
	return effect
