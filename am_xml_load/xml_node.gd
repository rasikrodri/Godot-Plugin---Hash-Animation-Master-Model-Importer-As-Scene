class XmlNode:
	var name:String
	var data:String
	var _data_dic:Dictionary
	var parent:XmlNode
	var children:Array
	
	func _init():
		pass
		
	#It queries all, children and sub children
	#Provide an array of strings for node names
	#Provide an array of properties
	func query(names:Array, containsProperties:Array = []):
		var query_result = XmlQueryResult.new()
		var nodes_list :Array=[]
		_add_matching_nodes(names, containsProperties, self.children, nodes_list)
		query_result.nodes = nodes_list
		return query_result
		pass
		
	func _add_matching_nodes(names:Array, containsProperties:Array, child_nodes:Array, nodes_list:Array)->void:
		for i in range(child_nodes.size()):
			var child = child_nodes[i]
			if child.name in names:
				if not containsProperties.empty():
					if _contains(containsProperties, child.data):
						nodes_list.append(child)
					else:
						child._add_matching_nodes(names, containsProperties, child.children, nodes_list)
				else:
					nodes_list.append(child)
			else:
				child._add_matching_nodes(names, containsProperties, child.children, nodes_list)
		pass
		
	func _contains(containsProperties:Array, data:String)->bool:
		for i in range(containsProperties.size()):
			if containsProperties[i] in data: return true
		return false
		pass
		
	#It queries only the direct children
	func query_direct_children(names:Array, containsProperties:Array = []):
		var query_result = XmlQueryResult.new()
		var nodes_list :Array=[]
		_add_direct_matching_nodes(names, containsProperties, children, nodes_list)
		query_result.nodes = nodes_list
		return query_result
		pass
		
	func _add_direct_matching_nodes(names:Array, containsProperties:Array, child_nodes:Array, nodes_list:Array)->void:
		for i in range(children.size()):
			var child = children[i]
			if child.name in names:
				if not containsProperties.empty():
					if _contains(containsProperties, child.data):
						nodes_list.append(child)
					else:
						child._add_matching_nodes(names, containsProperties, child.children, nodes_list)
				else:
					nodes_list.append(child)
		pass
		
	func get_property_value(property_name:String)->String:
		if _data_dic.size() == 0:
			var splited : Array = data.split("\n")
			for i in range(splited.size()):
				var prop : String = splited[i]
				var index:int = prop.find("=")
				if index > -1:
					_data_dic[prop.substr(0, index)] = prop.substr(index + 1).strip_edges()
		
		if _data_dic.has(property_name): return _data_dic[property_name]
		return ""
		pass
		
	class XmlQueryResult extends XmlNode:
		var nodes:Array=[]
		
		#It queries all, children and sub children
		func query(names:Array, containsProperties:Array = []):
			var query_result = XmlQueryResult.new()
			var nodes_list :Array=[]
			for i in range(nodes.size()):
				._add_matching_nodes(names, containsProperties, nodes[i].children, nodes_list)
				
			query_result.nodes = nodes_list
			return query_result
			pass
			
		#It queries only the direct children
		func query_direct_children(names:Array, containsProperties:Array = []):
			var query_result = XmlQueryResult.new()
			var nodes_list :Array=[]
			._add_direct_matching_nodes(names, containsProperties, nodes, nodes_list)
			query_result.nodes = nodes_list
			return query_result
			pass
