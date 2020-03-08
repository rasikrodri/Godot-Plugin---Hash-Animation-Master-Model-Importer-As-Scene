class AmMeshBuilder:
	var _mdl_file_location : String
	var _model_cps : Dictionary = {}
	var _model_splines : Array = []
	var _model_patches : Array = []
	var _normals : Array = []
	var _decal1
	var _decal2
	
	var _hook_and_left_cp : Dictionary ={}
	
	var _mesh_builder_resource = preload("res://addons/AMModelImporterAsScene/mesh_builder.gd")
	var _hook_patch_service_resource:Resource = preload("res://addons/AMModelImporterAsScene/services/hook_patch_service.gd")
	
	var zeroed_normals : Array = [Vector3(0,0,0)]
	var zeroed_normals_indexes :Array = [0,0,0,0,0]
	
	var _builder
	
	func _init(mdl_file_path:String ,model_cps : Dictionary, model_splines:Array, 
				model_patches:Array, normals:Array, 
				decal1, decal2):
		_mdl_file_location = mdl_file_path
		_model_cps = model_cps
		_model_splines = model_splines
		_model_patches = model_patches
		_normals = normals
		_decal1 = decal1
		_decal2 = decal2
		pass
		
	func build_mesh(options:Dictionary)->ArrayMesh:
		_builder = _mesh_builder_resource.MeshBuilder.new()
		var hook_patches:Array = []
		
		if _normals.size() == 0:
			_normals = zeroed_normals
			
		for i in range(_model_patches.size()):
			var patch = _model_patches[i]
			if patch.from_hook:
				hook_patches.append(patch)
			else:
				_build_4_and_5_points_patch(patch)

		_build_hook_patches(hook_patches)
		var mat : SpatialMaterial = SpatialMaterial.new()
		mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
		mat.albedo_texture = null
		
		#Only load images that are in teh same folder than the model, for now!
		if not _decal1 == null:
			mat.albedo_texture = _get_texture(_decal1.albedo_image)
			mat.metallic_texture = _get_texture(_decal1.specular_intensity_image)
			#for transparency Godot material usess the texture alpha channel 
			#enabling transparency int the flags.
			
			
		return _builder.generate_mesh(mat, options)
		pass
		
	func _get_texture(image_path:String)->Resource:
		if image_path.empty(): return null
		
		var image_name:String
		var path = _mdl_file_location.substr(0, _mdl_file_location.find_last("/") + 1)
		if image_path.find_last("/") > -1:
			path += image_path.substr(image_path.find_last("/") + 1)
		else:
			path += image_path
			
		if not File.new().file_exists(path): return null
			
		print("Returning texture: " + path)
		
		return load(path)
		pass
		
	func _build_4_and_5_points_patch(patch)->void:
		var uv1_0 : Vector2
		var uv1_1 : Vector2
		var uv1_2 : Vector2
		var uv1_3 : Vector2
		var uv1_4 : Vector2
		var uv2_0 : Vector2
		var uv2_1 : Vector2
		var uv2_2 : Vector2
		var uv2_3 : Vector2
		var uv2_4 : Vector2
		var vect2 : Vector2 = Vector2()
				
		var normals_indexes:Array
		var cps : Array
		var uvs1 : Array = []
		var uvs2:Array = []
		
		cps = patch.cps
		normals_indexes = patch.normals_indexes
		if patch.patch_uvs_1 != null: uvs1 = patch.patch_uvs_1.uvs
		if patch.patch_uvs_2 != null: uvs2 = patch.patch_uvs_2.uvs
			
		#Some older models do not seem to have normals saved intheir files
		if normals_indexes.size() == 0:
			normals_indexes = zeroed_normals_indexes
		
		if not uvs1.empty():
			uv1_0 = uvs1[0].coords
			uv1_1 = uvs1[1].coords
			uv1_2 = uvs1[2].coords
			uv1_3 = uvs1[3].coords
			if uvs1.size() == 5:
				uv1_4 = uvs1[4].coords
		else:
			uv1_0 = vect2
			uv1_1 = vect2
			uv1_2 = vect2
			uv1_3 = vect2
			uv1_4 = vect2
		if not uvs2.empty():
			uv2_0 = uvs2[0].coords
			uv2_1 = uvs2[1].coords
			uv2_2 = uvs2[2].coords
			uv2_3 = uvs2[3].coords
			if uvs2.size() == 5:
				uv2_4 = uvs2[4].coords
		else:
			uv2_0 = vect2
			uv2_1 = vect2
			uv2_2 = vect2
			uv2_3 = vect2
			uv2_4 = vect2
			
		_builder.add_polygon(
			cps[2].get_position(), cps[1].get_position(), cps[0].get_position(),
			_normals[normals_indexes[2]], _normals[normals_indexes[1]], _normals[normals_indexes[0]],
			uv1_2, uv1_1, uv1_0,
			uv2_2, uv2_1, uv2_0,
			cps[2].get_bones_data(), cps[1].get_bones_data(), cps[0].get_bones_data()
		) 
		
		_builder.add_polygon(
			cps[2].get_position(), cps[0].get_position(), cps[3].get_position(),
			_normals[normals_indexes[2]], _normals[normals_indexes[0]], _normals[normals_indexes[3]],
			uv1_2, uv1_0, uv1_3,
			uv2_2, uv2_0, uv2_3,
			cps[2].get_bones_data(), cps[0].get_bones_data(), cps[3].get_bones_data()
		) 
		if patch.is_5_points_patch:
			_builder.add_polygon(
				cps[3].get_position(), cps[0].get_position(), cps[4].get_position(),
				_normals[normals_indexes[3]], _normals[normals_indexes[0]], _normals[normals_indexes[4]],
				uv1_3, uv1_0, uv1_4,
				uv2_3, uv2_0, uv2_4,
				cps[3].get_bones_data(), cps[0].get_bones_data(), cps[4].get_bones_data()
			) 
		pass
		
	func _build_hook_patches(hook_patches:Array)->void:
		if hook_patches.size() == 0: return
		
		#Dictionary of arrays that containing the patches in order, accordint to the
		#distance percent it is attached to the cp
		var section_and_its_patches:Dictionary = {}
		
		#Collect all the continuous hook patches
		#Becasue you can have more than one hook attached to the same spline section
		#a hook patch can have 2 hooks 
		
		#The main host of all of the hooks cps in a hooks patch is allways
		# the cp of the spline to which the first hook cp is attacehd too.
		#Becasue of this, in order to determine if the hook patches are siblings
		#we just need to get the main host of any of the hook cps of the patches
		#in order to determine that they are in the same spline section
		#But also make sure the (direct)host cp of the hook i son the same spline
		#this is because a hook in a patch perpendiculat to another patch hook can
		#be hooked to a parent that it's main host is the same for both
		for i in range(hook_patches.size()):
			var hook_patch = hook_patches[i]
			var patchesSectionId = hook_patch.hook_cps[0].GetFirstHostNoneHookCp().cp_num
			if not section_and_its_patches.has(patchesSectionId):
				section_and_its_patches[patchesSectionId] = []
				
			section_and_its_patches[patchesSectionId].append(hook_patch)
		
		var hook_patch_service = _hook_patch_service_resource.HookPathService.new()
		
