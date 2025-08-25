extends Camera2D

@export var zoom_levels := [Vector2(0.5, 0.5), Vector2(1, 1), Vector2(2, 2)]
var drag_speed := 1.0
var is_dragging := false
var last_mouse_pos := Vector2.ZERO

func _input(event):
	# Handle dragging with the right mouse button
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
			last_mouse_pos = get_global_mouse_position()

	elif event is InputEventMouseMotion and is_dragging:
		var mouse_delta = get_global_mouse_position() - last_mouse_pos
		position -= mouse_delta * zoom.x * drag_speed
		last_mouse_pos = get_global_mouse_position()

	# Handle zooming with 1, 2, 3 keys
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			zoom = zoom_levels[0]
		elif event.keycode == KEY_2:
			zoom = zoom_levels[1]
		elif event.keycode == KEY_3:
			zoom = zoom_levels[2]
