extends Object
class_name Session

var type: String # private / public / local
var mode_name: String
var admin_id: int
var players: Dictionary[int, Player] # player_id : player_object
var game_code: int
var node_name: String # TODO whats this?
var units: Dictionary[StringName, Unit] # unit_id : unit_object
var map: Map
# used to check if a update from the server was missed
#var state_date: int

var player_turn = -1

### Signals that the session emits to notify the game when the state has changed ###
signal player_added(player: Player)
signal game_started()
signal map_updated()
signal action_performed(unit: Unit, action: Action, derived_effects: Array[Effect])


### functions that change the state. the server uses these to update the session. only called through global networking ###
func add_player(id: int, player: Player): # id is not only peer_id, because function is also used for local player adding
	players[id] = player
	player_added.emit(player)

func start_game():
	# TODO: set running-flag? what for?
	game_started.emit()

func set_map(_map: Map):
	map = _map.duplicate()
	map_updated.emit()


### functions that DONT change the state. pure information retrieval used by the game scene ###
func get_ability_allowed_cells(unit_id: StringName, ability_type: StringName) -> Array[Vector2]:
	var ability_data = DataCatalog.abilities[ability_type]
	var allowed_cells: Array[Vector2]
	for step: Vector2 in ability_data.target_pattern.base_steps:
		for multiple in range(ability_data.target_pattern.multiples):
			allowed_cells.append(step)
			step = step + step # TODO: is this defined for vector2?
	
	# TODO: remove unreachable or already used cells
	return allowed_cells



func _init(_type: String = "public", _admin_id: int = -1, _players: Dictionary = {}, _game_code: int = 0, _node_name: String = "") -> void:
	type = _type
	admin_id = _admin_id
	players = _players
	game_code = _game_code
	node_name = _node_name
	
func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"node_name": node_name,
		"type": type,
		"admin_id": admin_id,
		"players": players,
		"game_code": game_code
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Session:
	var session = Session.new()
	session.node_name = data.get("node_name", "")
	session.type = data.get("type", "public")
	session.admin_id = data.get("admin_id", -1)
	session.players = data.get("players", {})
	session.game_code = data.get("game_code", "")
	return session
