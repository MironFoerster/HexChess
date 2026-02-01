extends RefCounted
class_name MapGenerator

func _init():
	pass
	
func generate() -> Map:
	var map = Map.new()
	for i in range(0, 10):
		for j in range(0, 10):
			map.setCell(Vector2i(i, j), Cell.new("forest"))
	return map


#func generate_map(radius: int):
	#for q in range(-radius, radius+1):
		#for r in range(-radius, radius+1):
			#for s in range(-radius, radius+1):
				#if q + r + s == 0:
					#var tile_instance = TileScene.instantiate()
					#tile_instance.call_deferred("set_name", "Tile")
					#$Tiles.add_child(tile_instance)
					#tile_instance.initialize(CubeCoordinates.new(q, r, s))
