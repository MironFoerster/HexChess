class_name Utils

static func pos_from_coords(coords: Vector2i) -> Vector2:
	var q = coords.x
	var r = coords.y

	var x = 120.0 * (q + 0.5 * r)
	var y = 120.0 * (0.8660254 * r)  # sqrt(3)/2

	return Vector2(x + 60.0, y + 60.0)
