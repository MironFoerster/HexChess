extends Node2D
class_name DamageNumber

@onready var label: Label = $Label

func initialize(value: int, world_pos: Vector2) -> void:
	position = world_pos
	label.text = str(value)
