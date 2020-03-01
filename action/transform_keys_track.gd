class TranformKeysTrack:
	var transform_key_resource :Resource = preload("res://addons/AMModelImporterAsScene/action/transform_key.gd")
	
	var _rest_translation:Vector3
	var _rest_rotation:Quat
	var _rest_scale:Vector3
	
	var _track:Dictionary={}
	
	func _init(rest_translation:Vector3, rest_rotation:Quat, rest_scale:Vector3=Vector3(1,1,1)):
		_rest_translation = rest_translation
		_rest_rotation = rest_rotation
		_rest_scale = rest_scale
		pass
		
	func set_tranform_keys(translate_keys, rotate_keys, scale_keys)->void:
		for i in range(translate_keys.x_keys.size()):
			var frame_num:float = translate_keys.x_keys[i].frame_num
			var x:float = translate_keys.x_keys[i].value
			var y:float = translate_keys.y_keys[i].value
			var z:float = translate_keys.z_keys[i].value
			
			var tranform_key = transform_key_resource.TransformKey.new(frame_num)
			tranform_key.translation = Vector3(x, y, z)
			_track[frame_num] = tranform_key
			
		for i in range(rotate_keys.x_keys.size()):
			var frame_num:float = rotate_keys.x_keys[i].frame_num
			var x:float = rotate_keys.x_keys[i].value
			var y:float = rotate_keys.y_keys[i].value
			var z:float = rotate_keys.z_keys[i].value
			var w:float = rotate_keys.w_keys[i].value
			
			if _track.has(frame_num):
				_track[frame_num].rotation = Quat(x, y, z, w)
			else:
				var tranform_key = transform_key_resource.TransformKey.new(frame_num)
				tranform_key.rotation = Quat(x, y, z, w)
				_track[frame_num] = tranform_key
				
		#I have not implemented scaling of bones yet
		if scale_keys != null:
			for i in range(scale_keys.x_keys.size()):
				var frame_num:float = scale_keys.x_keys[i].frame_num
				var x:float = scale_keys.x_keys[i].value
				var y:float = scale_keys.y_keys[i].value
				var z:float = scale_keys.z_keys[i].value
				
				if _track.has(frame_num):
					_track[frame_num].scale = Vector3(x, y, z)
				else:
					var tranform_key = transform_key_resource.TransformKey.new(frame_num)
					tranform_key.scale = Vector3(x, y, z)
					_track[frame_num] = tranform_key
		pass

	func get_transforms()->Array:
		return _get_ensured_complete_transforms()
		
	#Gets full transforms that have a translation, rotation and size.
	func _get_ensured_complete_transforms()->Array:
		var last_trans:Vector3 = _rest_translation
		var last_rot:Quat = _rest_rotation
		var last_scale:Vector3 = _rest_scale
		
		var track_keys:Array = _track.values()
		track_keys.sort_custom(MyCustomSorter.new(), "_sort")
		for i in range(track_keys.size()):
			var key = track_keys[i]
			
			if key.translation_was_set:
				last_trans = key.translation
			else:
				key.translation = last_trans
				
			if key.rotation_was_set:
				last_rot = key.rotation
			else:
				key.rotation = last_rot
				
			if key.scale_was_set:
				last_scale = key.scale
			else:
				key.scale = last_scale
			
		return track_keys
		pass
		
	
		
	class MyCustomSorter:
		func _sort(a, b)->bool:
			if a.frame_num < b.frame_num:
				return true
			return false


