extends Node3D

var coordinates: CubeCoordinates

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func initialize(coordinates):
	self.coordinates = coordinates
	position = coordinates._to_vector3(0)
