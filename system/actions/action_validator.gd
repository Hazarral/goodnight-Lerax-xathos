extends Node

# Optional: Change this to your specific actions folder to make booting faster, 
# e.g., "res://resources/actions/". Leaving it as "res://" scans the whole project.
const ACTIONS_DIRECTORY: String = "res://system/actions/"

func _ready() -> void:
	# Only run these heavy checks when running the game from the editor.
	# Exported release builds will completely skip this to save boot time.
	if not OS.has_feature("editor"):
		return
		
	var all_actions: Array[Action] = _find_all_actions(ACTIONS_DIRECTORY)
	
	for action in all_actions:
		# 1. Validate the single_target_action_event
		if action.single_target_action_event != null:
			assert(
				action.single_target_action_event.target_mode == ActionEvent.TargetMode.SINGLE_INDEPENDENT_FILTER, 
				"ACTION CONFIG ERROR: Action '%s' has an invalid single_target mode! It MUST be SINGLE_INDEPENDENT_FILTER." % action.resource_path
			)
			
		# 2. Validate the action_events array
		for i in range(action.action_events.size()):
			var event = action.action_events[i]
			assert(event != null, "ACTION CONFIG ERROR: Action '%s' has null action_events[%d]" % [action.resource_path, i])
			assert(
				event.target_mode != ActionEvent.TargetMode.SINGLE_INDEPENDENT_FILTER,
				"ACTION CONFIG ERROR: Action '%s' contains SINGLE_INDEPENDENT_FILTER at action_events[%d]! This is not allowed in the array." % [action.resource_path, i]
			)
				
	print("ActionValidator: Successfully validated %d Action resources." % all_actions.size())

# Recursively scans the given directory for any Resource that is an Action
func _find_all_actions(path : String) -> Array[Action]:
	var actions : Array[Action] = []
	var dir = DirAccess.open(path)
	
	if dir == null:
		return actions
	
	dir.list_dir_begin()	
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		
		if dir.current_is_dir():
			# Ignore hidden directories like .godot
			if not file_name.begins_with("."): 
				actions.append_array(_find_all_actions(path.path_join(file_name)))
			continue
		
		# Only check resource files
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var file_path = path.path_join(file_name)
			var res = load(file_path)
			if res is Action:
				actions.append(res)
	
	return actions
