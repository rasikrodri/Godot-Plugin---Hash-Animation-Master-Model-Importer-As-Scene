class AmModel:
	var _spline_resource : Resource = preload("res://addons/AMModelImporterAsScene/spline.gd")
	var _cps_resource : Resource = preload("res://addons/AMModelImporterAsScene/cp.gd")
	var _patch_resource :Resource = preload("res://addons/AMModelImporterAsScene/patch.gd")
	var _mesh_builder_resource : Resource = preload("res://addons/AMModelImporterAsScene/am_mesh_builder.gd")
	var _decal_resource :Resource = preload("res://addons/AMModelImporterAsScene/decal.gd")
	var _bone_resource :Resource = preload("res://addons/AMModelImporterAsScene/bone.gd")
	var _xml_loader_resource :Resource = preload("res://addons/AMModelImporterAsScene/am_xml_load/xml_loader.gd")
	
	var _document
	
	var _source_path:String
	
	var _time_before
	var _process_being_timed
	
	var _cps : Dictionary = {}
	var _splines :Array = []
	var _patches :Array = []
	var _normals : Array = []
	var _decals : Array = []
	var _decal1
	var _decal2
	var all_bones : Dictionary = {}
	var bones_herarchy : Array = []
	
	var _patches_dictionary : Dictionary = {}
	
	var _files_paths:Array = []
	
	func _init(source_path: String, files_path:Array):
		_source_path = source_path
		_files_paths = files_path
		_document = _xml_loader_resource.XmlLoader.new(source_path).get_node_tree()
		pass
		
	func get_polygon_mesh(options:Dictionary):
		var mesh_builder = _mesh_builder_resource.AmMeshBuilder.new(
			_source_path,
			_cps, 
			_splines, 
			_patches, 
			_normals,
			_decal1,
			_decal2
		)
		_reset_variables()
		
		return mesh_builder.build_mesh(options)
		pass
		
	func start_timer(process_name:String):
		_process_being_timed = process_name
		_time_before = OS.get_ticks_msec()
	func stop_timer():
		print("'" + _process_being_timed + "'" + " took ms: " + str(OS.get_ticks_msec() - _time_before))
		
	func _reset_variables():
		_cps = {}
		_splines = []
		_patches = []
		_normals = []
		_decals = []
		_decal1 = null
		_decal2 = null
		pass
	
	func load_model()->int:
		start_timer("load_splines")
		var error = load_splines()
		if error != OK: return error
		stop_timer()
		
		start_timer("assing_host_and_client_cps")
		assing_host_and_client_cps()
		stop_timer()
		
		start_timer("load_patches")
		error = load_patches()
		if error != OK: return error
		stop_timer()
		
		start_timer("load_normals")
		error = load_normals()
		if error != OK: return error
		stop_timer()
		
		start_timer("load_decals")
		error = load_decals()
		stop_timer()
		
		start_timer("assign_decals_uvs_to_patches")
		assign_decals_uvs_to_patches()
		stop_timer()
		
		start_timer("load_bones")
		load_bones()
		stop_timer()
		
		start_timer("_merge_duplicate_bone_weights")
		_merge_duplicate_bone_weights()
		stop_timer()
		
		start_timer("_count_main_host_cps")
		var main_host_cps_count = _count_main_host_cps()
		stop_timer()
			
		print("Loading Results:")
		print("-Total Cps = " + str(_cps.size()))
		print("-Total Main Hosts Cps = " + str(main_host_cps_count))
		print("-Total Splines = " + str(_splines.size()))
		print("-Total Patches = " + str(_patches.size()))
		print("-Total Normals = " + str(_normals.size()) + ", these normals seem to be per patch vertex and not per individual vertex.")
		print("-Total Decals = " + str(_decals.size()))
		print("-Total Bones = " + str(all_bones.keys().size()))
		
		return OK
		pass
		
	func load_splines()->int:
		var result = _document.query(["MODEL"]).query(["MESH"]).query(["SPLINE"])
		for i in range(result.nodes.size()):
			_splines.append(_spline_resource.Spline.new(i, result.nodes[i], _cps, _cps_resource))
		return OK
		pass
		
	func assing_host_and_client_cps():
		var cps_array : Array = Array(_cps.values())
		for i in range(cps_array.size()):
			var cp = cps_array[i]
			if cp.host_cp_num > -1:
				var host_cp = _cps[cp.host_cp_num]
				host_cp.client_cp = cp
				cp.host_cp = host_cp
			
		pass
		
	func load_patches()->int:
		var result = _document.query(["MODEL"]).query(["MESH"]).query(["PATCHES"])
		for i in range(result.nodes.size()):
			var patches_data = result.nodes[i].data.strip_edges().split("\n")
			for b in range(patches_data.size()):
				var data:String = (patches_data[b] as String).strip_edges()
				if not data.empty():
					var patch = _patch_resource.Patch.new(data, _cps)
					_patches.append(patch)
					_patches_dictionary[patch.decal_patch_id] = patch
		return OK
		pass
		
	func load_normals()->int:
		var result = _document.query(["MODEL"]).query(["MESH"]).query(["NORMALS"])
		for i in range(result.nodes.size()):
			var normals_data = result.nodes[i].data.strip_edges().split("\n")
			for b in range(normals_data.size()):
				var normals_values : Array = normals_data[b].split(" ")
				_normals.append(Vector3(float(normals_values[0]), float(normals_values[1]), float(normals_values[2])))
		return OK
		pass
		
	func load_decals()->int:
		var result = _document.query(["MODEL"]).query(["DECALS"]).query(["DECAL"])
		for i in range(result.nodes.size()):
			_decals.append(_decal_resource.Decal.new(result.nodes[i], _cps, _files_paths))
			
		if _decals.size() > 0: _decal1 = _decals[0]
		if _decals.size() > 1: _decal2 = _decals[1]
		return OK
		pass
		
	func assign_decals_uvs_to_patches():
		for i in range(_decals.size()):
			if i == 2: return#allow only two decals from the model. Godot supports 2 uvs only per mesh
			var decal_patches_uvs = _decals[i].patches_uvs
			for a in decal_patches_uvs.keys():
				if i == 0:
					_patches_dictionary[a].patch_uvs_1 = decal_patches_uvs[a]
				else:					
					_patches_dictionary[a].patch_uvs_2 = decal_patches_uvs[a]
		pass
		
	func load_bones():
		var result = _document.query(["MODEL"]).query(["BONES"]).query(["SEGMENT", "NULLOBJECT"])
		for i in range(result.nodes.size()):
			var bone_node = result.nodes[i]
			var bone = _bone_resource.Bone.new(null, bone_node, _cps)
			#need to ad the bone to the lists first
			#so that they get processed first wehn bulding the skeleton
			bones_herarchy.append(bone)
			all_bones[bone.name] = bone
			read_segment(bone, bone_node.query(["SEGMENT", "NULLOBJECT"]).nodes)
		return OK
		pass
		
	func read_segment(parent_bode, bones_nodes:Array):
		for i in range(bones_nodes.size()):
			var bone_node = bones_nodes[i]
			var bone = _bone_resource.Bone.new(parent_bode, bone_node, _cps)
			#need to ad the bone to the lists first
			#so that they get processed first wehn bulding the skeleton
			all_bones[bone.name] = bone
			read_segment(bone, bone_node.query(["SEGMENT", "NULLOBJECT"]).nodes)
		pass
		
	func _count_main_host_cps()->int:
		var position_independent_cps : int = 0
		for i in _cps:
			if _cps[i].is_position_independent():position_independent_cps +=1
		return position_independent_cps
		pass
		
	func _merge_duplicate_bone_weights()->void:
		for i in _cps:
			var cp = _cps[i]
			if cp.is_position_independent():
#				if cp.cp_num == 2 or cp.cp_num == 3:
#					var ddd = 0
				cp.assign_missing_bone_weights()
		pass
