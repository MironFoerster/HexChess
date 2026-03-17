extends Node


@onready var battle_scene

var battle: Battle

signal battle_set()


### SUBMIT METHODS ###

func submit_start_battle():
	if battle.online:
		GlobalNetworking.start_battle(battle.game_code)
	else:
		battle.start()
	

func submit_command(command: Command):
	if battle.online:
		GlobalNetworking.submit_command(command)
	else:
		battle.execute_command(command)

func submit_end_turn(command: Command):
	if battle.online:
		GlobalNetworking.submit_end_turn(command)
	else:
		battle.end_turn(command)





### EXECUTE METHODS ###

func set_battle(_battle: Battle):
	battle = _battle
	battle_set.emit()

func add_player(player_id: int, player: Player):
	battle.add_player(player_id, player)

func start_battle():
	battle.start()
	SceneManager.page_transition_to("none")
	
func set_map(map: Map):
	battle.set_map(map)
	
func execute_command(command: Command):
	battle.execute_command(command)
	
