extends Object
class_name Battle

var type: String # private / public / local
var mode_name: String
var admin_id: int
var players: Dictionary[int, Player] # player_id : player_object
var game_code: int
var units: Dictionary[int, Unit] # unit_id : unit_object
var map: Map
# used to check if a update from the server was missed
#var state_date: int

var player_turn = -1

var units_by_id: Dictionary[int, Unit] = {}
var units_by_coords: Dictionary[Vector2i, Unit] = {}
var _next_unit_id := 0

### Signals that the battle emits to notify the game when the state has changed ###
signal player_added(player: Player)
signal game_started()
signal map_updated()




### functions that change the state. the server uses these to update the battle. only called through global networking ###
func add_player(id: int, player: Player): # id is not only peer_id, because function is also used for local player adding
	players[id] = player
	player_added.emit()

func start_game():
	# TODO: set running-flag? what for?
	game_started.emit()

func set_map(_map: Map):
	print("Map set!")
	map = _map
	map_updated.emit()

func execute_command(command: Command):
	if type == "local":
		var root_effect: Effect = Effect.new()
		root_effect.child_effects = _get_command_effects(command)
		_resolve_effect_tree(root_effect)
		_apply_effect(root_effect)
		
	elif GlobalNetworking._connected_to_server(): # type == private online/public online
		GlobalNetworking._execute_command.rpc_id(1, command.to_dict())
	else:
		push_error("[CLIENT] Abort: online battle but not connected to server.")

func _get_command_effects(command: Command):
	var effects: Array[Effect] = []
	match command.command_type:
		"spawn_unit":
			effects.append(Effect.new("spawn_unit"))
	return effects

func _resolve_effect_tree(effect: Effect): # fills in the Effect-Tree IN PLACE
	_apply_effect(effect)
	
	match effect.effect_type:
		"spawn_unit":
			if not effect.target_cell_coordinates.y > 5:
				var extra_spawn: Effect = effect.duplicate()
				extra_spawn.target_cell_coordinates += Vector2i(1, 1)
				effect.child_effects.append(extra_spawn)
			
	for child_effect in effect.child_effects:
		_resolve_effect_tree(child_effect)
	
func _apply_effect(effect: Effect):
	print("Applying Effect!")
	match effect.effect_type:
		"spawn_unit":
			_spawn_unit(effect.target_coords, Unit.new(effect.unit_type))
	
	for child_effect in effect.child_effects:
		_apply_effect(child_effect)




func _spawn_unit(coords: Vector2i, unit: Unit): # TODO wo wird unit erstellt, wo mit id versehen, wo mit coords, status etc
	unit.id = _next_unit_id
	_next_unit_id += 1
	unit.coords = coords

	units_by_id[unit.id] = unit
	units_by_coords[coords] = unit
	return unit

func move_unit(unit: Unit, new_coords: Vector2i) -> void:
	units_by_coords.erase(unit.coord)
	unit.coords = new_coords
	units_by_coords[new_coords] = unit


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











func _init(_type: String = "public", _admin_id: int = -1, _players: Dictionary[int, Player] = {}, _game_code: int = 0, _mode_name: String = "") -> void:
	type = _type
	admin_id = _admin_id
	players = _players
	game_code = _game_code
	mode_name = _mode_name
	
func to_dict() -> Dictionary[StringName, Variant]:
	var _players = {}
	for key in players.keys():
		_players[key] = players[key].to_dict()
		
	return {
		"mode_name": mode_name,
		"type": type,
		"admin_id": admin_id,
		"players": _players,
		"game_code": game_code
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Battle:
	var battle = Battle.new()
	
	var _players: Dictionary[int, Player] = {}
	for key in data["players"].keys():
		_players[key] = Player.from_dict(data["players"][key])

	battle.mode_name = data.get("mode_name", "")
	battle.type = data.get("type", "public")
	battle.admin_id = data.get("admin_id", -1)
	battle.players = _players
	battle.game_code = data.get("game_code", "")
	return battle
