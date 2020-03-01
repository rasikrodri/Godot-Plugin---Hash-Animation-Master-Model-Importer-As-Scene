class Options:
	var polygons_per_patch:int = 1
	
	
	func _init():
		pass
		
	func get_options_as_array()->Array:
		var options_array = []
		options_array.append( { 
			"name":"plygons_per_patch", 
			"default_value":polygons_per_patch, 
			"property_hint":"The higher the more polygons per patch will be created.", 
			"hint_string":"(int)" 
		} )
		options_array.append( { 
			"name":"normals_method", 
			"default_value": "SMOOTH", 
			"property_hint":"Normals calculation method.", 
			"hint_string":"{ LOAD_FROM_MODEL, FLAT, SMOOTH}" 
		} )
		return options_array
		pass
	func get_options_as_dictionary()->Dictionary:
		var options = get_options_as_array()
		var dic:Dictionary = {}
		for i in range(options.size()):
			dic[options[i].name] = options[i].default_value
			
		return dic
		pass
