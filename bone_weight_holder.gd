class BoneWeightHolder:
	var bone
	var cp_num:int
	var weight:float
	func _init(bone, cp_num:int, weight:float)->void:
		self.bone = bone
		self.cp_num = cp_num
		self.weight = weight
		pass
