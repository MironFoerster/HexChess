extends Node2D

signal clicked(unit_id)
signal hover_entered(unit_id)
signal hover_exited(unit_id)

var unit_id : int

@onready var area : Area2D = $Area2D

func initialize(id: int):
	unit_id = id

func _ready():
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)


func _on_mouse_entered():
	emit_signal("hover_entered", unit_id)


func _on_mouse_exited():
	emit_signal("hover_exited", unit_id)


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		emit_signal("clicked", unit_id)
