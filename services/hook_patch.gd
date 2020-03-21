class HookPatch:
	
	var PatchIndexInHooksSection:int
	var OrderedCps:Array
	var OrderedNormIndexes:Array
	var OrderedUvs1:Array
	var OrderedUvs2:Array
	
	#THis is assigned when we are creating the hook polygons
	#and it is also accessed when we are creating the hook polygons
	var PreviewsHookPatch:HookPatch
	
	var _HasTwoHooks:bool
	
	func _init(patch)->void:
		_HasTwoHooks = patch.hook_cps.size() > 1
		_set_hook_distance_as_guest(patch)
		_set_data(patch)
		pass
		
	func GetFirstHookPatch()->HookPatch:
		var lastPatch:HookPatch = self
		var temp:HookPatch = PreviewsHookPatch
		while(temp != null):
			lastPatch = temp
			temp = temp.PreviewsHookPatch
		
		return lastPatch
		pass
		
	func _set_hook_distance_as_guest(patch)->void:
		var a :int = patch.hook_cps[0].get_hook_distance_as_guest()
		if patch.hook_cps.size() == 1:
			PatchIndexInHooksSection = a
		else:
			var b:int = patch.hook_cps[1].get_hook_distance_as_guest()
			PatchIndexInHooksSection = b if b > a else a
		pass
		
	func IsPatchOnLeft()->bool:
		if not _HasTwoHooks:
			var firstCpMainHostNum = OrderedCps[0].get_main_cp_host_num()
			var hookCpMainHostNum = OrderedCps[3].get_main_cp_host_num()
			if firstCpMainHostNum == hookCpMainHostNum:
				return true
			elif hookCpMainHostNum == OrderedCps[2].get_main_cp_host_num():
				return true
			
		return false
		pass
		
	func IsPatchOnRight()->bool:
		if not IsPstchInMiddle() and not IsPatchOnLeft():  
			return true
		else:
			return false
		pass
		
	func IsPstchInMiddle()->bool:
		return _HasTwoHooks
		pass
		
	func _set_data(patch)->void:
		var hookIndex = _get_hook_index(patch)
		OrderedCps = _GetCpsOrderedHookAtIndex3(patch.cps, hookIndex)
		OrderedNormIndexes = _GetCpsOrderedHookAtIndex3(patch.normals_indexes, hookIndex)
		
		if patch.patch_uvs_1 != null:
			OrderedUvs1 = _GetCpsOrderedHookAtIndex3(patch.patch_uvs_1.uvs, hookIndex)
		
		if patch.patch_uvs_2 != null:
			OrderedUvs2 = _GetCpsOrderedHookAtIndex3(patch.patch_uvs_2.uvs, hookIndex)
		pass
		
	func _get_hook_index(patch)->int:
		if patch.hook_cps[0].get_hook_distance_as_guest() == PatchIndexInHooksSection: 
			return patch.cps.find(patch.hook_cps[0])
		else:
			return patch.cps.find(patch.hook_cps[1])
		pass
		
	func _GetCpsOrderedHookAtIndex3(items:Array, hook_index)->Array:
#		if items[0].cp_num == 112830:
#			var dd = 0
		
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
