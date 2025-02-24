extends Node3D

@onready var controller: Node = $"../../GameController"
@onready var interactor: Node = $"../../Interactor"

var coordinates: CubeCoordinates
var highlight_mode: String = "none"
const off_scale = Vector3(0.9, 0.9, 0.9)
const highlighted_scale = Vector3(1.03, 0.9, 1.03)
const highlight_speed = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		controller.update_highlights.connect(_on_update_highlight)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var tile_model: Node3D = $HighlightTileModel
	
	var target_scale = highlighted_scale if highlight_mode != "none" else off_scale
	var factor = lerp(tile_model.scale, target_scale, highlight_speed * delta)
	tile_model.scale = factor
	
	var highlight_color: Color
	match highlight_mode:
		"basic":
			highlight_color = Color(1, 1, 1, 1)
		"faint":
			highlight_color = Color(1, 1, 1, 0.5)
		"blue":
			highlight_color = Color(0, 0, 1, 1)
		"red":
			highlight_color = Color(1, 0, 0, 1)
		_:
			highlight_color = Color(1, 1, 1, 1)
			
	var highlight_material = StandardMaterial3D.new()
	highlight_material.albedo_color = highlight_color

	tile_model.get_node("Sketchfab_model/HexMesh_obj_cleaner_materialmerger_gles/Object_2").set_surface_override_material(0, highlight_material)

func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: # press
				interactor.pressed_on(self)
			#elif !event.pressed: # release
				#interactor.released_on(self)
	elif event is InputEventMouseMotion:
		interactor.hovered_on(self)
				
func initialize(coordinates):
	self.coordinates = coordinates
	position = coordinates._to_vector3(0)

func set_highlight(type: String):
	highlight_mode = type
	
func toggle_highlight():
	highlight_mode = "" if highlight_mode != "" else "basic"

func _on_update_highlight() -> void:
	print("onupdate", interactor.tile_highlights)
	if self == interactor.tile_highlights.selected:
		set_highlight("basic")
		return
	if self == interactor.tile_highlights.hovered:
		set_highlight("faint")
		return
	elif interactor.action_mode == "move" and self in interactor.tile_highlights.movable:
		set_highlight("blue")
		return
	elif interactor.action_mode == "action" and self in interactor.tile_highlights.affectable:
		set_highlight("red")
		return
	else:
		set_highlight("none")