#		#Sort each array by the percent distance from host cp 
		var patches:Array = section_and_its_patches.values()
		var patchesService = _hook_patch_service_resource.HookPathService.new()
		var all_ordered_patches:Array=[]
		for i in range(patches.size()):
			all_ordered_patches.append(patchesService.get_hook_patches(patches[i]))
			
		for i in range(all_ordered_patches.size()):
			#This should not be nessesary becasue Am seems to not allow
			#More than 3 hooks per patch
			_build_hooks_sections_patches(all_ordered_patches[i])
		pass
		
	func _build_hooks_sections_patches(ordered_sibbling_patches:Array)->void:
#		if ordered_sibbling_patches.size() > 2:
#			var ddd = 0
		
		
		var left_cp_data:PolygonData = _get_left_cp_data(ordered_sibbling_patches.front())
		var right_cp_data:PolygonData = _get_right_cp_data(ordered_sibbling_patches.back())
		
		var left_count:int = ordered_sibbling_patches.size()/2
		var polys_data:Array = []
		for i in range(ordered_sibbling_patches.size()):
			var poly_data : PolygonData
			if i == ordered_sibbling_patches.size() -1:#last right polygon
				poly_data = _get_last_right_hook_poly_data(ordered_sibbling_patches[i], right_cp_data)
			elif i < left_count:#Left polygons
				poly_data = _get_hook_poly_data(ordered_sibbling_patches[i], left_cp_data)
			else:#right polygons
				poly_data = _get_hook_poly_data(ordered_sibbling_patches[i], right_cp_data)
				
			polys_data.append(poly_data)
			_add_polygon(poly_data)
			
		
