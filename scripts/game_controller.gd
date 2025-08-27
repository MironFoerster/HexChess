extends Node

var PIECES = preload("res://scripts/pieces_conf.gd").new().PIECES
var PIECE_SCENE = load("res://packed_scenes/piece.tscn") as PackedScene

signal hover_tile(piece: Node3D)
signal update_highlights()
signal take_action(from: Node3D, to: Node3D, mode: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#var p = spawn_piece("swordsman", CubeCoordinates.new(0,-1,1))
	#var d = spawn_piece("goblin", CubeCoordinates.new(1,-1,0))
	#d.appear_at(CubeCoordinates.new(-1, 1, 0))
	#p.appear_at(CubeCoordinates.new(0, 1, -1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_piece(piece_type: String, coordinates: CubeCoordinates) -> Node3D:
	var piece_data = PIECES.get(piece_type, null)
	if piece_data == null:
		print("Enemy type not found:", piece_type)
		return

	var piece_instance: Node3D = PIECE_SCENE.instantiate()
	piece_instance.initialize(piece_type, coordinates)
	piece_instance.call_deferred("set_name", "Piece")
	$"../Pieces".add_child(piece_instance)
	
	return piece_instance
