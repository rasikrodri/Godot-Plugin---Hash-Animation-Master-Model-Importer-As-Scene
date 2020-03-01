class MeshBuilder:
	var _surfaces : Array = []
	var _verts_indexes_dictionary : Dictionary = {}
	var _vertexes : Array = []
	var _uvs_1 : Array = []
	var _uvs_2 : Array = []
	var _poly_surface_res : Resource = preload("res://addons/AMModelImporterAsScene/poly_surface.gd")
	var _poly_vertex_res : Resource = preload("res://addons/AMModelImporterAsScene/poly_vertex.gd")
	
	func _init():
		
		pass
	
	#Based on this technique #https://www.iquilezles.org/www/articles/normals/normals.htm
	
	func generate_mesh(material : Material, options:Dictionary)->ArrayMesh:
		var array_mesh : ArrayMesh = ArrayMesh.new()
		
		if options.normals_method == "SMOOTH":
			_generate_average_normals()
		
		var surface_tool :SurfaceTool = SurfaceTool.new()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		
		#For testing uvs
		if material == null: print("must pass a material")
		surface_tool.set_material(material)
		
		var uv_index = -1
		for i in range(_surfaces.size()):
			var surface = _surfaces[i]
			
			uv_index += 1
			var vertex = _vertexes[surface.verts_indexes[0]]
			surface_tool.add_normal(vertex.normal)
			surface_tool.add_uv(_uvs_1[uv_index])
			surface_tool.add_uv2(_uvs_2[uv_index])
			if surface.bones_indexes_arrays[0].size() > 0:
				surface_tool.add_bones(PoolIntArray(surface.bones_indexes_arrays[0]))
				surface_tool.add_weights(PoolRealArray(surface.bone_weights_arrays[0]))
			surface_tool.add_vertex(vertex.pos)
			
			uv_index += 1
			vertex = _vertexes[surface.verts_indexes[1]]
			surface_tool.add_normal(vertex.normal)
			surface_tool.add_uv(_uvs_1[uv_index])
			surface_tool.add_uv2(_uvs_2[uv_index])
			if surface.bones_indexes_arrays[1].size() > 1:
				surface_tool.add_bones(PoolIntArray(surface.bones_indexes_arrays[1]))
				surface_tool.add_weights(PoolRealArray(surface.bone_weights_arrays[1]))
			surface_tool.add_vertex(vertex.pos)
			
			uv_index += 1
			vertex = _vertexes[surface.verts_indexes[2]]
			surface_tool.add_normal(vertex.normal)
			surface_tool.add_uv(_uvs_1[uv_index])
			surface_tool.add_uv2(_uvs_2[uv_index])
			if surface.bones_indexes_arrays[2].size() > 2:
				surface_tool.add_bones(PoolIntArray(surface.bones_indexes_arrays[2]))
				surface_tool.add_weights(PoolRealArray(surface.bone_weights_arrays[2]))
			surface_tool.add_vertex(vertex.pos)
			
		if options.normals_method == "FLAT":
			surface_tool.generate_normals(false)
			
		surface_tool.generate_tangents()
		surface_tool.commit(array_mesh)
		
		_clear_data()
		return array_mesh
		pass
		
	func _clear_data()->void:
	#	print("clearing data")
		self._surfaces.clear()
		self._surfaces = []
		
		self._verts_indexes_dictionary.clear()
		self._verts_indexes_dictionary = {}
		
		self._vertexes.clear()
		self._vertexes = []
		
		self._uvs_1.clear()
		self._uvs_1 = []
		
		self._uvs_2.clear()
		self._uvs_2 = []
		pass
	
	func add_polygon(vec1:Vector3, vec2:Vector3, vec3:Vector3, 
					normal1:Vector3, normal2:Vector3, normal3:Vector3, 
					uv1_1:Vector2, uv1_2:Vector2, uv1_3:Vector2, 
					uv2_1:Vector2, uv2_2:Vector2, uv2_3:Vector2,
					bones1:Array=[], bones2:Array=[], bones3:Array=[])->void:
#		print("----------")
#		print("Polygon1: " + str(vec1) + " at " + str(uv1_1))
#		print("Polygon2: " + str(vec2) + " at " + str(uv1_2))
#		print("Polygon3: " + str(vec3) + " at " + str(uv1_3))
#		print("----------")
		var surface = _poly_surface_res.PolySurface.new()
		_add_verts(surface, vec1, normal1, bones1)
		_add_verts(surface, vec2, normal2, bones2)
		_add_verts(surface, vec3, normal3, bones3)
		_uvs_1.append(uv1_1)
		_uvs_1.append(uv1_2)
		_uvs_1.append(uv1_3)
		_uvs_2.append(uv2_1)
		_uvs_2.append(uv2_2)
		_uvs_2.append(uv2_3)
		self._surfaces.append(surface)
		pass
		
	#Used to assign the mesh bone to cps that do not have bones assigned to them
	#assigned to the cps that do not have a bone assigned otherwise godot will throw exceptions.
	var mesh_bone_index:Array = [0,0,0,0]
	var mesh_bone_weights:Array = [0.25,0.25,0.25,0.25]
	func _add_verts(surface, vert_pos : Vector3, normal : Vector3, bones:Array=[])->void:
		var vertex_index : int
		
		var vert_key = str(vert_pos)
		if _verts_indexes_dictionary.has(vert_key):
			vertex_index = _verts_indexes_dictionary[vert_key]
		else:
			vertex_index = _vertexes.size()
			var poly = _poly_vertex_res.PolyVertex.new(vert_pos, normal)
			_vertexes.append(poly)
			_verts_indexes_dictionary[vert_key] = vertex_index
			
		
		surface.verts_indexes.append(vertex_index)
		surface.add_bones(bones, mesh_bone_index, mesh_bone_weights)
		pass
		
	func _generate_average_normals()->void:
		#Based on this technique #https://www.iquilezles.org/www/articles/normals/normals.htm
		
		#create default zeroed normals
		for i in range(_vertexes.size()):
			_vertexes[i].normal = Vector3(0,0,0)
		
		#calcualte normals
		for i in range(_surfaces.size()):
			var surface = _surfaces[i]
			var ia : int = surface.verts_indexes[0]
			var ib : int = surface.verts_indexes[1]
			var ic : int = surface.verts_indexes[2]
			
			var e1 : Vector3 = _vertexes[ia].pos - _vertexes[ib].pos
			var e2 : Vector3 = _vertexes[ic].pos - _vertexes[ib].pos
			var no : Vector3 = e1.cross(e2)
			
			_vertexes[ia].normal += no
			_vertexes[ib].normal += no
			_vertexes[ic].normal += no
			
		#normalize normals
		for i in range(_vertexes.size()):
			_vertexes[i].normal = _vertexes[i].normal.normalized()
		
	#	_print_results()
		pass
		
	#func _print_results()->void:
	#	for i in range(_vertexes.size()):
	#		print("Vertex " + str(i) + ", normal[" + str(_vertexes[i].normal) + "], pos[" + str(_vertexes[i].pos) + "]")
	#	pass
