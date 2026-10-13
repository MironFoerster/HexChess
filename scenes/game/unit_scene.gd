class_name UnitScene
extends Node2D

signal clicked(unit: UnitScene)
signal hover_entered(unit: UnitScene)
signal hover_exited(unit: UnitScene)

var unit_id: int
var squad_id: int
var sprite_frames: SpriteFrames
var move_tween: Tween

@onready var area: Area2D = $Area2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)
	animated_sprite.sprite_frames = sprite_frames

func initialize(_unit: Unit, spawn_position: Vector2):
	unit_id = _unit.unit_id
	squad_id = _unit.squad_id
	position = spawn_position
	sprite_frames = DataCatalog.units[_unit.unit_type].frames


func move_to(target_position: Vector2, duration: float = 0.3) -> void:
	if move_tween and move_tween.is_running():
		move_tween.kill()

	move_tween = create_tween()
	move_tween.tween_property(self, "position", target_position, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

func _on_mouse_entered():
	hover_entered.emit(self)

func _on_mouse_exited():
	hover_exited.emit(self)


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		clicked.emit(self)
