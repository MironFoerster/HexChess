extends Object

class_name CubeCoordinates

var q: int
var r: int
var s: int

func _init(q: int = 0, r: int = 0, s: int = 0):
	self.q = q
	self.r = r
	self.s = s

func _to_string() -> String:
	return "[CubeCoordinates] q: "+str(q)+" r: "+str(r)+" s: "+str(s)

func _to_vector2() -> Vector2:
	var size = 1
	var x = size * (3./2 * q)
	var y = size * (sqrt(3)/2 * q  +  sqrt(3) * r)
	return Vector2(x, y)

func _to_vector3(y: float) -> Vector3:
	var vector2: Vector2 = _to_vector2()
	return Vector3(vector2.x, y, vector2.y)
	
func subtract_with(other: CubeCoordinates) -> CubeCoordinates:
	return CubeCoordinates.new(q - other.q, r - other.r, s - other.s)

func distance_to(other: CubeCoordinates) -> int:
	var coords = subtract_with(other)
	return max(abs(coords.q), abs(coords.r), abs(coords.s))
	
func equals(other: CubeCoordinates) -> bool:
	return q == other.q and r == other.r and s == other.s
