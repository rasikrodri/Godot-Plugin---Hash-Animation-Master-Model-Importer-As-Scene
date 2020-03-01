class XmlLoader:
	var _xml_node_resource = preload("res://addons/AMModelImporterAsScene/am_xml_load/xml_node.gd")
	
	var _xml_document:XMLParser
	var main_node
	
	var errors : Array = []
	
	func _init(source_path:String):
		var xml_document = XMLParser.new()
		xml_document.open(source_path)
		self._xml_document = xml_document
		pass
		
	func get_node_tree():
		if main_node == null: 
			_xml_document.read()
			main_node = _load_node()
		return main_node
		pass
		
		
#	func _get_curr_node_tag_name()->String:
#		if _xml_document.get_node_type() == XMLParser.NODE_ELEMENT or _xml_document.get_node_type() == XMLParser.NODE_ELEMENT_END: 
#			return _xml_document.get_node_name()
#		else:
#			return ""
			
	func _get_node_name()->String:
		return _xml_document.get_node_name()
		
	func _get_node_data()->String:
		return _xml_document.get_node_data().strip_edges()
			
	func _is_node_start()->bool:
		if _xml_document.get_node_type() == XMLParser.NODE_ELEMENT:
			return true
		else:
			return false
			
	func _is_node_end()->bool:
		if _xml_document.get_node_type() == XMLParser.NODE_ELEMENT_END:
			return true
		else:
			return false
			
	func _is_node_data()->bool:
		if not (_xml_document.get_node_type() == XMLParser.NODE_ELEMENT or _xml_document.get_node_type() == XMLParser.NODE_ELEMENT_END): 
			return true
		else:
			return false
			
		
		
	func _load_node()->Object:
		var node = _xml_node_resource.XmlNode.new()
		node.name = _get_node_name()

		_xml_document.read()
		if _is_node_end(): 
			#skip the closing tag of the last child </NODENAME> in order to grab data after
			_xml_document.seek(_xml_document.get_node_offset() + node.name.length() + 5)
			return node
		
		var node_data : String
		if _is_node_data(): 
			node.data = _get_node_data()
			_xml_document.read()
			
		while not (_is_node_end() and node.name == _get_node_name()):
			var child = _load_node()
			child.parent = node
			node.children.append(child)
				
			#Make sure to also get the data after the closing tag of the last node
			if _is_node_data():
				var temp:String = _xml_document.get_node_data().strip_edges()
				if not temp.empty():
					node.data = node.data + " \n" + temp.strip_edges()
				_xml_document.read()
		
		#skip the closing tag of the last child </NODENAME> in order to grab data after
		_xml_document.seek(_xml_document.get_node_offset() + node.name.length() + 5)
		return node
		pass
