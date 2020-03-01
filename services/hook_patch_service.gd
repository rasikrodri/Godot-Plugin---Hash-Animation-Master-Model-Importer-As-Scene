class HookPathService:
	
	var hook_patch_resource:Resource = preload("res://addons/AMModelImporterAsScene/services/hook_patch.gd")
	
	func _init()->void:
		pass
		
	func get_hook_patches(hook_patches_section:Array)->Array:
		var hook_patches = _create_hook_patches(hook_patches_section)
		hook_patches.sort_custom(self, "by_hook_patch_index")
		_normalize_left_to_right(hook_patches)
			
		return hook_patches
		pass
		
	func _create_hook_patches(hook_patches_section:Array)->Array:
		var hook_patches:Array = []
		for i in range(hook_patches_section.size()):
			hook_patches.append(hook_patch_resource.HookPatch.new(hook_patches_section[i]))
		return hook_patches
		pass
		
	func by_hook_patch_index(a, b):
		if a.PatchIndexInHooksSection == b.PatchIndexInHooksSection:
			return a.HasTwoHooks# the one with one hook is the last patch on the right
		else:
			return a.PatchIndexInHooksSection < b.PatchIndexInHooksSection
			
	func _normalize_left_to_right(hook_patches:Array)->void:
		#If the first patch is the right patch bacause the perpendicular
		#spline runs from right to left then invert the order of the
		#patches allways assume the perpendicular spine runs from 
		#left to write when calculating the poligons for the poly mesh
		var firstPatch = hook_patches[0]
		if firstPatch.OrderedCps[0].get_main_cp_host_num() != firstPatch.OrderedCps[3].get_main_cp_host_num():
			hook_patches.invert()
		pass
		
	
		
	
