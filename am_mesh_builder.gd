class AmMeshBuilder:
	var _mdl_file_location : String
	var _model_cps : Dictionary = {}
	var _model_splines : Array = []
	var _model_patches : Array = []
	var _normals : Array = []
	var _decal1
	var _decal2
	
	var _mesh_builder_resource = preload("res://addons/AMModelImporterAsScene/mesh_builder.gd")
	var _hookPatchResource:Resource = preload("res://addons/AMModelImporterAsScene/services/hook_patch.gd")
	
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
		var patchesWithHooks:Array = []
		
		if _normals.size() == 0:
			_normals = zeroed_normals
			
		for i in range(_model_patches.size()):
			var patch = _model_patches[i]
			if patch.from_hook:
				patchesWithHooks.append(patch)
			else:
				_build_4_and_5_points_patch(patch)

		_build_hook_patches(patchesWithHooks)
		var mat : SpatialMaterial = SpatialMaterial.new()
		mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
		mat.albedo_texture = null
		
		#Only load images that are in the same folder than the model, for now!
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
			uv1_0 = uvs1[0].Coords
			uv1_1 = uvs1[1].Coords
			uv1_2 = uvs1[2].Coords
			uv1_3 = uvs1[3].Coords
			if uvs1.size() == 5:
				uv1_4 = uvs1[4].Coords
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
		
	func _build_hook_patches(patchesWithHooks:Array)->void:
		if patchesWithHooks.size() == 0: return
		
		#Oder them to forst create the left patches then the middle ones and then
		#the center ones. This wa we can easily get the uvs and normals from
		#the correct cps
		var edgeLeftPatches:Dictionary = {}
		var edgeMiddlePatches:Dictionary = {}
		
		var leftSidePatches:Array = []
		var middlePatches:Array = []
		var rightSidePatches:Array = []
		for i in range(patchesWithHooks.size()):
			var hookPatch = _hookPatchResource.HookPatch.new(patchesWithHooks[i])		
			var edgeId:String
			if hookPatch.IsPatchOnLeft():
				leftSidePatches.append(hookPatch)
			elif hookPatch.IsPstchInMiddle():
				middlePatches.append(hookPatch)
			else:#it is a right side patch
				rightSidePatches.append(hookPatch)
		
		#left polygons
		for i in range(leftSidePatches.size()):
			var hookPatch = leftSidePatches[i]
			var edgeId = _GenerateEdgeId(hookPatch, 0, 2)
			edgeLeftPatches[edgeId] = hookPatch
			_add_polygon(_GetPolyonData(hookPatch, 0, 1, 2))
			
		#midle polygons
		_CreateMiddlePolygons(middlePatches, edgeLeftPatches,edgeMiddlePatches)
			
		#Right polygons
		_CreateRightPolygons(rightSidePatches, edgeLeftPatches,edgeMiddlePatches)
			
		pass
		
	func _CreateMiddlePolygons(middlePatches:Array, edgeLeftPatches:Dictionary, edgeMiddlePatches:Dictionary)->void:
		var middlePatchesCopy:Array = middlePatches.duplicate()
		var originalSize:int = middlePatchesCopy.size()
		for i in range(middlePatchesCopy.size()):
			var hookPatch = middlePatches[i]
			var edgeIdLeftToRight = _GenerateEdgeId(hookPatch, 0, 1)
			var edgeIdRightToLeft = _GenerateEdgeId(hookPatch, 2, 3)
			
			var polygonCreated:bool = true
			if edgeLeftPatches.has(edgeIdLeftToRight):
				hookPatch.PreviewsHookPatch = edgeLeftPatches[edgeIdLeftToRight]
				_add_polygon(_GetPolyonDataForTwoSides(hookPatch, 1, 2, hookPatch.GetFirstHookPatch(), 0))
				edgeMiddlePatches[_GenerateEdgeId(hookPatch, 3, 2)] = hookPatch
			elif edgeLeftPatches.has(edgeIdRightToLeft):
				hookPatch.PreviewsHookPatch = edgeLeftPatches[edgeIdRightToLeft]
				_add_polygon(_GetPolyonDataForTwoSides(hookPatch, 1, 2, hookPatch.GetFirstHookPatch(), 3))
				edgeMiddlePatches[_GenerateEdgeId(hookPatch, 1, 0)] = hookPatch
			elif edgeMiddlePatches.has(edgeIdLeftToRight):
				hookPatch.PreviewsHookPatch = edgeMiddlePatches[edgeIdLeftToRight]
				_add_polygon(_GetPolyonDataForTwoSides(hookPatch, 1, 2, hookPatch.GetFirstHookPatch(), 0))
				edgeMiddlePatches[_GenerateEdgeId(hookPatch, 3, 2)] = hookPatch
			elif edgeMiddlePatches.has(edgeIdRightToLeft):
				hookPatch.PreviewsHookPatch = edgeMiddlePatches[edgeIdRightToLeft]
				_add_polygon(_GetPolyonDataForTwoSides(hookPatch, 1, 2, hookPatch.GetFirstHookPatch(), 3))
				edgeMiddlePatches[_GenerateEdgeId(hookPatch, 3, 2)] = hookPatch
			else:
				polygonCreated = false
				
			if polygonCreated: middlePatchesCopy.erase(hookPatch)
			
		#Exit if we could not create the polygons so that we do not
		#keep calling the same function for ever
		if middlePatchesCopy.size() == originalSize: return
		
		#This is nessesary becasue middle patches are going to only find it's previews patch.
		#If the patches are not in order form first to last patch in the patches section
		#Then some patches will be skiped and we need to call this function again.
		if middlePatchesCopy.size() > 0: _CreateMiddlePolygons(middlePatchesCopy, edgeLeftPatches, edgeMiddlePatches)
		pass
		
	func _CreateRightPolygons(rightSidePatches:Array, edgeLeftPatches:Dictionary, edgeMiddlePatches:Dictionary)->void:
		for i in range(rightSidePatches.size()):
			var hookPatch = rightSidePatches[i]
			var edgeIdLeftToRight = _GenerateEdgeId(hookPatch, 2, 3)
			var edgeIdRightToLeft = _GenerateEdgeId(hookPatch, 3, 0)
			var midEdgeIdLeftToRight = _GenerateEdgeId(hookPatch, 3, 0)
			var midIdRightToLeft = _GenerateEdgeId(hookPatch, 2, 2)
			
			if edgeLeftPatches.has(edgeIdLeftToRight):
				hookPatch.PreviewsHookPatch = edgeLeftPatches[edgeIdLeftToRight]
				_add_polygon(_GetPolyonDataForTwoSides(hookPatch, 0, 2, hookPatch.GetFirstHookPatch(), 3))
				_add_polygon(_GetPolyonData(hookPatch, 0, 1, 2))
			elif edgeLeftPatches.has(edgeIdRightToLeft):
				hookPatch.PreviewsHookPatch = edgeLeftPatches[edgeIdRightToLeft]
				_add_polygon(_GetPolyonDataForTwoSides(hookPatch, 0, 2, hookPatch.GetFirstHookPatch(), 0))
				_add_polygon(_GetPolyonData(hookPatch, 0, 1, 2))
			elif edgeMiddlePatches.has(midEdgeIdLeftToRight):
				hookPatch.PreviewsHookPatch = edgeMiddlePatches[midEdgeIdLeftToRight]
				_add_polygon(_GetPolyonDataForTwoSides(hookPatch, 0, 2, hookPatch.GetFirstHookPatch(), 0))
				_add_polygon(_GetPolyonData(hookPatch, 0, 1, 2))
			elif edgeMiddlePatches.has(midIdRightToLeft):
				hookPatch.PreviewsHookPatch = edgeMiddlePatches[midIdRightToLeft]
				_add_polygon(_GetPolyonDataForTwoSides(hookPatch, 0, 2, hookPatch.GetFirstHookPatch(), 3))
				_add_polygon(_GetPolyonData(hookPatch, 0, 1, 2))
		pass
		
	func _GenerateEdgeId(hookPatch, vetIndex1:int, verIndex2:int)->String:
		return str(hookPatch.OrderedCps[vetIndex1].get_main_cp_host_num()) + "-" +str(hookPatch.OrderedCps[verIndex2].get_main_cp_host_num())
		pass
		
	func _GetPolyonDataForTwoSides(leftHookPatch, leftIndexForVert1:int, leftIndexForVert2:int,
									rightHookPatch, rightIndexForVert3:int)->PolygonData:
		var data:PolygonData = PolygonData.new()
		
		var hasNormals:bool = leftHookPatch.OrderedNormIndexes.size() > 0
		var hasUvs1:bool = leftHookPatch.OrderedUvs1.size() > 0
		var hasUvs2:bool = leftHookPatch.OrderedUvs2.size() > 0
		
		data.pos_1 = leftHookPatch.OrderedCps[leftIndexForVert1].get_position()
		if hasNormals: data.norm_1 = leftHookPatch.OrderedNormIndexes[leftIndexForVert1]
		if hasUvs1: data.uv_1 = leftHookPatch.OrderedUvs1[leftIndexForVert1].Coords
		if hasUvs2: data.uv2_1 = leftHookPatch.OrderedUvs2[leftIndexForVert1].Coords
		data.bone_data_1 = leftHookPatch.OrderedCps[leftIndexForVert1].get_bones_data()	
		
		data.pos_2 = leftHookPatch.OrderedCps[leftIndexForVert2].get_position()
		if hasNormals: data.norm_2 = leftHookPatch.OrderedNormIndexes[leftIndexForVert2]
		if hasUvs1: data.uv_2 = leftHookPatch.OrderedUvs1[leftIndexForVert2].Coords
		if hasUvs2: data.uv2_2 = leftHookPatch.OrderedUvs2[leftIndexForVert2].Coords
		data.bone_data_2 = leftHookPatch.OrderedCps[leftIndexForVert2].get_bones_data()		
		
		data.pos_3 = rightHookPatch.OrderedCps[rightIndexForVert3].get_position()
		if hasNormals: data.norm_3 = rightHookPatch.OrderedNormIndexes[rightIndexForVert3]
		if hasUvs1: data.uv_3 = rightHookPatch.OrderedUvs1[rightIndexForVert3].Coords
		if hasUvs2: data.uv2_3 = rightHookPatch.OrderedUvs2[rightIndexForVert3].Coords
		data.bone_data_3 = rightHookPatch.OrderedCps[rightIndexForVert3].get_bones_data()
		
		return data
		pass
	
	func _GetPolyonData(hookPatch, vert1Index:int, vert2Index:int, vert3Index:int)->PolygonData:
		var data:PolygonData = PolygonData.new()
		
		var hasNormals:bool = hookPatch.OrderedNormIndexes.size() > 0
		var hasUvs1:bool = hookPatch.OrderedUvs1.size() > 0
		var hasUvs2:bool = hookPatch.OrderedUvs2.size() > 0
		
		data.pos_1 = hookPatch.OrderedCps[vert1Index].get_position()
		if hasNormals: data.norm_1 = hookPatch.OrderedNormIndexes[vert1Index]
		if hasUvs1: data.uv_1 = hookPatch.OrderedUvs1[vert1Index].Coords
		if hasUvs2: data.uv2_1 = hookPatch.OrderedUvs2[vert1Index].Coords
		data.bone_data_1 = hookPatch.OrderedCps[vert1Index].get_bones_data()	
		
		data.pos_2 = hookPatch.OrderedCps[vert2Index].get_position()
		if hasNormals: data.norm_2 = hookPatch.OrderedNormIndexes[vert2Index]
		if hasUvs1: data.uv_2 = hookPatch.OrderedUvs1[vert2Index].Coords
		if hasUvs2: data.uv2_2 = hookPatch.OrderedUvs2[vert2Index].Coords
		data.bone_data_2 = hookPatch.OrderedCps[vert2Index].get_bones_data()		
		
		data.pos_3 = hookPatch.OrderedCps[vert3Index].get_position()
		if hasNormals: data.norm_3 = hookPatch.OrderedNormIndexes[vert3Index]
		if hasUvs1: data.uv_3 = hookPatch.OrderedUvs1[vert3Index].Coords
		if hasUvs2: data.uv2_3 = hookPatch.OrderedUvs2[vert3Index].Coords
		data.bone_data_3 = hookPatch.OrderedCps[vert3Index].get_bones_data()
		
		return data
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