#		var t = 0
#		if _is_hooks_patches_an_even_build(ordered_sibbling_patches.size()):
		#Fill the center with a triangle
		_add_center_poly(polys_data, left_cp_data, right_cp_data)
#		else:
#			#Fill the center with a square/two trinagles
#			_AddCenterSquarePolygons(polys_data, ordered_sibbling_patches.size())
#		pass
		
	func _get_left_cp_data(firstPatch)->PolygonData:
		var index:int = 0
		var left_cp = firstPatch.OrderedCps[index]
		var data = PolygonData.new()
		data.pos_1 = left_cp.get_position()
		data.norm_1 = _normals[firstPatch.OrderedNormIndexes[index]] if firstPatch.OrderedNormIndexes.size() > 0 else Vector3()
		
		if firstPatch.OrderedUvs1 == null or firstPatch.OrderedUvs1.empty():
			data.uv_1 = Vector2()
		else:
			data.uv_1 = firstPatch.OrderedUvs1[index].coords
			
		data.uv_2 = data.uv_1 
		data.bone_data_1 = left_cp.get_bones_data()
		return data
		pass
		
	func _get_right_cp_data(lastPatch)->PolygonData:
		var index:int=2
		var right_cp = lastPatch.OrderedCps[index]
		var data = PolygonData.new()
		data.pos_1 = right_cp.get_position()
		data.norm_1 = _normals[lastPatch.OrderedNormIndexes[index]] if lastPatch.OrderedNormIndexes.size() > 0 else Vector3()
		
		if lastPatch.OrderedUvs1 == null or lastPatch.OrderedUvs1.empty():
			data.uv_1 = Vector2()
		else:
			data.uv_1 = lastPatch.OrderedUvs1[index].coords
		
		data.uv_2 = data.uv_1 
		data.bone_data_1 = right_cp.get_bones_data()
		return data
		pass
		
	func _add_center_poly(polys_data:Array, left_data:PolygonData, right_data:PolygonData)->void:
		var half:int = polys_data.size()/2
		var centerCpPolyData:PolygonData = polys_data[half - 1]
		
		var new_poly_data:PolygonData = PolygonData.new()
		new_poly_data.pos_1 = left_data.pos_1 
		new_poly_data.pos_2 = centerCpPolyData.pos_2
		new_poly_data.pos_3 = right_data.pos_1
		
		new_poly_data.norm_1 = left_data.norm_1
		new_poly_data.norm_2 = centerCpPolyData.norm_2
		new_poly_data.norm_3 = right_data.norm_1
		
		new_poly_data.uv_1 = left_data.uv_1
		new_poly_data.uv_2 = centerCpPolyData.uv_2
		new_poly_data.uv_3 = right_data.uv_1
		
		new_poly_data.uv2_1 = left_data.uv2_1
		new_poly_data.uv2_2 = centerCpPolyData.uv2_2
		new_poly_data.uv2_3 = right_data.uv2_1
		
		new_poly_data.bone_data_1 = left_data.bone_data_1
		new_poly_data.bone_data_2 = centerCpPolyData.bone_data_2
		new_poly_data.bone_data_3 = right_data.bone_data_1
		_add_polygon(new_poly_data)
		pass
		
	func _AddCenterSquarePolygons(polys_data:Array, totalPatches:int)->void:
		var left_count = totalPatches / 2
		var left_data:PolygonData = polys_data[left_count - 1]
		var right_data:PolygonData = polys_data[left_count - 1]
		
		#Actual cps = 0,2,(2) - 2,(0),(2)
		#Positions as PolygonData = 3,2,(2) - 2,(3),(2)
		var new_poly_data:PolygonData = PolygonData.new()
		new_poly_data.pos_1 = left_data.pos_3
		new_poly_data.pos_2 = left_data.pos_2
		new_poly_data.pos_3 = right_data.pos_2
		
		new_poly_data.norm_1 = left_data.norm_3
		new_poly_data.norm_2 = left_data.norm_2
		new_poly_data.norm_3 = right_data.norm_2
		
		new_poly_data.uv_1 = left_data.uv_3
		new_poly_data.uv_2 = left_data.uv_2
		new_poly_data.uv_3 = right_data.uv_2
		
		new_poly_data.uv2_1 = left_data.uv2_3
		new_poly_data.uv2_2 = left_data.uv2_2
		new_poly_data.uv2_3 = right_data.uv2_2
		
		new_poly_data.bone_data_1 = left_data.bone_data_3
		new_poly_data.bone_data_2 = left_data.bone_data_2
		new_poly_data.bone_data_3 = right_data.bone_data_2
		_add_polygon(new_poly_data)
		
		new_poly_data = PolygonData.new()
		new_poly_data.pos_1 = left_data.pos_2
		new_poly_data.pos_2 = right_data.pos_3
		new_poly_data.pos_3 = right_data.pos_2
		
		new_poly_data.norm_1 = left_data.norm_2
		new_poly_data.norm_2 = right_data.norm_3
		new_poly_data.norm_3 = right_data.norm_2
		
		new_poly_data.uv_1 = left_data.uv_2
		new_poly_data.uv_2 = right_data.uv_3
		new_poly_data.uv_3 = right_data.uv_2
		
		new_poly_data.uv2_1 = left_data.uv2_2
		new_poly_data.uv2_2 = right_data.uv2_3
		new_poly_data.uv2_3 = right_data.uv2_2
		
		new_poly_data.bone_data_1 = left_data.bone_data_2
		new_poly_data.bone_data_2 = right_data.bone_data_3
		new_poly_data.bone_data_3 = right_data.bone_data_2
		_add_polygon(new_poly_data)
		pass
		
	func _add_polygon(poly_data:PolygonData)->void:
		_builder.add_polygon(
					poly_data.pos_1, poly_data.pos_2, poly_data.pos_3, 
					poly_data.norm_1, poly_data.norm_2, poly_data.norm_3,  
					poly_data.uv_1, poly_data.uv_2, poly_data.uv_3, 
					poly_data.uv2_1, poly_data.uv2_2, poly_data.uv2_3,
					poly_data.bone_data_1, poly_data.bone_data_2, poly_data.bone_data_3
				)
		pass
		
	func _is_hooks_patches_an_even_build(patches_count:int)->bool:
		var count_str:String = str(patches_count)
		var last_num:String = count_str.left(1)
		match(last_num):
			"2", "4", "6", "8", "0":
				return true
			_:
				return false
		pass
			
	func _get_hook_poly_data(hookPatch, corner_cp_data:PolygonData)->PolygonData:
		var uv1_0 : Vector2
		var uv1_1 : Vector2
		var uv1_2 : Vector2
		var uv1_3 : Vector2
		var uv1_4 : Vector2
		var uv2_0 : Vector2
		var uv2_1 : Vector2
		var uv2_2 : Vector2
		var uv2_3 : Vector2
		var uv2_4 : Vector2
		var normals_indexes:Array = hookPatch.OrderedNormIndexes
		var uvs1 : Array = []
		var uvs2 : Array = []
		
		if normals_indexes.size() == 0:
				normals_indexes = zeroed_normals_indexes
		
		if not hookPatch.OrderedUvs1.empty():
			uv1_0 = hookPatch.OrderedUvs1[0].coords
			uv1_1 = hookPatch.OrderedUvs1[1].coords
			uv1_2 = hookPatch.OrderedUvs1[2].coords
			uv1_3 = hookPatch.OrderedUvs1[3].coords
			if hookPatch.OrderedUvs1.size() == 5:
				uv1_4 = hookPatch.OrderedUvs1[4].coords
		if not hookPatch.OrderedUvs2.empty():
			uv2_0 = hookPatch.OrderedUvs2[0].coords
			uv2_1 = hookPatch.OrderedUvs2[1].coords
			uv2_2 = hookPatch.OrderedUvs2[2].coords
			uv2_3 = hookPatch.OrderedUvs2[3].coords
			if hookPatch.OrderedUvs2.size() == 5:
				uv2_4 = hookPatch.OrderedUvs2[4].coords
			
			
		var data:PolygonData = PolygonData.new()
		data.pos_1 = hookPatch.OrderedCps[1].get_position()
		data.pos_2 = hookPatch.OrderedCps[2].get_position()
		data.pos_3 = corner_cp_data.pos_1
		data.norm_1 = _normals[normals_indexes[1]]
		data.norm_2 = _normals[normals_indexes[2]]
		data.norm_3 = corner_cp_data.norm_1
		data.uv_1 = uv1_1
		data.uv_2 = uv1_2
		data.uv_3 = corner_cp_data.uv_1
		data.uv2_1 = uv2_1
		data.uv2_2 = uv2_2
		data.uv2_3 = corner_cp_data.uv2_1
		data.bone_data_1 = hookPatch.OrderedCps[1].get_bones_data()
		data.bone_data_2 = hookPatch.OrderedCps[2].get_bones_data()
		data.bone_data_3 = corner_cp_data.bone_data_1
		return data
		pass
		
	func _get_last_right_hook_poly_data(hookPatch, right_cp_data:PolygonData)->PolygonData:
		var uv1_0 : Vector2
		var uv1_1 : Vector2
		var uv1_2 : Vector2
		var uv1_3 : Vector2
		var uv1_4 : Vector2
		var uv2_0 : Vector2
		var uv2_1 : Vector2
		var uv2_2 : Vector2
		var uv2_3 : Vector2
		var uv2_4 : Vector2
		var normals_indexes:Array = hookPatch.OrderedNormIndexes
		var uvs1 : Array = []
		var uvs2 : Array = []
		
		if normals_indexes.size() == 0:
				normals_indexes = zeroed_normals_indexes
		
		if not hookPatch.OrderedUvs1.empty():
			uv1_0 = hookPatch.OrderedUvs1[0].coords
			uv1_1 = hookPatch.OrderedUvs1[1].coords
			uv1_2 = hookPatch.OrderedUvs1[2].coords
			uv1_3 = hookPatch.OrderedUvs1[3].coords
			if hookPatch.OrderedUvs1.size() == 5:
				uv1_4 = hookPatch.OrderedUvs1[4].coords
		if not hookPatch.OrderedUvs2.empty():
			uv2_0 = hookPatch.OrderedUvs2[0].coords
			uv2_1 = hookPatch.OrderedUvs2[1].coords
			uv2_2 = hookPatch.OrderedUvs2[2].coords
			uv2_3 = hookPatch.OrderedUvs2[3].coords
			if hookPatch.OrderedUvs2.size() == 5:
				uv2_4 = hookPatch.OrderedUvs2[4].coords


		var data:PolygonData = PolygonData.new()
		data.pos_1 = hookPatch.OrderedCps[0].get_position()
		data.pos_2 = hookPatch.OrderedCps[1].get_position()
		data.pos_3 = hookPatch.OrderedCps[2].get_position()
		data.norm_1 = _normals[normals_indexes[0]]
		data.norm_2 = _normals[normals_indexes[1]]
		data.norm_3 = _normals[normals_indexes[2]]
		data.uv_1 = uv1_0
		data.uv_2 = uv1_1
		data.uv_3 = uv1_2
		data.uv2_1 = uv2_0
		data.uv2_2 = uv2_1
		data.uv2_3 = uv2_2
		data.bone_data_1 = hookPatch.OrderedCps[0].get_bones_data()
		data.bone_data_2 = hookPatch.OrderedCps[1].get_bones_data()
		data.bone_data_3 = hookPatch.OrderedCps[2].get_bones_data()
		return data
		pass
		
	class PolygonData:
		var pos_1:Vector3
		var pos_2:Vector3
		var pos_3:Vector3
		var norm_1:Vector3
		var norm_2:Vector3
		var norm_3:Vector3
		var uv_1:Vector2
		var uv_3:Vector2
		var uv_2:Vector2
		var uv2_1:Vector2
		var uv2_3:Vector2
		var uv2_2:Vector2
		var bone_data_1:Array
		var bone_data_2:Array
		var bone_data_3:Array
