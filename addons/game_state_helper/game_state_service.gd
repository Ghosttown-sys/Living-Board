extends Node

signal state_load_completed()
signal new_game_state_initialized()

const  SECURITY_KEY = "ABCDEF"
var _game_state_default := {
	"meta_data": {
		"current_scene_path": "",
		"data_format_version": "1.0"
	},
	"global": {},
	"scene_data": {},
}

var _game_state := {
	"meta_data": {
		"current_scene_path": "",
		"data_format_version": "1.0"
	},
	"global": {},
	"scene_data": {},
}

#list of scene resources that have already been loaded
var _loaded_scene_resources := {}
# list of objects with data about instanced child scenes that have been freed
var _freed_instanced_scene_save_and_loads = []
# used when saved game is loaded - prevents current scene game state from being saved before changing scene
var _skip_next_scene_transition_save := false


func _ready():
	# monitor whenever a node is added in the tree - we can tell when a new scene is loaded this way
	if OK != get_tree().connect("node_added", Callable(self, "_on_scene_tree_node_added")):
		printerr("GameStateService: could not connect to scene tree node_added signal!")
	
	var current_scene = get_tree().current_scene
	if current_scene != null:
		_on_scene_tree_node_added(current_scene)
	
	var transition_mgr = get_tree().root.get_node_or_null("TransitionMgr")
	if transition_mgr == null:
		return
	transition_mgr.connect("scene_transitioning", on_scene_transitioning)


"""
Creates a json file with the raw game state dictionary data.  This is used for debugging.
"""
func dump_game_state() -> void:
	var file_name = "user://game_state_dump_%s.json" % _get_date_time_string()
	var json_string = JSON.stringify(_game_state, "\t")
	var f = FileAccess.open(file_name, FileAccess.WRITE)
	f.store_string(json_string)


"""
Returns JSON string of current game state.
"""
func get_game_state_string(refresh_state: bool = false) -> String:
	if refresh_state:
		#fake a scene transition to force game state to be updated
		on_scene_transitioning("")
	return JSON.stringify(_game_state, "\t")

"""
Gets a value from the global game state.
"""
func get_global_state_value(key: String):
	var global_state = _game_state["global"]
	if global_state.has(key):
		return global_state[key]
	return null


"""
Loads game state data from given file path.  If loading is successful,
calls given func ref for scene transition if given.
"""
func load_game_state(path: String, scene_transition_func: Callable) -> bool:
	if !FileAccess.file_exists(path):
		printerr("GameStateService: File does not exist: path %s" % path)
		return false
	

	var save_file_hash = _get_file_content_hash(path)
	var saved_hash = _get_save_file_hash(path)


	if save_file_hash != saved_hash:
		printerr("GameStateService: Save file is corrupt or has been modified: path %s" % path)
		return false

	var f = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECURITY_KEY)
	if f == null or !f.is_open():
		printerr("GameStateService: File does not exist: path %s" % path)
		return false

	_game_state = str_to_var(f.get_as_text())

	f.close()
	
	_data_format_version_migration()

	_skip_next_scene_transition_save = true

	#return path to scene that was current for save file
	# this lets caller handle the transition
	var scene_path = _game_state["meta_data"]["current_scene_path"]
	if scene_transition_func != null:
		scene_transition_func.call(scene_path)
		
	return true


"""
resets game state for a new game
"""
func new_game() -> void:
	_game_state = _game_state_default.duplicate(true)
	new_game_state_initialized.emit()


"""
Saves game state to the given file path.  Another file with an md5 hash
will be saved along with the file with the extention ".dat".  The hash will
be used during load() to detect if the save game file has been altered.
"""
func save_game_state(path: String) -> bool:
	#fake a scene transition to force game state to be updated
	on_scene_transitioning("")

	_game_state["game_data_version"] = "1.0"

	var f = FileAccess.open(path, FileAccess.WRITE)
	f = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SECURITY_KEY)
	if f == null or !f.is_open():
		printerr("Couldn't open file to save to : %s" % path)
		return false
	var data: String = var_to_str(_game_state)
	f.store_string(data)
	FileAccess.get_open_error()
	f.close()
	
#
	_save_save_file_hash(path)
	
	return true


"""
Sets a value from the global game state.
"""
func set_global_state_value(key: String, value) -> void:
	var global_state = _game_state["global"]
	global_state[key] = value


"""
Connected to scene tree's node_added signal.  If the node is a scene, load game state for it
"""
func _on_scene_tree_node_added(node : Node) -> void:
	if node != get_tree().current_scene:
		return
	_handle_scene_load(node)


"""
Determines an id for a scene node.  This id is used as a key to the game state dictionary.
"""
func _get_scene_id(node: Node) -> String:
	var id = node.get("id")
	if id == null:
		if node.scene_file_path != null:
			id = node.scene_file_path
		else:
			printerr("GameStateService: scene has no scene_file_path??  path: %s" % node.get_path())
			return ""
	
	return id


