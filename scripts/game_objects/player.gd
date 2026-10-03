extends RefCounted
class_name Player

var player_id: int
var user_id: int = -1
var name: String
var is_temp: bool

var reconnect_token: int

func _init(_player_id: int, _name: String = "", _is_temp: bool = true):
	player_id = _player_id
	name = _name
	is_temp = _is_temp

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"player_id": player_id,
		"name": name,
		"is_temp": is_temp,
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Player:
	var player = Player.new(
		data.get("player_id", -1),
		data.get("name", ""),
		data.get("is_temp", false),
		)

	return player
