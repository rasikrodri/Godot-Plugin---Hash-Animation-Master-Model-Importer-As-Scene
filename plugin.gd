tool
extends EditorPlugin

var import_plugin
var control

func _enter_tree():
	#Add import plugin
	import_plugin = ImportPlugin.new()
	add_import_plugin(import_plugin)

func _exit_tree():
	#remove plugin
	remove_import_plugin(import_plugin)
	import_plugin = null

##############################################
#                Import Plugin               #
##############################################
class ImportPlugin extends EditorImportPlugin:
	var _optioans_resource : Resource = preload("res://addons/AMModelImporterAsScene/options.gd")
	var _scene_generator_resource : Resource = preload("res://addons/AMModelImporterAsScene/scene/scene_generator.gd")
	
	enum Presets { LOWEST_DETIAL, MEDIUM_DETAIL, HIGH_DETAIL  }
	enum NormalsMethod { LOAD_FROM_MODEL, FLAT, SMOOTH}
	
	func get_preset_count():
		return Presets.size()

	func get_preset_name(preset):
		match preset:
			Presets.LOWEST_DETIAL:
				return "Lowest Detail"
			Presets.MEDIUM_DETAIL:
				return "Medium Detail"
			Presets.HIGH_DETAIL:
				return "Hihg Detail"
			_:
				return "Unknown"
	
	func get_import_options(preset):
		var polys_per_patch : int = 1
		match preset:
			Presets.LOWEST_DETIAL:
				polys_per_patch = 1
			Presets.MEDIUM_DETAIL:
				polys_per_patch = 4
			Presets.HIGH_DETAIL:
				polys_per_patch = 8
				
		#https://docs.godotengine.org/en/3.1/tutorials/plugins/editor/import_plugins.html
		var options = _optioans_resource.Options.new()
		options.polygons_per_patch = polys_per_patch
		var settings = options.get_options_as_array()
#		print(settings)
		return settings
		pass
	
	#The Name shown in the Plugin Menu
	func get_importer_name():
		return 'AmModel-Importer As Scene'
	
	#The Name shown under 'Import As' in the Import menu
	func get_visible_name():
		return "AmModel as Scene"
	
	#The File extensions that this Plugin can import. Those will then show up in the Filesystem
	func get_recognized_extensions():
		return ['mdl']
	
	func get_resource_type():
		return "PackedScene"
	
	#The extenison the imported file will have
	func get_save_extension():
		return 'scn'
		
	func get_option_visibility(option: String, options: Dictionary)->bool:
		return true
		pass
		
	func get_priority()->float:
		return 1.0
		pass
		
	#Gets called when pressing a file gets imported / reimported
	func import( source_path, save_path, options, platforms, gen_files ):
		print("start")
#		print(0)
		var xml_document = XMLParser.new()
		var error = xml_document.open(source_path)
		if error != OK:
			return error
		
		var scene:PackedScene = _scene_generator_resource.SceneGenerator.new(source_path, options).generate_packed_scene()
		
		var full_path = "%s.%s" % [save_path, get_save_extension()]
		print("saving too [" + full_path + "]")
		return ResourceSaver.save( full_path, scene )
		pass
