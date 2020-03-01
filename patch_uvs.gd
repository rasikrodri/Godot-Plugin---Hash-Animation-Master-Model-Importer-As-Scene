class PatchUvs:
	var _uv_resource :Resource = preload("res://addons/AMModelImporterAsScene/uv.gd")
	var patch_id_generator_resource : Resource = preload("res://addons/AMModelImporterAsScene/patch_id_generator.gd")
	var id_generator
	var decal_patch_id : String
	var uvs : Array = []
	
	func _init():
		id_generator = patch_id_generator_resource.PatchIdGenerator.new()
		pass
		
	func add_uv(cp, uv:Vector2)->void:
		uvs.append(_uv_resource.UV.new(cp, uv))
		pass
		
	func generate_patch_id()->String:
		return id_generator.generate_id([
			uvs[0].cp.get_main_cp_host_num(), 
			uvs[1].cp.get_main_cp_host_num(),
			uvs[2].cp.get_main_cp_host_num(), 
			uvs[3].cp.get_main_cp_host_num()
		])
		pass
