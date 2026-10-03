extends RefCounted
class_name Ability

var ability_type: Types.AbilityType
var allowed_target_coords: Array[Vector2i]
var usable: bool

func _init(_ability_type: Types.AbilityType = -1, _allowed_target_coords: Array[Vector2i] = [], _usable: bool = false):
	ability_type = _ability_type
	# Using duplicate() to ensure the array is passed by value, not reference
	allowed_target_coords = _allowed_target_coords.duplicate()
	usable = _usable

func to_dict() -> Dictionary:
	return {
		"ability_type": Types.AbilityType.keys()[ability_type],
		"allowed_target_coords": allowed_target_coords,
		"usable": usable
	}

static func from_dict(dict: Dictionary) -> Ability:
	var ability = Ability.new()
	
	ability.ability_type = Types.AbilityType[dict.get("ability_type", -1)] # TODO make all type dumps like that
	
	# Handle the Array[Vector2i] reconstruction
	var coords = dict.get("allowed_target_coords", [])
	ability.allowed_target_coords.clear()
	for c in coords:
		if c is Vector2i:
			ability.allowed_target_coords.append(c)
	
	ability.usable = dict.get("usable", false)
	
	return ability
