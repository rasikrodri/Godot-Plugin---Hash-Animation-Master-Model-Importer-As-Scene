class Bone:
		
		var bone_weight_holder_res = preload("res://addons/AMModelImporterAsScene/bone_weight_holder.gd")
		
		###################################
		#Storage while creating bones in the skeleton and assigning the parent bone
		var bone_id_in_skeleton:int
		###################################
	
		var name:String
		var attached_to_parent:bool
		var start:Vector3
		var end:Vector3
		var rotation:Quat
		var scale:Vector3
		var length:float
		
		var children:Array = []
		var parent:Bone
		
		var _scaler : float = 0.01
		
		var bone_node
		var model_cps:Dictionary
		
		func _init(parent_bode, bone_node, _model_cps):
			self.bone_node = bone_node
			self.model_cps = _model_cps
			
			if parent_bode != null: 
				self.parent = parent_bode
				parent_bode.children.append(self)
			
			name = bone_node.get_property_value("Name")
			
			var rot = bone_node.get_property_value("Rotate").split(" ")
			rotation = Quat(rot[0],rot[1],rot[2],rot[3])
			
			length = float(bone_node.get_property_value("Length"))*.01
			scale = Vector3(1 * 0.01, 1 * 0.01, length)
			
			var start:String = bone_node.get_property_value("Start")
			if start.empty():
				self.attached_to_parent = true
#				if parent_bode != null: 
#					self.start = parent_bode.end
			else:
				var vals:Array = start.split(" ")
				self.start = Vector3(float(vals[0])*0.01, float(vals[1])*0.01, float(vals[2])*0.01)
			
			var end_values:String = bone_node.get_property_value("End")
			if not end_values.empty():
				var vals:Array = end_values.split(" ")
				end = Vector3(float(vals[0])*0.01, float(vals[1])*0.01, float(vals[2])*0.01)
			
			set_cps_and_weights(bone_node, model_cps)
			pass
			
		func set_cps_and_weights(bone_node, model_cps:Dictionary)->void:
			var cp_and_weight:Dictionary = {}
			var cps_result = bone_node.query_direct_children(["NONSKINNEDCPS"])
			if cps_result.nodes.size() > 0:
				var data:String = cps_result.nodes[0].data
				var splited = data.split("\n") 
				for i in range(splited.size()):
					var cp_num:int=int(splited[i])
					cp_and_weight[cp_num] = bone_weight_holder_res.BoneWeightHolder.new(self, cp_num, 1.0)
				
			var weights_result = bone_node.query_direct_children(["WEIGHTEDCPS"])
			if weights_result.nodes.size() > 0:
				var data:String = weights_result.nodes[0].data
				var splited = data.split("\n") 
				for i in range(splited.size()):
					var cp_num_weig:Array = splited[i].split(" ")
					var cp_num = int(cp_num_weig[0])
					cp_and_weight[cp_num] = bone_weight_holder_res.BoneWeightHolder.new(self, cp_num, float(cp_num_weig[1]))

			if cp_and_weight.size() > 0:
				_set_cps(cp_and_weight, model_cps)
			pass
			
		func _set_cps(bone_and_weights:Dictionary, model_cps:Dictionary):
			var bs_ws : Array = bone_and_weights.values()
			for i in range(bs_ws.size()):
				var b_w = bs_ws[i]
				
#				if b_w.cp_num == 3121 or b_w.cp_num == 3104:
#					var ddd = 0
				
				var cp = model_cps[b_w.cp_num]
				
				#Ignore the hooks, there is no really a need to add their bone
				#Since the bone owner is the hooks main host cp bone owner.
				#Also, in some old models, the hooks bone is wrong
				if not cp.is_hook : cp.add_bone_data(b_w)
			pass
			
		
