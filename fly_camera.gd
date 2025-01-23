extends Camera3D

# Movement speed
@export var move_speed: float = 10.0
@export var sprint_multiplier: float = 2.0
@export var rotation_sensitivity: float = 0.4

# Mouse look toggle
var mouse_look_enabled: bool = true

# Track rotation
var rotation_x: float = 0.0
var rotation_y: float = 0.0

func _ready():
	# Lock the mouse for a better experience
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float):
	handle_mouse_input(delta)
	handle_keyboard_input(delta)
	if Input.is_action_just_pressed("left_click"):
		detect_click()

func detect_click():
	# Get the mouse position (center of the screen)
	var mouse_position = get_viewport().get_mouse_position()

	# Convert screen space position to a ray in 3D space
	var ray_origin = project_ray_origin(mouse_position)
	var ray_direction = project_ray_normal(mouse_position)

	# Cast the ray and check for intersections
	var space_state = get_world_3d().direct_space_state

	# Create RayCastParameters to pass to the method
	var ray_parameters = PhysicsRayQueryParameters3D.new()
	ray_parameters.from = ray_origin
	ray_parameters.to = ray_origin + ray_direction * 1000  # Length of the ray

	# Perform the ray intersection
	var result = space_state.intersect_ray(ray_parameters)

	if result:
		# The ray hit a node, `result` contains the hit info
		var hit_node = result["collider"]
		print("Hit node: ", hit_node.name)
		if hit_node.name == "TileBody":
			get_parent().ripple(hit_node.get_parent())
	else:
		print("No node hit.")


func handle_mouse_input(delta: float):
	if mouse_look_enabled:
		var mouse_motion = Input.get_last_mouse_velocity()
		rotation_y -= mouse_motion.x * rotation_sensitivity * delta
		rotation_x -= mouse_motion.y * rotation_sensitivity * delta

		# Clamp vertical rotation to prevent flipping
		rotation_x = clamp(rotation_x, -90, 90)

		# Apply rotation to the camera
		rotation_degrees.x = rotation_x
		rotation_degrees.y = rotation_y

func handle_keyboard_input(delta: float):
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("ui_up"):  # W
		print("Moving forward")

	# Forward/backward
	if Input.is_action_pressed("ui_up"):  # W
		direction -= transform.basis.z
	if Input.is_action_pressed("ui_down"):  # S
		direction += transform.basis.z

	# Left/right
	if Input.is_action_pressed("ui_left"):  # A
		direction -= transform.basis.x
	if Input.is_action_pressed("ui_right"):  # D
		direction += transform.basis.x

	# Ascend/descend
	if Input.is_action_pressed("ascend"):  # Q
		direction += transform.basis.y
	if Input.is_action_pressed("descend"):  # E
		direction -= transform.basis.y

	# Normalize direction to avoid faster diagonal movement
	if direction != Vector3.ZERO:
		direction = direction.normalized()

	# Adjust speed (sprint with Shift)
	var speed = move_speed * (sprint_multiplier if Input.is_action_pressed("ui_focus") else 1.0)
	transform.origin += direction * speed * delta

func _input(event):
	# Toggle mouse look with Escape
	if event.is_action_pressed("ui_cancel"):  # ESC
		mouse_look_enabled = not mouse_look_enabled
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if mouse_look_enabled else Input.MOUSE_MODE_VISIBLE)
