extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	if OS.has_feature("server") or "--server" in OS.get_cmdline_args():
		GlobalNetworking.start_server()
	else:
		pass
		#start intro sequence
