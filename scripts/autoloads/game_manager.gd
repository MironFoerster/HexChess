extends Node


var map_generator: MapGenerator

func create_battle():
	# TODO eventually all battle configs and campaign squad should be passed here
	var cells: Dictionary[Vector2i, Cell] = {}
	for i in range(10):
		for j in range(10):
			cells[Vector2i(i, j)] = Cell.new(Types.TerrainType.FOREST)
	
	var map: Map = Map.new(cells)
	
	var squads: Dictionary[int, Squad] = {
		0: Squad.new("", 0, {
				0: Unit.new(0, 0, Types.UnitType.WARRIOR, Vector2i(0, 0), 10, [], []),
				1: Unit.new(1, 0, Types.UnitType.WARRIOR, Vector2i(1, 0), 5, [], []),
			}),
		1: Squad.new("", 1, {
				0: Unit.new(0, 1, Types.UnitType.WARRIOR, Vector2i(3, 3), 10, [], []),
				1: Unit.new(1, 1, Types.UnitType.WARRIOR, Vector2i(3, 4), 5, [], []),
			}),
	}
	var battle: Battle = Battle.new(map, squads, "")
	
	# give the battle_scene references to already existing nodes it should use,
	# instead of creating new ones
	var battle_scene: BattleScene = get_tree().current_scene.get_node("BattleContainer/Battle")
	battle_scene.initialize(null, {})
	
	# pass the newly created battle to BattleManager.
	# This also triggers battle_scene to create/reuse all visuals.
	BattleManager.set_battle(battle)
