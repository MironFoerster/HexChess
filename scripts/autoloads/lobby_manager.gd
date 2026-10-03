extends Node


@onready var battle_scene

var lobby: Lobby
var map_generator: MapGenerator
var battle: Battle # TODO dont know if this actually should be here

signal battle_set()

func _ready():
	map_generator = MapGenerator.new()


### SUBMIT METHODS ###

func submit_start_battle():
	if lobby.online:
		pass
		GlobalNetworking.start_battle(battle.lobby_code)
	else:
		lobby.start()




### EXECUTE METHODS ###

func set_battle(_battle: Battle):
	battle = _battle
	battle_set.emit()

func add_player(player: Player):
	lobby.add_player(player)

func create_player():
	return lobby.create_player("Player1")
	
func start_battle():
	battle.start()
	SceneManager.page_transition_to("none")
	
func set_map(seed: int):
	var generated_map: Map = map_generator.generate(seed)
	battle.set_map(generated_map)
