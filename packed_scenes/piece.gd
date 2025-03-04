extends RigidBody3D

var PIECES = load("res://pieces_conf.gd").new().PIECES
@onready var dragger: Node = $"../../Dragger"
@onready var interactor: Node = $"../../Interactor"
@onready var controller: Node = $"../../GameController"

var coordinates: CubeCoordinates
var selected: bool = false

var type: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	controller.take_action.connect(_on_take_action)
	angular_damp = 1.0
	freeze = true
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func _input_event(camera, event, position, normal, shape_idx):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#if event.pressed: # press
				#interactor.pressed_on(self)
			#elif !event.pressed: # release
				#interactor.released_on(self)
			

func initialize(type: String, coordinates: CubeCoordinates) -> void:
	self.type = type
	print("initialize "+type)
	appear_at(coordinates)

	var model_scene = load(PIECES[type].model_path) as PackedScene
	var model_instance = model_scene.instantiate()
	model_instance.scale = PIECES[type].base_scale
	model_instance.position = PIECES[type].base_transform
	self.translate(Vector3(0,0.1,0))
	$ModelContainer.add_child(model_instance)
	var animation_player = model_instance.get_node("AnimationPlayer")
	animation_player.play(PIECES[type].animations.idle)


func appear_at(coordinates: CubeCoordinates) -> void:
	print("appearing")
	if get_tree():
		print("waiting")
		await get_tree().create_timer(0.1).timeout
	freeze = true
	sleeping = false
	self.coordinates = coordinates
	print(position)
	position = coordinates._to_vector3(0.0)
	print(coordinates._to_vector3(0.0))
	rotation = Vector3.ZERO
	print(position)
	#freeze = true
	
func _on_take_action(from: Node3D, to: Node3D, mode: String) -> void:
	if mode == "move":
		appear_at(to.coordinates)
	elif mode == "affect":
		# make effect on piece on other tile
		pass

#func _on_mouse_exited() -> void:
	#interactor.exited_from(self)
