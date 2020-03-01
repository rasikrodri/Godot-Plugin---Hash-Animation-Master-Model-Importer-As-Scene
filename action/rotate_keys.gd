class RotateKeys:
	var _key_resource:Resource=preload("res://addons/AMModelImporterAsScene/action/key.gd")
	
	var x_keys:Array = []
	var y_keys:Array = []
	var z_keys:Array = []
	var w_keys:Array = []

	#Merges the provided keys on top of crrent keys.
	#It overrides existing keys where the frame_num is the same.
	func merge_override_keys(keys:RotateKeys, fallback_rotation:Quat)->void:
		var all_times:Dictionary={}
		var host_x_dic:Dictionary = _get_dictionary(x_keys)
		var host_y_dic:Dictionary = _get_dictionary(y_keys)
		var host_z_dic:Dictionary = _get_dictionary(z_keys)
		var host_w_dic:Dictionary = _get_dictionary(w_keys)
		
		var guest_x_dic:Dictionary = _get_dictionary(keys.x_keys)
		var guest_y_dic:Dictionary = _get_dictionary(keys.y_keys)
		var guest_z_dic:Dictionary = _get_dictionary(keys.z_keys)
		var guest_w_dic:Dictionary = _get_dictionary(keys.w_keys)
		
		_merge_to_dictionary(all_times, x_keys)
		_merge_to_dictionary(all_times, y_keys)
		_merge_to_dictionary(all_times, z_keys)
		_merge_to_dictionary(all_times, w_keys)
		
		_merge_to_dictionary(all_times, keys.x_keys)
		_merge_to_dictionary(all_times, keys.y_keys)
		_merge_to_dictionary(all_times, keys.z_keys)
		_merge_to_dictionary(all_times, keys.w_keys)
		
		var last_x = _key_resource.Key.new(0.0, fallback_rotation.x)
		var last_y = _key_resource.Key.new(0.0, fallback_rotation.y)
		var last_z = _key_resource.Key.new(0.0, fallback_rotation.z)
		var last_w = _key_resource.Key.new(0.0, fallback_rotation.w)
		
		var new_x_keys:Array=[]
		var new_y_keys:Array=[]
		var new_z_keys:Array=[]
		var new_w_keys:Array=[]
		
		var all_times_arr : Array = all_times.keys()
		all_times_arr.sort_custom(MyCustomSorter.new(), "_sort")
		for i in range(all_times_arr.size()):
			var frame_num : float = all_times_arr[i]
			
			if guest_x_dic.has(frame_num):
				var item = guest_x_dic[frame_num]
				new_x_keys.append(item)
				last_x = item
			elif host_x_dic.has(frame_num):
				var item = host_x_dic[frame_num]
				new_x_keys.append(item)
				last_x = item
			else:
				last_x = _key_resource.Key.new(frame_num, last_x.value)
				new_x_keys.append(last_x)
			
			if guest_y_dic.has(frame_num):
				var item = guest_y_dic[frame_num]
				new_y_keys.append(item)
				last_y = item
			elif host_y_dic.has(frame_num):
				var item = host_y_dic[frame_num]
				new_y_keys.append(item)
				last_y = item
			else:
				last_y = _key_resource.Key.new(frame_num, last_y.value)
				new_y_keys.append(last_y)
			
			if guest_z_dic.has(frame_num):
				var item = guest_z_dic[frame_num]
				new_z_keys.append(item)
				last_z = item
			elif host_z_dic.has(frame_num):
				var item = host_z_dic[frame_num]
				new_z_keys.append(item)
				last_z = item
			else:
				last_z = _key_resource.Key.new(frame_num, last_z.value)
				new_z_keys.append(last_z)
			
			if guest_w_dic.has(frame_num):
				var item = guest_w_dic[frame_num]
				new_w_keys.append(item)
				last_w = item
			elif host_w_dic.has(frame_num):
				var item = host_w_dic[frame_num]
				new_w_keys.append(item)
				last_w = item
			else:
				last_w = _key_resource.Key.new(frame_num, last_w.value)
				new_w_keys.append(last_w)
			
		x_keys = new_x_keys
		y_keys = new_y_keys
		z_keys = new_z_keys
		w_keys = new_w_keys
		pass
		
	#Gets full transforms that have a translation, rotation and size.
	func _compute_complete_keys(fallback_rotation:Quat)->void:
		var all_times:Dictionary={}
		var x_dic:Dictionary = _get_dictionary(x_keys)
		var y_dic:Dictionary = _get_dictionary(y_keys)
		var z_dic:Dictionary = _get_dictionary(z_keys)
		var w_dic:Dictionary = _get_dictionary(w_keys)
		
		_merge_to_dictionary(all_times, x_keys)
		_merge_to_dictionary(all_times, y_keys)
		_merge_to_dictionary(all_times, z_keys)
		_merge_to_dictionary(all_times, w_keys)
		
		var last_x = _key_resource.Key.new(0.0, fallback_rotation.x)
		var last_y = _key_resource.Key.new(0.0, fallback_rotation.y)
		var last_z = _key_resource.Key.new(0.0, fallback_rotation.z)
		var last_w = _key_resource.Key.new(0.0, fallback_rotation.w)
		
		var new_x_keys:Array=[]
		var new_y_keys:Array=[]
		var new_z_keys:Array=[]
		var new_w_keys:Array=[]
		
		var all_times_arr : Array = all_times.keys()
		all_times_arr.sort_custom(MyCustomSorter.new(), "_sort")
		for i in range(all_times_arr.size()):
			var frame_num : float = all_times_arr[i]
			
			if x_dic.has(frame_num):
				var item = x_dic[frame_num]
				new_x_keys.append(item)
				last_x = item
			else:
				last_x = _key_resource.Key.new(frame_num, last_x.value)
				new_x_keys.append(last_x)
				
			if y_dic.has(frame_num):
				var item = y_dic[frame_num]
				new_y_keys.append(item)
				last_y = item
			else:
				last_y = _key_resource.Key.new(frame_num, last_y.value)
				new_y_keys.append(last_y)
				
			if z_dic.has(frame_num):
				var item = z_dic[frame_num]
				new_z_keys.append(item)
				last_z = item
			else:
				last_z = _key_resource.Key.new(frame_num, last_z.value)
				new_z_keys.append(last_z)
				
			if w_dic.has(frame_num):
				var item = w_dic[frame_num]
				new_w_keys.append(item)
				last_w = item
			else:
				last_w = _key_resource.Key.new(frame_num, last_w.value)
				new_w_keys.append(last_w)
			
			
		x_keys = new_x_keys
		y_keys = new_y_keys
		z_keys = new_z_keys
		w_keys = new_w_keys
		pass
		
	func _merge_to_dictionary(dict:Dictionary, arr:Array)->void:
		for i in range(arr.size()):
			dict[arr[i].frame_num] = null
		pass
		
	func _get_dictionary(arr:Array)->Dictionary:
		var dic:Dictionary = {}
		for i in range(arr.size()):
			var key = arr[i]
			dic[key.frame_num] = key
			
		return dic
		pass
		
	class MyCustomSorter:
		func _sort(a:float, b:float)->bool:
			if a < b:
				return true
			return false
