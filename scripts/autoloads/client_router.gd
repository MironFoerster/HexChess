extends Node


var handlers: Dictionary[StringName, Callable] = {
	"effect_tree": GameManager.active_battle._handle_effect_tree,
	# TODO add more handlers
}

func handle_server_message(payload: Dictionary):
	handlers[payload.handler_name].call(payload.data)
