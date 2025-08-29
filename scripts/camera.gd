extends Camera2D

@export var zoom_levels := [Vector2(0.5, 0.5), Vector2(1, 1), Vector2(2, 2)]
@export var zoom_duration := 0.3
@export var move_speed := 400.0
@export var zoom_step := 0.1
@export var min_zoom := 0.3
@export var max_zoom := 3.0
var drag_speed := 1.0
var dragging := false
var last_mouse_pos := Vector2.ZERO
var target_zoom := Vector2(1, 1)

var tween: Tween


func _ready():
	make_current()


func _process(delta):
	handle_movement(delta)
	handle_drag()
	handle_zoom_keys()
	handle_mouse_zoom()

func handle_movement(delta):
	var direction := Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	position += direction.normalized() * move_speed * delta

func handle_drag():
	if Input.is_action_just_pressed("mouse_drag"):
		dragging = true
		last_mouse_pos = get_viewport().get_mouse_position()
	elif Input.is_action_just_released("mouse_drag"):
		dragging = false

	if dragging:
		var current_mouse_pos = get_viewport().get_mouse_position()
		var delta = last_mouse_pos - current_mouse_pos
		position += delta * (Vector2(1.0, 1.0) / zoom)  # Adjust for zoom level
		last_mouse_pos = current_mouse_pos

func handle_zoom_keys():
	if Input.is_action_just_pressed("zoom_1"):
		smooth_zoom_to(zoom_levels[0])
	elif Input.is_action_just_pressed("zoom_2"):
		smooth_zoom_to(zoom_levels[1])
	elif Input.is_action_just_pressed("zoom_3"):
		smooth_zoom_to(zoom_levels[2])

func handle_mouse_zoom():
	var zoom_factor := 1.1  # 70% per step
	if Input.is_action_just_pressed("zoom_in"):
		zoom = (zoom / zoom_factor).clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	elif Input.is_action_just_pressed("zoom_out"):
		zoom = (zoom * zoom_factor).clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func smooth_zoom_to(new_zoom: Vector2):
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "zoom", new_zoom, zoom_duration)
