class PatchIdGenerator:
	func _init():
		pass
		
	func generate_id(cps_nums:Array)->String:
		#Do not add the 5th cp becasue the uvs do not have the 5th cp in them
		#And with the first 4 cps it should be enouth to id the patch uniquely
		return "-" + str(cps_nums[0]) + "-" + str(cps_nums[1]) + "-" + str(cps_nums[2]) + "-" + str(cps_nums[3])
		pass
