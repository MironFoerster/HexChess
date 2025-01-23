extends CollisionShape3D

@export var mesh_instance : MeshInstance3D

func _ready():
	if mesh_instance and self:
		var mesh = mesh_instance.mesh
		var shape = ConvexPolygonShape3D.new()  # For convex shapes
		# var shape = ConcavePolygonShape3D.new()  # For concave shapes

		# Convert the mesh into a collision shape

		self.shape = mesh
