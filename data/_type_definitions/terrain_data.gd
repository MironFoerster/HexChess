extends Resource
class_name TerrainData

@export var display_name: String
@export var tile_coordinates: Vector2
@export var can_border_on: Array[TerrainData] # TODO: use string? does using terrainData instanciate something exta?
