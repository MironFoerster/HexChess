extends Object
class_name Player

var name: String
var is_temp: bool
var rank: int

func _init(_name: String = "", _is_temp: bool = true, _rank: int = 0):
	name = _name
	is_temp = _is_temp
	rank = _rank

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"name": name,
		"is_temp": is_temp,
		"rank": rank
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Player:
	var player = Player.new()
	player.name = data.get("name", "")
	player.is_temp = data.get("is_temp", false)
	player.rank = data.get("rank", 0)
	return player
