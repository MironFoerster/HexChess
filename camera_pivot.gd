extends Node3D

var key_rotation_speed := 0.03  # Sensitivity for rotation
var drag_rotation_speed := 0.003  # Sensitivity for rotation
var zoom_speed := 2.0       # Speed for zooming
var min_zoom := 5.0         # Minimum camera distance
var max_zoom := 50.0        # Maximum camera distance



var target_rotation: float = 30
var rotating: bool = false
var dragging: bool = false
@export var rotation_speed: float = 4  # Adjust speed as needed


# Called when the node is added to the scene
func _ready():
	target_rotation = rotation_degrees.y  # Initialize to current rotation
	# Ensure the camera is initially positioned correctly
	$Camera.look_at(Vector3.ZERO, Vector3.UP)
	
func _input(event):
	# Rotate the pivot when dragging the screen
	#if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#pass # maybe do an override system on drag one day
		#rotate_y(-event.relative.x * drag_rotation_speed)
		#dragging = true
		#rotating = false
	#
	#if event is InputEventMouseButton and not event.pressed:
		#pass
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#target_rotation = snappedf(rotation_degrees.y-30, 60)+30
			#dragging = false
			#rotating = true
	
	# Zoom in/out with the scroll wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(-zoom_speed)

func _process(delta):
	# Rotate using A/D keys
	if Input.is_action_just_pressed("ui_left"):
		rotate_to_next_multiple(false)
	elif Input.is_action_just_pressed("ui_right"):
		rotate_to_next_multiple(true)
	if rotating:
		if abs(rotation_degrees.y - target_rotation) > 0.1:
			rotation_degrees.y = lerp(rotation_degrees.y, target_rotation, rotation_speed * delta)
			await get_tree().process_frame
		else:
			rotation_degrees.y = target_rotation  # Ensure exact final value
			rotating = false

# Smoothly zoom the camera in/out
func zoom_camera(amount):
	var min_fov = 15
	var max_fov = 80
	var camera = $"../CameraPivot/Camera"  # Ensure this is the correct path
	camera.fov = clamp(camera.fov - amount, min_fov, max_fov)
	

func rotate_to_next_multiple(clockwise: bool):
	var step = 60 if clockwise else -60
	target_rotation = snappedf(target_rotation + step-30, 60)+30

	if not rotating:
		rotating = true
