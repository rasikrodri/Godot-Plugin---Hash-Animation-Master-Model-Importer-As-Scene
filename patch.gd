class Patch:
	var patch_id_generator_resource : Resource = preload("res://addons/AMModelImporterAsScene/patch_id_generator.gd")
	
	var is_3_points_patch : bool
	var is_4_points_patch : bool
	var is_5_points_patch : bool
	var from_hook : bool
	var first_hook_cp
	var first_hook_cp_index : int
	var hook_cps:Array = []
	
	#Used to quickly identify the decal uvs that correspond to this patch
	var decal_patch_id : String
	
	#Godot allows up to 2 uvs by default because a game ubject should not have more
	#or it will slow down the game
	var patch_uvs_1 = null
	var patch_uvs_2 = null
	
	var _unknown_first : String
	var cps : Array
	var normals_indexes : Array = []
	
	func _init(data: String, model_cps : Dictionary):
		# 3 and 4 cps patches
		#Patches with of 3 cps and 4 cps are written with four cps
		#You can identify a 3 cps patch when the first cp is the same as the last cp
#		print(data)
		
		var splited = data.split(" ")
		
		if splited.size() == 6 or splited.size() == 12: 
			is_5_points_patch = true
		elif splited.size() == 10:
			if splited[1] == splited[4]:
				is_3_points_patch = true
			else:
				is_4_points_patch = true
		
		_unknown_first = splited[0]
		cps.append(model_cps[int(splited[1])])
		cps.append(model_cps[int(splited[2])])
		cps.append(model_cps[int(splited[3])])
		cps.append(model_cps[int(splited[4])])
		var normals_start : int = 5
		if is_5_points_patch: 
			cps.append(model_cps[int(splited[5])])
			normals_start = 6

#Some older models do not seem to have normals saved intheir files
#		if splited.size() > normals_start:
#			normals_indexes.append(int(splited[normals_start]))
#			normals_start += 1
#			normals_indexes.append(int(splited[normals_start]))
#			normals_start += 1
#			normals_indexes.append(int(splited[normals_start]))
#			normals_start += 1
#			normals_indexes.append(int(splited[normals_start]))
#			normals_start += 1
#			normals_indexes.append(int(splited[normals_start]))
#			normals_start += 1
#			if is_5_points_patch:
#				normals_indexes.append(int(splited[normals_start]))
			
#		if cps[0].get_main_cp_host_num() == 1312:
#			var dd = 6
		var id_generator = patch_id_generator_resource.PatchIdGenerator.new()
		var cp_nums:Array = [cps[0].get_main_cp_host_num(), cps[1].get_main_cp_host_num(), cps[2].get_main_cp_host_num(), cps[3].get_main_cp_host_num()]
		if cps.size() == 5: cp_nums.append(cps[4].get_main_cp_host_num())
		decal_patch_id = id_generator.generate_id(cp_nums)
			
		for i in range(cps.size()):
			var curr_cp = cps[i]
			if curr_cp.is_hook:
				hook_cps.append(curr_cp)
				if hook_cps.size() == 1:
					from_hook = true
					first_hook_cp = curr_cp
					first_hook_cp_index = i
		
		pass
