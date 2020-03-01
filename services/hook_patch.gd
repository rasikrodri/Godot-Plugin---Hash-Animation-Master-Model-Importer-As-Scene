class HookPatch:
	
	var PatchIndexInHooksSection:int
	var OrderedCps:Array
	var OrderedNormIndexes:Array
	var OrderedUvs1:Array
	var OrderedUvs2:Array
	
	var HasTwoHooks:bool
	
	func _init(patch)->void:
		HasTwoHooks = patch.hook_cps.size() > 1
		_set_hook_distance_as_guest(patch)
		_set_data(patch)
		pass
		
	func _set_hook_distance_as_guest(patch)->void:
		var a :int = patch.hook_cps[0].get_hook_distance_as_guest()
		if patch.hook_cps.size() == 1:
			PatchIndexInHooksSection = a
		else:
			var b:int = patch.hook_cps[1].get_hook_distance_as_guest()
			PatchIndexInHooksSection = b if b > a else a
		pass
		
	func _set_data(patch)->void:
		var hookIndex = _get_hook_index(patch)
		OrderedCps = _get_cps_ordered_hook_at_zero(patch.cps, hookIndex)
		OrderedNormIndexes = _get_cps_ordered_hook_at_zero(patch.normals_indexes, hookIndex)
		
		if patch.patch_uvs_1 != null:
			OrderedUvs1 = _get_cps_ordered_hook_at_zero(patch.patch_uvs_1.uvs, hookIndex)
		
		if patch.patch_uvs_2 != null:
			OrderedUvs2 = _get_cps_ordered_hook_at_zero(patch.patch_uvs_2.uvs, hookIndex)
		pass
		
	func _get_hook_index(patch)->int:
		if patch.hook_cps[0].get_hook_distance_as_guest() == PatchIndexInHooksSection: 
			return patch.cps.find(patch.hook_cps[0])
		else:
			return patch.cps.find(patch.hook_cps[1])
		pass
		
	func _get_cps_ordered_hook_at_zero(items:Array, hook_index)->Array:
		if items == null: return []
		if items.size() == 0: return items
		
		#Flip them to have them in the polygon build order already
		#Scroll items so that data from the hook cp is at index 0
		var arr:Array
		match (hook_index):
			1:
				arr = [items[0], items[3], items[2], items[1]]
			2:
				arr = [items[1], items[0], items[3], items[2]]
			3:
				arr = [items[2], items[1], items[0], items[3]]
			_:#0
				items.invert()
				arr = items
		return arr
		pass
