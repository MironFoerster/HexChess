extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		detect_click()

func detect_click():
	# Get the mouse position (cursor position on the screen)
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
		if hit_node.name.begins_with("Tile"):
			get_parent().get_parent().ripple(hit_node)
			#hit_node.get_parent().toggle_highlight()
	else:
		print("No node hit.")
