class AmAction:
	var _am_action_resurce : Resource = preload("res://addons/AMModelImporterAsScene/am_xml_load/xml_loader.gd")
	var _translate_keys_resource :Resource = preload("res://addons/AMModelImporterAsScene/action/translate_keys.gd")
	var _rotate_keys_resource :Resource = preload("res://addons/AMModelImporterAsScene/action/rotate_keys.gd")
	var _key_resource :Resource = preload("res://addons/AMModelImporterAsScene/action/key.gd")
	
	var _track_resource:Resource = preload("res://addons/AMModelImporterAsScene/action/transform_keys_track.gd")
	
	var _resource_path:String
	var _am_model
	var _skeleton:Skeleton
	var _path_to_skeleton:String
	
	var _current_animation : Animation
	var _current_track_id :int = -1
	
	#######Use Import options
	var _action_frames_per_sec:float = 30.0
	var _one_track_per_bone:bool = true
	#######
	
#	var _xml_document:XMLParser
#
#	var start_miliseconds:int
#	var end_miliseconds:int
#	var bones:Dictionary

#	var _speed_normal:float
	var _frame_spacing:float
	
	func _init(resource_path:String, am_model, skeleton:Skeleton, path_to_skeleton:String):
		_resource_path = resource_path
		_am_model = am_model
		_skeleton = skeleton
		_path_to_skeleton = path_to_skeleton
		pass
		
	func generate_animation()->Animation:
		if _current_animation != null: _current_animation.free()
		_current_animation = Animation.new()
		
		var loader = _am_action_resurce.XmlLoader.new(_resource_path)
		var main_node = loader.get_node_tree()
		
#		_speed_normal = 60 / _action_frames_per_sec
		_frame_spacing = 1 / _action_frames_per_sec
		
		var action = main_node.query(["ACTION"]).nodes[0]
		_current_animation.length = _get_frame_number(action.get_property_value("Frames"))
		
		_load_bones_keys(main_node)
		
		return _current_animation
		pass
		
	func _add_animation_track(track_type:int, bone_path:String)->void:
		_current_animation.add_track(track_type)
		_current_track_id = _current_animation.get_track_count() - 1
		_current_animation.track_set_path(_current_track_id, bone_path)
		_current_animation.track_set_imported(_current_track_id, true)
		pass
		
	func _load_bones_keys(main_node)->void:
		var zero_translation:Vector3 = Vector3(0,0,0)
		var zero_rotation:Quat = Quat(Vector3(0,0,0))
		var query_result = main_node.query(["ACTION"]).query(["OBJECTSHORTCUT"], ["MatchName=Bones"]).query(["OBJECTSHORTCUT"])
		for a in range(query_result.nodes.size()):
			var bone_name:String = str(query_result.nodes[a].get_property_value("MatchName"))
			if bone_name == "Head":
				var dd = 0
				
			if _am_model.all_bones.has(bone_name):
				var bone = _am_model.all_bones[bone_name]
				
				var translate_keys = _get_translate_keys(query_result.nodes[a].query(["EMPTYDRIVER"], ["MatchName=Transform"]).query(["EMPTYDRIVER"], ["MatchName=Translate"]).query(["TRANSLATECHANNELDRIVER"]).nodes)
				translate_keys._compute_complete_keys(zero_translation)
				var rotate_keys = _get_rotate_keys(query_result.nodes[a].query(["EMPTYDRIVER"], ["MatchName=Transform"]).query(["QUATERNIONROTATEDRIVER", "VECTORROTATEDRIVER"], ["MatchName=Rotate"]).query(["CHANNELDRIVER"]).nodes)
				rotate_keys._compute_complete_keys(zero_rotation)
				
				var translate_backed_dynamic_constraint_keys = _get_translate_keys(query_result.nodes[a].query(["EMPTYDRIVER"], ["MatchName=Transform"]).query(["DYNAMICRESULTSDRIVER"], ["MatchName=Translate"]).query(["TRANSLATECHANNELDRIVER"]).nodes)
				translate_backed_dynamic_constraint_keys._compute_complete_keys(zero_translation)
				var rotate_backed_dynamic_constraint_keys = _get_rotate_keys(query_result.nodes[a].query(["EMPTYDRIVER"], ["MatchName=Transform"]).query(["DYNAMICRESULTSDRIVER"], ["MatchName=Rotate"]).query(["CHANNELDRIVER"]).nodes)
				rotate_backed_dynamic_constraint_keys._compute_complete_keys(zero_rotation)
				
				if _one_track_per_bone:
					#Merge the dynamic constraints generated keys with the previews keys
					translate_keys.merge_override_keys(translate_backed_dynamic_constraint_keys, zero_translation)
					rotate_keys.merge_override_keys(rotate_backed_dynamic_constraint_keys, zero_rotation)
					var track = _track_resource.TranformKeysTrack.new(zero_translation, zero_rotation, Vector3(1,1,1))
					
					track.set_tranform_keys(translate_keys, rotate_keys, null)
					_add_track_to_animation(bone, track.get_transforms())
				else:
					var track = _track_resource.TranformKeysTrack.new(zero_translation, zero_rotation, Vector3(1,1,1))
					track.set_tranform_keys(translate_keys, rotate_keys, null)
					_add_track_to_animation(bone, track.get_transforms())
					
					track = _track_resource.TranformKeysTrack.new(zero_translation, zero_rotation, Vector3(1,1,1))
					track.set_tranform_keys(translate_backed_dynamic_constraint_keys, rotate_backed_dynamic_constraint_keys, null)
					_add_track_to_animation(bone, track.get_transforms())
		pass
	
	func _add_track_to_animation(bone, transform_keys:Array)->void:
		_add_animation_track(Animation.TYPE_TRANSFORM, "Skeleton:" + bone.name)
