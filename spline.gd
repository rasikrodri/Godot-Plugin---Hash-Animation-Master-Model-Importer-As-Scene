class Spline:
	var id:int
	var cps : Array = []
	var _curr_index:int = -1
	
	#Splines define the cps right inside
	func _init(spline_id:int,spline_node, model_cps : Dictionary, cps_resource : Resource)->void:
		self.id = spline_id
		var spline_data:String = spline_node.data
#		print(spline_data.strip_edges())
		var cps_data = spline_data.strip_edges().split("\n")
		for i in range(cps_data.size()):
			var cp = cps_resource.CP.new(cps_data[i], model_cps, self)
			model_cps[cp.cp_num] = cp
			cps.append(cp)
		
		pass
		
	func get_hooks_sections()->Array:
		var arr:Array =[]
		var curr_cp = next_cp()
		var curr_section:Array = []
		while (not curr_cp == null):
			while (curr_cp.is_hook):
				curr_section.append(curr_cp)
			if curr_section.size() > 0:
				arr.append(curr_section)
				curr_section = []
		return arr
		pass
		
	func set_current_cp(cp)->void:
		_curr_index = cps.find(cp, 0)
	func next_cp()->Object:
		_curr_index += 1
		if _curr_index >= cps.size(): 
			_curr_index -= 1#return i to it's last position
			return null
		return cps[_curr_index]
	func prev_cp()->Object:
		_curr_index -= 1
		if _curr_index < 0: 
			_curr_index += 1#return i to it's last position
			return null
		return cps[_curr_index]
