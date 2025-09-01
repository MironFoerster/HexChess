extends Object
class_name SessionData

var node_name: String
var type: String # private / public
var admin_id: int
var player_ids: Array[int]  # used by server
var players: Dictionary  # used by clients
var game_code: String

func _init(_node_name: String = "", _type: String = "public", _admin_id: int = -1, _player_ids: Array[int] = [], _players: Dictionary = {}, _game_code: String = "") -> void:
	node_name = _node_name
	type = _type
	admin_id = _admin_id
	player_ids = _player_ids
	players = _players
	game_code = _game_code

func serialize() -> Dictionary[String, Variant]:
	return {
		"node_name": node_name,
		"type": type,
		"admin_id": admin_id,
		"player_ids": player_ids,
		"players": players,
		"game_code": game_code
	}

static func deserialize(data: Dictionary[String, Variant]) -> SessionData:
	var session = SessionData.new()
	session.node_name = data.get("node_name", "")
	session.type = data.get("type", "public")
	session.admin_id = data.get("admin_id", -1)
	session.player_ids = data.get("player_ids", [])
	session.players = data.get("players", {})
	session.game_code = data.get("game_code", "")
	return session
