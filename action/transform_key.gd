class TransformKey:
	var translation_was_set:bool setget _set_to_avoid_setting_from_outside
	var translation:Vector3 setget _set_translation
	func _set_translation(value:Vector3)->void:
		translation = value
		translation_was_set = true
		pass

	var rotation_was_set:bool setget _set_to_avoid_setting_from_outside
	var rotation:Quat setget _set_rotation
	func _set_rotation(value:Quat)->void:
		rotation = value
		rotation_was_set = true
		pass
#
	var scale_was_set:bool setget _set_to_avoid_setting_from_outside
	var scale:Vector3 setget _set_scale
	func _set_scale(value:Vector3)->void:
		scale = value
		scale_was_set = true
		pass
		
	func _set_to_avoid_setting_from_outside(value:bool)->void:
		pass
	
	var frame_num:float
		
	func _init(frame_num:float)->void:
		self.frame_num = frame_num
		pass
