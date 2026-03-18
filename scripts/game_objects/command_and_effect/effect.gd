class_name Effect
extends RefCounted


var effect_type: String
var duration: int  # in tenth of seconds
var target_coords: Vector2i
var data: Dictionary[StringName, Variant]
var child_effects: Array[Effect] = []

func _init(_effect_type: String = "", _duration: int = 0,  _target_coords: Vector2i = Vector2i(0, 0), _data: Dictionary[StringName, Variant] = {}):
	effect_type = _effect_type
	duration = _duration
	target_coords = _target_coords
	data = _data

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"effect_type": effect_type,
		"duration": duration,
		"target_coords": target_coords,
		"data": data,
		"child_effects": child_effects.map(func (e): e.to_dict()),
	}

static func from_dict(dict: Dictionary[StringName, Variant]) -> Effect:
	var effect = Effect.new()
	effect.effect_type = dict.get("effect_type", "")
	effect.duration = dict.get("duration", 0)
	effect.target_coords = dict.get("target_coords", Vector2i(0, 0))
	effect.data = dict.get("data", {})
	
	# Reconstruct arrays of Status and Item
	var effect_array = dict.get("child_effects", [])
	effect.child_effects.clear()
	for effect_dict in effect_array:
		effect.child_effects.append(Status.from_dict(effect_dict))
	
	return effect
