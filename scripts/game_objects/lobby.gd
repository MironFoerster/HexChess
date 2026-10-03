extends RefCounted
class_name Lobby

var type: String # private / public / local
var online: bool
var mode_name: String
var admin_id: int
var players: Dictionary[int, Player] # player_id : player_object
var lobby_code: int
var units: Dictionary[int, BattleUnit] # unit_id : unit_object
var map: Map

var units_by_id: Dictionary[int, BattleUnit] = {}
var unit_ids_by_coords: Dictionary[Vector2i, int] = {}
var unit_ids_by_owner_id: Dictionary[int, Array] = {}

var _next_player_id: int = 0
var _next_unit_id: int = 0


### Signals that the battle emits to notify the game when the state has changed ###
signal player_added(player: Player)




### UPDATE METHODS, usually called by BattleManager ###
func add_player(player: Player): # TODO what: id is not only peer_id, because function is also used for local player adding
	players[player.player_id] = player
	player_added.emit()
	
func create_player(_name: String):
	var player = Player.new(_next_player_id, _name)
	_next_player_id += 1
	
	players[player.player_id] = player
	player_added.emit()
	return player

func start():
	pass
	#battle_started.emit()TODO

func set_map(_map: Map):
	print("Map set!")
	map = _map
	#map_updated.emit()TODO



### INTERNAL LOGIC METHODS ###


### EFFECT APPLIERS ###


### INFORMAION RETRIEVAL for battle scene ###
func get_ability_allowed_cells(unit_id: int, ability_type: Types.AbilityType) -> Array[Vector2i]:
	var ability_data = DataCatalog.abilities[ability_type]
	var allowed_cells: Array[Vector2i]
	for step: Vector2i in ability_data.target_pattern.base_steps:
		for multiple in range(ability_data.target_pattern.multiples):
			allowed_cells.append(step)
			step = step + step # TODO: is this defined for vector2?
	
	# TODO: remove unreachable or already used cells
	return allowed_cells
	
func get_unit_abilities(unit_id: int) -> Array[Ability]:
	var abilities: Array[Ability] = []
	for ability_type in DataCatalog.units[units_by_id[unit_id].unit_type].abilities:
		abilities.append(Ability.new(ability_type, get_ability_allowed_cells(unit_id, ability_type), true))
		
	return abilities











func _init(_online: bool = false, _type: String = "public", _admin_id: int = -1, _players: Dictionary[int, Player] = {}, _lobby_code: int = 0, _mode_name: String = "") -> void:
	online = _online
	type = _type
	admin_id = _admin_id
	players = _players
	lobby_code = _lobby_code
	mode_name = _mode_name
	
func to_dict() -> Dictionary[StringName, Variant]:
	var _players = {}
	for key in players.keys():
		_players[key] = players[key].to_dict()
		
	return {
		"mode_name": mode_name,
		"online": online,
		"type": type,
		"admin_id": admin_id,
		"players": _players,
		"lobby_code": lobby_code
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Battle:
	var battle = Battle.new()
	
	var _players: Dictionary[int, Player] = {}
	for key in data["players"].keys():
		_players[key] = Player.from_dict(data["players"][key])

	battle.mode_name = data.get("mode_name", "")
	battle.online = data.get("online", false)
	battle.type = data.get("type", "public")
	battle.admin_id = data.get("admin_id", -1)
	battle.players = _players
	battle.lobby_code = data.get("lobby_code", "")
	return battle
