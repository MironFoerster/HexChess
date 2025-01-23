extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var viewport_size = Vector2(get_viewport().size.x, get_viewport().size.y)
	position = (viewport_size - size*scale) / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
