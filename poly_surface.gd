class PolySurface:
	var verts_indexes : Array = []
	var bones_indexes_arrays : Array = []#Godot suports up to 4 bones per vertex
	var bone_weights_arrays : Array = []#Godot suports up to 4 bones per vertex
	
	func _init():
		pass
		
	#Godot suports up to 4 bones per vertex
	func add_bones(bones_data:Array, mesh_bone_index:Array, mesh_bone_weights:Array)->void:
		if bones_data == null or bones_data.size() == 0: 
			bones_indexes_arrays.append(mesh_bone_index)
			bone_weights_arrays.append(mesh_bone_weights)
			return
		
		var indexes_arrays:Array = []
		bones_indexes_arrays.append(indexes_arrays)
		var weights_arrays:Array = []
		bone_weights_arrays.append(weights_arrays)
		
		for i in range(bones_data.size()):
			if i == 4:return#Godot suports up to 4 bones per vertex
			var bone_data = bones_data[i]
			indexes_arrays.append(bone_data.bone.bone_id_in_skeleton)
			weights_arrays.append(bone_data.weight)
			
		#Fill the arrays up to 4 items that are required for the surface tool
		#with the forst bone
		if indexes_arrays.size() == 1:
			var bone_data = bones_data[0]
			
#			if bone_data.cp_num == 3104:
#				var ddd = 0
			
			indexes_arrays.append(bone_data.bone.bone_id_in_skeleton)
			indexes_arrays.append(bone_data.bone.bone_id_in_skeleton)
			indexes_arrays.append(bone_data.bone.bone_id_in_skeleton)
			
			weights_arrays[0] = 0.25
			weights_arrays.append(0.25)
			weights_arrays.append(0.25)
			weights_arrays.append(0.25)
				
		elif indexes_arrays.size() == 2:
			var first = bones_data[0]
			var first_weight_half : float = first.weight / 2.0
			var second = bones_data[1]
			var second_weight_half : float = second.weight / 2.0
			
			indexes_arrays.append(first.bone.bone_id_in_skeleton)
			indexes_arrays.append(second.bone.bone_id_in_skeleton)
			
			weights_arrays[0] = first_weight_half
			weights_arrays[1] = second_weight_half
			
			weights_arrays.append(first_weight_half)
			weights_arrays.append(second_weight_half)
				
		elif indexes_arrays.size() == 3:
			var first = bones_data[0]
			var second = bones_data[1]
			var third = bones_data[1]
			
			var highest = first
			if second.weight > highest.weight: highest = second
			if third.weight > highest: highest = third
		
			var half:float = highest.weight / 2.0
			if highest == first:
				indexes_arrays[0] = highest.bone.bone_id_in_skeleton
				weights_arrays[0] = half
			elif second == highest:
				indexes_arrays[1] = highest.bone.bone_id_in_skeleton
				weights_arrays[1] = half
			else:
				indexes_arrays[1] = highest.bone.bone_id_in_skeleton
				weights_arrays[1] = half
			
			indexes_arrays.append(highest.bone.bone_id_in_skeleton)
			weights_arrays.append(half)
		else:
			#Nothing to do
			var ddd =4
		pass
