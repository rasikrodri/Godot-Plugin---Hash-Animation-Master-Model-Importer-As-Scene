class Decal:
	
	var patches_uvs:Dictionary = {}
	var albedo_image : String
	var specular_intensity_image:String
	var specular_size_image:String
	var ambiance_intensity_image:String
	var bump_image:String
	var transparency_image:String
	var reflectivity_image:String
	var normal_image:String
	
	var _patch_uvs_resource :Resource = preload("res://addons/AMModelImporterAsScene/patch_uvs.gd")
	
	var _uvs_stamps:Array = []
	var _file_paths:Array = []
	
	func _init(decal_node, model_cps:Dictionary, file_paths:Array):
		_file_paths = file_paths
		_assign_images(decal_node)
		_assing_uv_data(decal_node)
		
		for a in range(_uvs_stamps.size()):
			var patches:Array = _GetPatches(_uvs_stamps[a])
			if patches.size() > 0:
				_load_stamp(patches, model_cps)
		
		pass
		
	func _GetPatches(stamp:String)->Array:
		var patches:Array = stamp.strip_edges().split("\n")
		if patches.size() == 1:
			if patches[0].strip_edges().empty(): return []
		return patches
		pass
		
	func _assign_images(decal_node)->void:
#		var image_paths:Array = _get_images_paths()
		var decal_images:Array = decal_node.query(["DECALIMAGE"]).nodes
		for i in range(decal_images.size()):
			var dec_image = decal_images[i]
			var image_type_type = dec_image.get_property_value("DecalType")
			var image_path:String = dec_image.query(["Image"]).nodes[0].data
			var image_name:String = image_path.substr(image_path.find("\"")).replace("\"", "")
			
			var file_path:String = _get_image_path(image_name)
			
			match (image_type_type):
				"SpecularIntensity":
					specular_intensity_image = file_path
				"SpecularSize":
					specular_size_image = file_path
				"Ambiance":
					ambiance_intensity_image = file_path
				"Bump":
					bump_image = file_path
				"Transparency":
					transparency_image = file_path
				"Reflectivity":
					reflectivity_image = file_path
				"Normal":
					normal_image = file_path
				_:
					albedo_image = file_path
		pass
		
	func _get_image_path(image_name)->String:
		for i in range(_file_paths.size()):
			var path:String = _file_paths[i]
			if path.find_last(image_name) + image_name.length() == path.length(): return path
		return ""
		pass
		
	func _assing_uv_data(decal_node)->void:
		var stamps:Array = decal_node.query(["STAMPS"]).query(["STAMP"]).nodes
		for i in range(stamps.size()):
			var data_nodes:Array = stamps[i].query(["DATA"]).nodes
			if data_nodes.size() > 0:
				_uvs_stamps.append(data_nodes[0].data)
		pass
		
	func _load_stamp(patches:Array, model_cps:Dictionary)->void:
		#The first number is none sence
		#the next 4 numbers are the cps. This is for 3 and 4 cp patches. For 5
			#cps patches I will check latter
			
		#For some reason every cp has 3 Vectos3
		#we only need the first Vector3
		#Also we only need x and y since is a 2d coordinate
		for i in range(patches.size()):
			var splited : Array = patches[i].split(" ")
			#Skip the first number(it might be used to tell of it is a five point patch) it is 0

			var patch_uvs = _patch_uvs_resource.PatchUvs.new()
			
			
			patch_uvs.add_uv(model_cps[int(splited[1])], Vector2(float(splited[5]), float(splited[6])))
			patch_uvs.add_uv(model_cps[int(splited[2])], Vector2(float(splited[14]), float(splited[15])))
			patch_uvs.add_uv(model_cps[int(splited[3])], Vector2(float(splited[23]), float(splited[24])))
			patch_uvs.add_uv(model_cps[int(splited[4])], Vector2(float(splited[32]), float(splited[33])))
			
#			if splited[1] == "1312":
#				var dd = 6
			#The uvs do not have the 5th cp number but they do have its uv
			if splited[0] == '5': #This is a 5 points patch
				patch_uvs.add_uv(null, Vector2(float(splited[41]), float(splited[42])))

			patches_uvs[patch_uvs.generate_patch_id()] = patch_uvs
#			print("Patch Decal Id = " + patch_uvs.decal_patch_id)
		pass
