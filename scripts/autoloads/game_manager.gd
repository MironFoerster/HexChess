extends Node


var map_generator: MapGenerator

func create_battle():
	# TODO eventually all battle configs and campaign squad should be passed here
	
	var squads: Dictionary[int, Squad] = {
		0: Squad.new("", 1, {
				0: Unit.new(0, 0, Types.UnitType.WARRIOR, Vector2i(0, 0), 10, [], []),
				1: Unit.new(1, 0, Types.UnitType.WARRIOR, Vector2i(1, 0), 5, [], []),
			})
	}
	var battle: Battle = Battle.new(false, "private", -1, squads, 0, "")
	
	# give the battle_scene references to already existing nodes it should use,
	# instead of creating new ones
	var battle_scene: BattleScene = get_tree().current_scene.get_node("BattleContainer/Battle")
	battle_scene.initialize(null, {})
	
	# pass the newly created battle to BattleManager.
	# This also triggers battle_scene to create/reuse all visuals.
	BattleManager.set_battle(battle)
