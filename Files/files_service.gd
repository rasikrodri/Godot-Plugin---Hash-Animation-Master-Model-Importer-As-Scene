class FilesService:
	
	var _file_paths:Array
	
	func _init()->void:
		pass
		
	func get_filelist(scan_dir : String) -> Array:
		var my_files : Array = []
		var dir := Directory.new()
		if dir.open(scan_dir) != OK:
			printerr("Warning: could not open directory: ", scan_dir)
			return []
		
		if dir.list_dir_begin(true, true) != OK:
			printerr("Warning: could not list contents of: ", scan_dir)
			return []
		
		var file_name := dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				my_files += get_filelist(dir.get_current_dir() + "/" + file_name)
			else:
				my_files.append(dir.get_current_dir() + "/" + file_name)
		
			file_name = dir.get_next()
		
		return my_files
		pass
		
