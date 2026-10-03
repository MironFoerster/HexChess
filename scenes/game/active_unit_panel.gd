extends Control

var button_scene = load("res://scenes/ui/components/AbilityButton.tscn") as PackedScene
@onready var container = $AbilityContainer

signal ability_clicked(ability_type: StringName)


func set_unit(unit_id: int):
	for c in container.get_children():
		c.queue_free()
	
	if unit_id == -1:
		return
	
	var abilities = BattleManager.battle.get_unit_abilities(unit_id)

	for ability in abilities:
		var b = button_scene.instantiate()
		b.setup(ability)
		b.clicked.connect(_on_ability_clicked)
		container.add_child(b)

func _on_ability_clicked(ability_type: StringName):
	ability_clicked.emit(ability_type)
