extends Node2D

signal clicked(unit_id: int)
signal hover_entered(unit_id: int)
signal hover_exited(unit_id: int)

var unit_id : int

@onready var area : Area2D = $Area2D
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)

func initialize(_unit: BattleUnit):
	unit_id = _unit.unit_id
	position = Utils.pos_from_coords(_unit.coords)
	animated_sprite.sprite_frames = DataCatalog.units[_unit.unit_type].frames

func _on_mouse_entered():
	hover_entered. emit(unit_id)


func _on_mouse_exited():
	hover_exited. emit(unit_id)


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		clicked.emit(unit_id)
