extends Node

@onready var dragger: Node = $"../Dragger"
@onready var controller: Node = $"../GameController"
var pressed: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if !event.pressed: # release
				pressed = null
				dragger.end_dragging()

func pressed_on(piece: Node3D) -> void:
	pressed = piece
	controller.select_piece.emit(piece)

func released_on(piece: Node3D) -> void:
	pressed = null
	
func exited_from(piece: Node3D) -> void:
	if pressed == piece:
		dragger.start_dragging(piece)
