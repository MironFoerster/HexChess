extends Node2D

signal clicked(unit_id: Vector2i)
signal hover_entered(unit_id: Vector2i)
signal hover_exited(unit_id: Vector2i)

var coords : Vector2i

@onready var area : Area2D = $Area2D

func initialize(_coords: Vector2i):
	coords = _coords
	position = Utils.pos_from_coords(coords)

func _ready():
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)


func _on_mouse_entered():
	hover_entered.emit(coords)


func _on_mouse_exited():
	hover_exited.emit(coords)


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		clicked.emit(coords)