"""
Gets the scene data for a scene node.
"""
func _get_scene_data(id: String, node: Node) -> Dictionary:
	var scene_data: Dictionary = _game_state["scene_data"]
	
	if !scene_data.has(id):
		var temp = {
			"scene_file_path": node.scene_file_path,
			"node_data": {}
			}
		scene_data[id] = temp

	return scene_data[id]


"""
Re-applies game state to a newly loaded scene.
"""
func _handle_scene_load(node: Node) -> void:
	# array was populated when old scene unloaded - these are not legit freed instances
	_freed_instanced_scene_save_and_loads.clear()
	
	var scene_id: String = _get_scene_id(node)
	if scene_id.is_empty():
		return
	
	# store path to scene file for the now current scene
	_game_state["meta_data"]["current_scene_path"] = node.scene_file_path
	
	# wait for scene to be fully loaded
	await node.ready
	
	# connect to helper node freed signal - for handling instanced child scenes that are freed at runtime
	_connect_to_GameStateHelper_freed_signal()
	
	var scene_data = _get_scene_data(scene_id, node)
	var node_data = scene_data["node_data"]
	var global_state = _game_state["global"]

	# recreate dynamically instanced nodes
	_load_dynamic_instanced_nodes(node_data)

	# load data into each helper node
	for temp in get_tree().get_nodes_in_group(GameStateHelper.NODE_GROUP):
		var helper: GameStateHelper = temp
		if helper.debug:
			breakpoint
		if helper.global:
			helper.load_data(global_state)
		else:
			helper.load_data(node_data)
	
	# signal that load is complete - sometimes scenes need to do extra logic after state is loaded
	emit_signal("state_load_completed")


"""
Creates new instances of any dynamicly instanced node and loads their saved data.
"""
func _load_dynamic_instanced_nodes(data: Dictionary) -> void:
	for id in data.keys():
		if typeof(data[id]) != TYPE_DICTIONARY:
			continue
		var node_data: Dictionary = data[id]
		if !node_data.has(GameStateHelper.GAME_STATE_KEY_INSTANCE_SCENE):
			continue
		if !node_data.has(GameStateHelper.GAME_STATE_KEY_NODE_PATH):
			continue
		var parent = _get_parent(node_data[GameStateHelper.GAME_STATE_KEY_NODE_PATH])
		if parent == null:
			printerr("GameStateService: could not get parent for dynamic instanced node: %s" % node_data[GameStateHelper.GAME_STATE_KEY_NODE_PATH])
			continue
		_instance_scene(parent, node_data, id)


"""
Gets the parent given a child node path
"""
func _get_parent(child_node_path: String) -> Node:
	var parent_path = child_node_path.get_base_dir()
	var parent = get_tree().root.get_node_or_null(parent_path)
	return parent


"""
Loads or gets a scene resource
"""
func _get_scene_resource(resource_path: String) -> PackedScene:
	if _loaded_scene_resources.has(resource_path):
		return _loaded_scene_resources[resource_path]
	
	var resource = load(resource_path)
	if resource == null:
		printerr("GameStateService: Could not load scene resource: %s" % resource_path)
	_loaded_scene_resources[resource_path] = resource
	return resource


"""
Actually instances a scene, adds it to the node tree and calls it's GameStateHelper node to load data
"""
func _instance_scene(parent: Node, node_data: Dictionary, id: String) -> void:
	var resource := _get_scene_resource(node_data[GameStateHelper.GAME_STATE_KEY_INSTANCE_SCENE])
	if resource == null:
		printerr("GameStateService: Could not instance node:  resource not found.   Save file id: %s, scene path: %s" % [id, node_data[GameStateHelper.GAME_STATE_KEY_INSTANCE_SCENE]])
		return
	var instance = resource.instantiate()
	var path := NodePath(id)
	var node_name = path.get_name(path.get_name_count() - 1)
	instance.name = node_name
	parent.add_child(instance)


"""
Connects to all GameStateHelper nodes freed signal.  This is to track when an 
instanced child scene is freed at runtime.
"""
func _connect_to_GameStateHelper_freed_signal():
	for save_and_load in get_tree().get_nodes_in_group(GameStateHelper.NODE_GROUP):
		if !save_and_load.is_connected("instanced_child_scene_freed", Callable(self, "_on_instanced_child_scene_freed")):
			save_and_load.connect("instanced_child_scene_freed", Callable(self, "_on_instanced_child_scene_freed"))


