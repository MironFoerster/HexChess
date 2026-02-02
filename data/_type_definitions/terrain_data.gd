extends Resource
class_name TerrainData

@export var display_name: String
@export var atlas_coords: Vector2i
@export var can_border_on: Array[TerrainData] # TODO: use string? does using terrainData instanciate something exta?
