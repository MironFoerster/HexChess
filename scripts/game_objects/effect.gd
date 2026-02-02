extends Object
class_name Effect

var effect_type: String
var target_cell_coordinates: Vector2

func _init(_effect_type: String = "", _target_cell_coordinates: Vector2 = Vector2(0, 0)):
	effect_type = _effect_type
	target_cell_coordinates = _target_cell_coordinates

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"effect_type": effect_type,
		"target_cell_coordinates": target_cell_coordinates
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Action:
	var effect = Effect.new()
	effect.effect_type = data.get("effect_type", "")
	effect.target_cell_coordinates = data.get("target_cell_coordinates", Vector2(0, 0))
	
	return effect
