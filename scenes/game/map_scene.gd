class_name MapScene
extends Node2D

@onready var base_map_node: TileMapLayer = $BaseMap
@onready var highlight_map_node: TileMapLayer = $HighlightMap


func initialize(map: Map):
	# clear highlight map
	highlight_map_node.clear()
	
	# build base map
	base_map_node.clear()
	for coords: Vector2i in map.cells:
		var atlas_coords: Vector2i = _get_atlas_coords(map.cells.get(coords))
		base_map_node.set_cell(coords, 0, atlas_coords)

func _on_cell_changed(coords: Vector2i, cell: Cell):
	base_map_node.set_cell(coords, 0, _get_atlas_coords(cell))
	
func set_highlights(coords_list: Array[Vector2i]):
	highlight_map_node.clear()
	for coords: Vector2i in coords_list:
		highlight_map_node.set_cell(coords, 0, Vector2i(0, 0))
	
func clear_highlights():
	highlight_map_node.clear()
	
func _get_atlas_coords(cell: Cell) -> Vector2i:
	return DataCatalog.terrains[cell.terrain_type].atlas_coords
	
