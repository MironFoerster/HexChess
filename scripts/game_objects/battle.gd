extends Object
class_name Battle

var type: String # private / public / local
var online: bool
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
signal battle_started()
signal map_updated()
signal effect_tree_applied(effect_tree: Effect)




### UPDATE METHODS, usually called by BattleManager ###
func add_player(id: int, player: Player): # TODO what: id is not only peer_id, because function is also used for local player adding
	players[id] = player
	player_added.emit()

func start():
	battle_started.emit()

func set_map(_map: Map):
	print("Map set!")
	map = _map
	map_updated.emit()

func execute_command(command: Command):
	var root_effect: Effect = Effect.new()
	root_effect.child_effects = _get_command_effects(command)
	
	_resolve_and_apply_effect_tree(root_effect)
	
	effect_tree_applied.emit(root_effect)





### INTERNAL LOGIC METHODS ###
func _get_command_effects(command: Command):
	var effects: Array[Effect] = []
	match command.command_type:
		"spawn_unit":
			effects.append(Effect.new("spawn_unit"))
	return effects

func _resolve_and_apply_effect_tree(effect_tree: Effect): # fills in the Effect-Tree IN PLACE
	# 1. Flatten the root effect tree into a time queue of effects
	var effect_time_queue: Dictionary[float, Array] = {}
	_effect_tree_to_time_queue(effect_tree, effect_time_queue, 0.0)
	
	# 2. while-loop through time queue, apply effects, add resulting child effects to time queue
	var current_time: float = 0.0
	var current_effect: Effect
	while !effect_time_queue.is_empty():
		# skip empty buckets
		while !effect_time_queue.has(current_time):
			current_time += 0.1
		
		# get next timed effect
		current_effect = effect_time_queue[current_time].pop_back() # TODO is front more efficient??
		# remove bucket if now empty
		if effect_time_queue[current_time].is_empty():
			effect_time_queue.erase(current_time)
		
		# apply effect, get child effects
		var child_effects: Array[Effect] = apply_effect(current_effect)
		# add child effects to effect tree (the effect itself) for the visualization
		current_effect.child_effects = child_effects
		# add child effects to time queue (for further timed simulation)
		var child_time = current_time + current_effect.duration
		for child_effect in child_effects:
			add_effect_to_time_queue(effect_time_queue, child_time, child_effect)


func _effect_tree_to_time_queue(effect_tree: Effect, effect_time_queue: Dictionary[float, Array], current_time: float):
	add_effect_to_time_queue(effect_time_queue, current_time, effect_tree)
	
	for child_effect in effect_tree.child_effects:
		_effect_tree_to_time_queue(child_effect, effect_time_queue, current_time+effect_tree.duration)

func add_effect_to_time_queue(time_queue: Dictionary[float, Array], time: float, effect: Effect):
	if !time_queue.has(time):
		time_queue[time] = []
	time_queue[time].append(effect)
	
func apply_effect(effect: Effect) -> Array[Effect]:
	print("Applying Effect!")
	match effect.effect_type:
		"spawn_unit":
			# apply
			_spawn_unit(effect.target_coords, effect.data.unit_type)
			# compute children
			if not effect.target_coords.y > 5:
				var extra_spawn: Effect = effect.duplicate()
				extra_spawn.target_coords += Vector2i(1, 1)
				# return child effects
				return [extra_spawn]
	return []






### EFFECT APPLLIERS ###
func _spawn_unit(coords: Vector2i, unit_type: StringName):
	var unit: Unit = Unit.new(unit_type)
	unit.id = _next_unit_id
	_next_unit_id += 1
	unit.coords = coords

	units_by_id[unit.id] = unit
	units_by_coords[coords] = unit
	return unit

func _move_unit(unit: Unit, new_coords: Vector2i) -> void:
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











func _init(_online: bool = false, _type: String = "public", _admin_id: int = -1, _players: Dictionary[int, Player] = {}, _game_code: int = 0, _mode_name: String = "") -> void:
	online = _online
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
		"online": online,
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
	battle.online = data.get("online", false)
	battle.type = data.get("type", "public")
	battle.admin_id = data.get("admin_id", -1)
	battle.players = _players
	battle.game_code = data.get("game_code", "")
	return battle
