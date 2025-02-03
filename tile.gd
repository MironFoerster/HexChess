extends Node3D

@onready var controller: Node = $"../../GameController"

var coordinates: CubeCoordinates
var highlighted: bool = false
const off_scale = Vector3(0.9, 0.9, 0.9)
const highlighted_scale = Vector3(1.03, 0.9, 1.03)
const highlight_speed = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		controller.select_piece.connect(_on_select_piece)
		controller.hover_tile.connect(_on_hover_tile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_scale = highlighted_scale if highlighted else off_scale
	var factor = lerp($HighlightTileModel.scale, target_scale, highlight_speed * delta)
	$HighlightTileModel.scale = factor

func initialize(coordinates):
	self.coordinates = coordinates
	position = coordinates._to_vector3(0)

func set_highlight(value: bool):
	highlighted = value
	
func toggle_highlight():
	highlighted = !highlighted
	
func _on_select_piece(piece: Node3D) -> void:
	if coordinates.equals(piece.coordinates):
		set_highlight(true)
	else:
		set_highlight(false)
		
func _on_hover_tile(piece: Node3D) -> void:
	if self == piece:
		set_highlight(true)
	else:
		set_highlight(false)