#		var difference = bone.start - bone.local_transform.origin
#		var fallback_translation = bone.start - difference
		for i in range(transform_keys.size()):
			var key = transform_keys[i]
			key.rotation = key.rotation.normalized()
			_current_animation.transform_track_insert_key(_current_track_id, key.frame_num, key.translation, key.rotation, Vector3(1,1,1))
		
		pass
		
	func get_rotated_translation(bone_default_radians:Vector3, translation:Vector3, radians:Vector3)->Vector3:
		var obj:Spatial = Spatial.new()
		obj.translate(-translation)
		obj.rotate_x(radians.x - bone_default_radians.x)
		obj.rotate_y(radians.y - bone_default_radians.y)
		obj.rotate_z(radians.z - bone_default_radians.z)
		obj.translate(translation)
		return obj.transform.origin
		
	func _get_translate_keys(translate_nodes)->Object:
		var translate_keys = _translate_keys_resource.TranslateKeys.new()
		for a in range(translate_nodes.size()):
			var channel = translate_nodes[a]
			if channel.children.size() == 0: continue
			
			var arr_toAdd_too :Array
			match channel.get_property_value("MatchName"):
				"X":
					arr_toAdd_too = translate_keys.x_keys
				"Y":
					arr_toAdd_too = translate_keys.y_keys
				"Z":
					arr_toAdd_too = translate_keys.z_keys
			
			#<SPLINE>
			#The time and value
			var data:Array = (channel.children[0].data as String).split("\n")
			for i in range(data.size()):
				var sections:Array = (data[i] as String).strip_edges().split(" ")
				var key = _key_resource.Key.new(_get_frame_number(sections[1]), float(sections[2]) * 0.01)
				arr_toAdd_too.append(key)
				
		return translate_keys
		pass
		
	func _get_rotate_keys(rotate_nodes)->Object:
		var rotate_keys = _rotate_keys_resource.RotateKeys.new()
		for a in range(rotate_nodes.size()):
			var channel = rotate_nodes[a]
			if channel.children.size() == 0: continue
			
			var arr_toAdd_too :Array
			match channel.get_property_value("MatchName"):
				"X":
					arr_toAdd_too = rotate_keys.x_keys
				"Y":
					arr_toAdd_too = rotate_keys.y_keys
				"Z":
					arr_toAdd_too = rotate_keys.z_keys
				"W":
					arr_toAdd_too = rotate_keys.w_keys
			
			#<SPLINE>
			#The time and value
			var data:Array = (channel.children[0].data as String).split("\n")
			for i in range(data.size()):
				var sections:Array = (data[i] as String).strip_edges().split(" ")
#				var unknown:String = sections[0]
				var key = _key_resource.Key.new(_get_frame_number(sections[1]), float(sections[2]))
				arr_toAdd_too.append(key)
				
		return rotate_keys
		pass
		
	func _get_frame_number(time:String)->float:
		var splited = time.split(":")
#		var e:float
		if splited.size() == 1:
#			e = float(splited[0]) * _frame_spacing
			return float(splited[0]) * _frame_spacing
		elif splited.size() == 2:
#			e = ((float(splited[0]) * _action_frames_per_sec) * _frame_spacing) + (int(splited[1]) * _frame_spacing)
			return ((float(splited[0]) * _action_frames_per_sec) * _frame_spacing) + (int(splited[1]) * _frame_spacing)
		else:
			return ((float(splited[0]) * _action_frames_per_sec * _action_frames_per_sec) * _frame_spacing) + ((float(splited[1]) * _action_frames_per_sec) * _frame_spacing) + (int(splited[2]) * _frame_spacing)
		pass
