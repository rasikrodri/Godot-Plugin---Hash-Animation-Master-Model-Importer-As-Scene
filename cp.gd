class CP:
	var spline
	var cp_num : int
	var is_hook : bool
	var hook_pos_percent : float
	var _hosts_position : bool = true
	var host_cp_num : int = -1 #The cp number of the cp this cp is attached too for getting the position
	
	
	#Only used in the main host cp
	#All the client cps should save and get this data from the main host cp
	var _bones_data_dic:Dictionary = {}
	var _bones_data:Array = []
	
	#The cp this cp is attached too for getting the position
	#Assigned in a separate funciton becasue we have to load all the cps first
	var host_cp : CP 
	
	#The cp that is attached to this cp, and depends on this cp to get the position
	#Assigned in a separate funciton becasue we have to load all the cps first
	var client_cp : CP #
	
	#The cps that holds the position
	#Assigned and returned whenever get_main_cp_host_num() is called
	#Simulating Lazy loading
	var _main_cp_host: CP
	var _main_cp_host_num: int
	
	var _pos : Vector3
	var patches : Array = []
	
	#settings for after cp in the direction of the spline
	var _out_alpha : float = 0
	var _out_gamma : float = 0
	var _out_magnitude : float = 1.0
	
	#settings for before cp in the direction of the spline
	var _in_alpha : float = 0
	var _in_gamma : float = 0
	var _in_magnitude : float = 1.0
	
	var _scaler : float = 0.01
	
	
	#CPs allways start with 3 to 4 numbers:
	#First number is allways 1
	#Second number is 1 or 0. 
		#0 means that the location is being defined in this line
		#1 means that the location x,y, and z are defined in the attached cp
	#Third number is the cp number
	#Fourth, only appears when Second is 1, is the attached cp number that has the location x, y, and z
	#Fifth, six, and seventh, if Second is 0, this are the x, y, and z, otherwise no location data
	#The rest are alpha, gama and magnitude
	func _init(cp_data, model_cps:Dictionary, spline):
		self.spline = spline
		
#		print(cp_data)
		var data = cp_data.split(" ")
		cp_num = int(data[2])
#		if cp_num == 60: print(cp_data)
		if data[1] == "1": 
			_hosts_position = false
			if data.size() == 5:
				is_hook = true
				hook_pos_percent = float(data[3])
				host_cp_num = int(data[4])
			else:
				host_cp_num = int(data[3])
				_init_alpha_gamma_magnitude(4, data)
		else:
			_pos = Vector3(float(data[3])*_scaler, float(data[4])*_scaler, float(data[5])*_scaler)
			_init_alpha_gamma_magnitude(6, data)
			
#		print("start")
#		print(data)
#		print(_pos)
#		print(_out_alpha)
#		print(_out_gamma)
#		print(_out_magnitude)
#		print(_in_alpha)
#		print(_in_gamma)
#		print(_in_magnitude)
#		print("end")
		pass
		
	func _init_alpha_gamma_magnitude(index, data:Array)->void:
		#out settings are allways first
#		if data.size() - 1 < index + 1: print(data) 
		if data[index] != ".":
			_out_alpha = float(data[index])
			index += 1
			_out_gamma = float(data[index])
			index += 1
			_out_magnitude = float(data[index])
			index+= 1
		
		if data[index] != ".":
			_in_alpha = float(data[index])
			index += 1
			
		if data.size() < index and data[index] != ".":
			_in_gamma = float(data[index])
			index += 1
			
		if data.size() < index and data[index] != ".":
			_in_magnitude = float(data[index])
			
		pass

	func get_position()->Vector3:
		if _hosts_position:
			return _pos
		else:
			return host_cp.get_position()
		pass
		
	#If the position is stored on this cp
	func is_position_independent()->bool:
		if _hosts_position: return true
		else: return false
		pass
		
	func get_main_cp_host_num()->int:
		if _main_cp_host != null: return _main_cp_host.cp_num
		_main_cp_host = get_main_cp_host()
		_main_cp_host_num = _main_cp_host.cp_num
		return _main_cp_host.cp_num
		pass
		
	func get_main_cp_host()->Object:
		if _main_cp_host != null: return _main_cp_host
		if _hosts_position:
			_main_cp_host = self
		else:
			_main_cp_host = host_cp.get_main_cp_host()
			
		return _main_cp_host
		pass
		
	#this will get the first host cp that is not a hook cp
	#example a hook is the client of a normal cp that in turn
	#is a client of another hook(from an unrealted spline)
	#that in turn is a client of the main host cp
	var FirstHostNoneHookCp:CP
	func GetFirstHostNoneHookCp()->CP:
		if FirstHostNoneHookCp != null: return FirstHostNoneHookCp
		if _hosts_position:
			FirstHostNoneHookCp = self
		elif not host_cp.is_hook:
			FirstHostNoneHookCp = host_cp
		else:
			FirstHostNoneHookCp = host_cp.get_main_cp_host()
			
		return FirstHostNoneHookCp
		pass
		
	#Used for hook cps to get how far the hook is from
	#the main host cp
	var _hook_order_num:int
	func get_hook_distance_as_guest()->int:
		if _hook_order_num == 0:
			if host_cp == get_main_cp_host():
				_hook_order_num = 1
			else:
				_hook_order_num = 1 + host_cp.get_hook_distance_as_guest()
			return _hook_order_num
		else:
			return _hook_order_num
		pass
		
	func add_bone_data(bw):
		var h = get_main_cp_host()
		if h._bones_data_dic.has(bw.bone.name):
			#If we already have an entry, only override it if it is not 1
			if bw.weight != 1:
				h._bones_data_dic[bw.bone.name] = bw.weight
		else:
			h._bones_data_dic[bw.bone.name] = bw
		pass
	func get_bones_data()->Array:
		return get_main_cp_host()._bones_data
		pass
	
	#This is to be called only after all the bones have been assigned to the cps
	func assign_missing_bone_weights()->void:
		_bones_data = _bones_data_dic.values()
		if _bones_data_dic.size() == 1: return
		
		#This is to keep track of how much weight hasnot been assigned
		#Becasue the mdl file never asigns a weight to one of the bones when
		#multiple bones affect a cp
		var remaining_weight:float=1
		
		#If more than one bone affects this cps
		var unspecified_weight_data
		var remaining:float = 1.0
		for i in range(_bones_data.size()):
			var bd = _bones_data[i]
			if bd.weight == 1:
				unspecified_weight_data = bd
			else:
				remaining = remaining - bd.weight
				
		if not unspecified_weight_data == null:
			unspecified_weight_data.weight = remaining
				
		pass
