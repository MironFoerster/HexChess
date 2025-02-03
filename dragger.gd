extends Node

var dragging = false
var y_level = 2.5
@onready var controller = $"../GameController"
@onready var anchor = $DragAnchor
@onready var TP = $TouchdownPoint
@onready var placeholder = $Placeholder
@onready var joint = $DragJoint
@onready var raycast = $DragAnchor/RayCast3D
var hovering_tile: Node3D = null
var dragging_piece: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if raycast.is_colliding():
		var hit_tile = raycast.get_collider()
		TP.position = raycast.get_collision_point()
		controller.hover_tile.emit(hit_tile)
		hovering_tile = hit_tile
	else:
		controller.hover_tile.emit(null)
		hovering_tile = null
		
	if dragging:
		var anchor_pos = cursor_intersects_y(y_level)
		if anchor_pos != Vector3.ZERO:
			anchor.position = anchor_pos
		

func end_dragging() -> void:
	if dragging:
		dragging = false
		joint.node_b = NodePath("")# placeholder.get_path()
		dragging_piece.sleeping = false
		
		if hovering_tile:
			#dragging_piece.freeze = true
			#dragging_piece.global_transform.origin = Vector3(10, 0, 0)
			dragging_piece.appear_at(hovering_tile.coordinates)
			#dragging_piece.global_transform.origin = Vector3(10, 0, 0)
		else:
			dragging_piece.appear_at(dragging_piece.coordinates)

func start_dragging(piece: Node3D) -> void:
	dragging = true
	anchor.position = piece.position
	anchor.position.y = y_level-1
	dragging_piece = piece
	piece.freeze = false
	joint.node_b = piece.get_path()
	

func deactivate(piece: Node3D) -> void:
	dragging = false

func cursor_intersects_y(y_level: float) -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)

	if direction.y == 0:
		return Vector3.ZERO  # Ray is parallel to the plane, no intersection

	var t = (y_level - from.y) / direction.y
	return from + direction * t  # Intersection point in 3D space
