class SceneGenerator:
	var _am_model_resource : Resource = preload("res://addons/AMModelImporterAsScene/am_model.gd")
	var _am_action_resource:Resource = preload("res://addons/AMModelImporterAsScene/action/am_action.gd")
	var _am_bone_resource:Resource = preload("res://addons/AMModelImporterAsScene/bone.gd")
	var _files_service_resource:Resource = preload("res://addons/AMModelImporterAsScene/Files/files_service.gd")
	
	var _am_model
	var _skeleton:Skeleton
	
	var _source_path:String
	var _options:Dictionary
	var _files_paths:Array = []
	
	func _init(source_path:String, options:Dictionary):
		self._source_path = source_path
		self._options = options
		pass
		
	func generate_packed_scene()->PackedScene:
		var error
		
		var path : String = _source_path.substr(0, _source_path.find_last("\/") + 1)#.replace(" ", "_")
		_files_paths = _files_service_resource.FilesService.new().get_filelist(path)
		
		_am_model = _am_model_resource.AmModel.new(_source_path, _files_paths)
		error = _am_model.load_model()
		if error != OK: return error
		
		_skeleton = Skeleton.new()
			
		var character:Spatial = Spatial.new()
		character.name = "Character"
		if _am_model.all_bones.size() > 0:
			character.add_child(_skeleton)
			_skeleton.owner = character
			_add_bones_to_skeleton()
			
		var mesh = _am_model.get_polygon_mesh(_options)
		var mesh_instance:MeshInstance = MeshInstance.new()
		mesh_instance.mesh = mesh
		if _am_model.all_bones.size() > 0:
			_skeleton.add_child(mesh_instance)
			mesh_instance.owner = character
			mesh_instance.skeleton = mesh_instance.get_path_to(_skeleton)
		else:
			character.add_child(mesh_instance)
			mesh_instance.owner = character
		
		if _am_model.all_bones.size() > 0:
			#Actions
			var actions_paths:Array = _get_actions_paths()
			
#			character.set_script(AMCharacter)
			
			#Create actions as animations and add them as child of the skeleton
			var animation_player :AnimationPlayer = AnimationPlayer.new()
#			(character as AMCharacter).actions = animation_player
			animation_player.name = "Actions"
			character.add_child(animation_player)
			animation_player.owner = character
			for i in range(actions_paths.size()):
				_add_action_as_animation(actions_paths[i], animation_player)
		
		print("packing")
		var scene = PackedScene.new()
		var result = scene.pack(character)
		
		return scene
		pass
		
	func _add_action_as_animation(action_path:String, anim_player:AnimationPlayer)->void:
		var animation = _am_action_resource.AmAction.new(action_path, _am_model, _skeleton, anim_player.get_path_to(_skeleton)).generate_animation()
		anim_player.add_animation(action_path.substr(action_path.find_last("\/") + 1), animation)
		pass
		
	func _get_all_files_paths()->Array:
		var actions_paths:Array = []
		for i in range(_files_paths.size()):
			var file_name:String = _files_paths[i]
			if file_name.find_last(".act") + 4 == file_name.length(): actions_paths.append(file_name)
		return actions_paths
		pass
		
	func _get_actions_paths()->Array:
		var path : String = _source_path.substr(0, _source_path.find_last("\/") + 1)#.replace(" ", "_")
		var actions_paths:Array = []
		var files = _files_service_resource.FilesService.new().get_filelist(path)
		for i in range(files.size()):
			var file_name:String = files[i]
			if file_name.find_last(".act") + 4 == file_name.length(): actions_paths.append(file_name)
		return actions_paths
		pass
		
	var end_bones:Array=[]
	func _add_bones_to_skeleton()->void:
		#Add the mesh bone so that unassigned cps get assogned to this bone 
		#when building the polygin mesh
		_add_mesh_bone()
		
		#Godot requires the parent bones in the skeleton to allways
		#have a smaller index than the child, becasue of that 
		#we recreate the whole bone herarchy starting from the parents
		for i in range(_am_model.bones_herarchy.size()):
			_add_bone_globaly(_am_model.bones_herarchy[i])
			
		var all_bones:Array = _am_model.all_bones.values()
		for i in range(all_bones.size()):
			_assign_bone_parent(all_bones[i])
		pass
		
	func _add_mesh_bone()->void:
		var base_bone_name = "MeshBone"
		var t:Transform = Transform(Quat(Vector3()))
		t = t.scaled(Vector3(1,1,1))
		_skeleton.add_bone(base_bone_name)
		_skeleton.set_bone_rest(0, t)
		pass
		
	func _assign_bone_parent(bone)->void:
		if bone.parent == null: 
			#This is a main bone that is a child of the mesh bone
			_skeleton.set_bone_parent(bone.bone_id_in_skeleton, 0)
			return
		
		var parent_global:Transform = _skeleton.get_bone_global_pose(bone.parent.bone_id_in_skeleton)
		var child_global:Transform = _skeleton.get_bone_rest(bone.bone_id_in_skeleton)
		var rot:Quat = parent_global.basis.get_rotation_quat().inverse() * child_global.basis.get_rotation_quat()
		var t:Transform = Transform(rot, parent_global.xform_inv(child_global.origin))
		_skeleton.set_bone_parent(bone.bone_id_in_skeleton, bone.parent.bone_id_in_skeleton)
		_skeleton.set_bone_rest(bone.bone_id_in_skeleton, t)
		pass
		
	func _add_bone_globaly(bone)->void:
		var t:Transform = Transform(Basis(bone.rotation), bone.start)
		t = t.scaled(Vector3(1,1,1))
		_skeleton.add_bone(bone.name)
		bone.bone_id_in_skeleton = _skeleton.find_bone(bone.name)
		_skeleton.set_bone_rest(bone.bone_id_in_skeleton, t)
		
		if bone.children.size() == 0:
#			_add_bone_tip(bone)#for debugging purposes
			var d = 0
		else:
			for i in range(bone.children.size()):
				_add_bone_globaly(bone.children[i])
		pass
		
	func _add_bone_tip(bone)->void:
		var bone_global:Transform = Transform(bone.rotation, bone.start)
		_skeleton.add_bone(bone.name + "-" + "Tip")
		var tip = _skeleton.find_bone(bone.name + "-" + "Tip")
		var tip_local_translation:Vector3 = bone_global.xform_inv(bone.end)
		_skeleton.set_bone_rest(tip, Transform(Vector3(0,0,0),tip_local_translation))
		_skeleton.set_bone_parent(tip, bone.bone_id_in_skeleton)
		pass