"""
Handler func for the GameStateHelper's instanced_child_scene_freed signal.
The object passed in the signal is saved off to be processed when game state is saved.
"""
func _on_instanced_child_scene_freed(save_freed_instanced_child_scene_object) -> void:
	_freed_instanced_scene_save_and_loads.append(save_freed_instanced_child_scene_object)


"""
Processes data about freed child instance scenes - saving the fact that they were freed
at runtime into the game state.
"""
func _save_freed_save_and_load(data: Dictionary) -> void:
	for save_and_load in _freed_instanced_scene_save_and_loads:
		save_and_load.save_data(data)
	_freed_instanced_scene_save_and_loads.clear()


"""
Handler for when a new scene is about to be transitioned to.  Game state for
the current scene is saved into the game state.
"""
func on_scene_transitioning(_new_scene_path) -> void:
	# skip the transition when loading a saved game
	if _skip_next_scene_transition_save:
		_skip_next_scene_transition_save = false
		return

	var current_scene: Node =  get_tree().current_scene

	var scene_id: String = _get_scene_id(current_scene)
	if scene_id.is_empty():
		return

	var scene_data = _get_scene_data(scene_id, current_scene)
	var node_data := {}
	scene_data["node_data"] = node_data
	var global_state = _game_state["global"]
	
	# save state
	for n in get_tree().get_nodes_in_group(GameStateHelper.NODE_GROUP):
		if n.debug:
			breakpoint
		if n.global:
			n.save_data(global_state)
		else:
			n.save_data(node_data)
	
	# save data about freed instanced child scenes
	_save_freed_save_and_load(node_data)


"""
Get a string based on current date/time - used for generating file names.
"""
func _get_date_time_string():
	# year, month, day, weekday, dst (daylight savings time), hour, minute, second.
	var datetime = Time.get_datetime_dict_from_system()
	return "%d%02d%02d_%02d%02d%02d" % [datetime["year"], datetime["month"], datetime["day"], datetime["hour"], datetime["minute"], datetime["second"]]


"""
Gets the md5 hash of the contents of a file.
"""
func _get_file_content_hash(file_path: String) -> String:
	var f = FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ, SECURITY_KEY)
	if f == null or !f.is_open():
		return ""
	var content = f.get_as_text()
	f.close()
	return content.md5_text()


"""
Gets md5 hash of a save file that was saved along side (in another file)
"""
func _get_save_file_hash(file_path: String) -> String:
	file_path = file_path.replace("." + file_path.get_extension(), ".dat")
	var f = FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ, SECURITY_KEY)
	if f == null or !f.is_open():
		return ""
	var content = f.get_as_text()
	f.close()
	return content


"""
Create a new text file along side a save file.  This text file contains the
md5 hash of the save file contents.  This hash is used to detect if the save file
contents have been altered.
"""
func _save_save_file_hash(file_path: String) -> void:
	var content_hash = _get_file_content_hash(file_path)
	file_path = file_path.replace("." + file_path.get_extension(), ".dat")
	var f = FileAccess.open_encrypted_with_pass(file_path, FileAccess.WRITE , SECURITY_KEY)
	if f == null or !f.is_open():
		return
	f.store_string(content_hash)
	f.close()


func _data_format_version_migration() -> void:
	if !_game_state["meta_data"].has("data_format_version"):
		_data_format_version_mgration_pre_v1()


func _data_format_version_mgration_pre_v1() -> void:
	print("converting save game data from pre v1 to v1")
	_game_state["meta_data"]["data_format_version"] = "1.0"
	var scene_data:Dictionary = _game_state["scene_data"]
	for scene_data_key in scene_data.keys():
		var node_data:Dictionary = scene_data[scene_data_key]["node_data"]
		var node_data_keys_to_change := {}
		for node_data_key in node_data:
			if node_data_key.find("@") > -1:
				node_data_keys_to_change[node_data_key] = node_data_key.replace("@", "_")
			var node_data_dictionary:Dictionary = node_data[node_data_key]
			var props_to_convert_keys = [
				GameStateHelper.GAME_STATE_KEY_NODE_PATH,
				GameStateHelper.GAME_STATE_KEY_OWNER_NODE_PATH]
			for key in props_to_convert_keys:
				if node_data_dictionary.has(key):
					var value = node_data_dictionary[key]
					var original_value = str(value)
					var is_node_path = value is NodePath
					value = str(value).replace("@", "_")
					if original_value == value:
						continue
					print("updating node data for %s: '%s' -> '%s'" % [key, original_value, value])
					if is_node_path:
						value = NodePath(value)
					node_data_dictionary[key] = value
		for key in node_data_keys_to_change.keys():
			print("GameStateService: updating node data key : '%s' -> '%s'" % [key, node_data_keys_to_change[key]])
			node_data[node_data_keys_to_change[key]] = node_data[key]
			node_data.erase(key)
	print("conversion for save game data from pre v1 to v1 complete")
	

