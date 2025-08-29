extends Resource
class_name SessionData

var node_name: String
var type: String # private / public
var admin_id: int
var player_ids: Array[int]
var game_code: String

func _init(_node_name: String, _type: String, _admin_id: int, _player_ids: Array[int], _game_code: String) -> void:
	node_name = _node_name
	type = _type
	admin_id = _admin_id
	player_ids = _player_ids
	game_code = _game_code
