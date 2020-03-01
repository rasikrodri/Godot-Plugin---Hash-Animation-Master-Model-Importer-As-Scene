class PolyVertex:
	var pos : Vector3
	var normal : Vector3
	var uv : Vector2
	
	func _init(vert_pos : Vector3, vert_normal : Vector3)->void:
		pos = vert_pos
		normal = vert_normal
		pass
		
	#func init_with_pos_and_normal(_pos, _normal)->Vertex:
	#	pos = _pos
	#	normal = _normal
	#	return self
	#	pass
		
	#func init_with_multiple_pos_and_normal(pos:Array, normal:Array)->Vertex:
	#	var vec = Vector.new()
	#	vec1.init_with_coords(pos)
	#	self.pos = vec1
	#
	#	vec = Vector.new()
	#	vec.init_with_coords(normal)
	#	self.normal = vec
	#	return self
	#	pass
		
	#func clone()->Vertex:
	#	var v = Vertex.new()
	#	v.init_with_pos_and_normal(pos.clone(), normal.clone())
	#	return v
	#	pass
		
	#func flip()->void:
	#	normal = normal.inverse()#.negated()
	#	pass
	#
	#func interpolate(other : Vertex, t : float)->Vertex:
	#	var v = Vertex.new()
	#	v.pos = lerp(v.pos, other.pos, t) # pos.lerp(other.pos, t)
	#	v.normal = lerp(v.normal, other.normal, t) #normal.lerp(other.normal, t)
	#	return v
	#	pass
		
