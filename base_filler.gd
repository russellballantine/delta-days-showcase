@tool
extends StaticBody3D

@export var size: Vector3 = Vector3(8.0, 5.0, 20.0):
	set(value):
		size = value
		_update_dimensions()

func _ready() -> void:
	_update_dimensions()

func _update_dimensions() -> void:
	var mesh_node = get_node_or_null("MeshInstance3D")
	var col_node = get_node_or_null("CollisionShape3D")
	
	if mesh_node and mesh_node.mesh is BoxMesh:
		mesh_node.mesh.size = size
	if col_node and col_node.shape is BoxShape3D:
		col_node.shape.size = size
