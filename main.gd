extends Node

@export var TileScene: PackedScene
var map_radius: int = 5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_map(map_radius)
	
func ripple (tile: Node3D) -> void:
	for distance in range(map_radius*2 +1):
		for t in $Tiles.get_children():
			if t.coordinates.distance_to(tile.coordinates) == distance:
				t.toggle_highlight()
				#t.get_node("AnimationPlayer").play("bump")
		await get_tree().create_timer(0.06).timeout

func generate_map(radius: int):
	if TileScene:
		for q in range(-radius, radius+1):
			for r in range(-radius, radius+1):
				for s in range(-radius, radius+1):
					if q + r + s == 0:
						var tile_instance = TileScene.instantiate()
						tile_instance.call_deferred("set_name", "Tile")
						$Tiles.add_child(tile_instance)
						tile_instance.initialize(CubeCoordinates.new(q, r, s))
	else:
		print("Tile scene is not assigned!")
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
