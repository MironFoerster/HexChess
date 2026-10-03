extends Control

@onready var ability_name_label = $AbilityNameLabel

var ability_type: Types.AbilityType

signal clicked(ability_type: Types.AbilityType)

func setup(_ability: Ability):
	ability_type = _ability.ability_type
	ability_name_label.text = DataCatalog.abilities[ability_type].display_name
	#if ability.usable: TODO make ability buttons more responsive
		#icon = DataCatalog.abilities[ability.ability_type].icon_usable
	#mouse_filter = not _ability.usable

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(ability_type)
