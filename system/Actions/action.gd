@tool
class_name Action
extends Resource

## What world this came from
@export var origin : World.Origin

## Name of this action, e.g. "Fire Breath"
@export var action_name : String

## Cost to cast this action, in AP
@export var action_point_cost : int

## Cooldown, in turns
@export var cooldown : int

## Description: what it does
@export var description_segments : Array[DescriptionSegment]

## First action event which is single target manually picked. This is optional
@export var single_target_action_event : ActionEvent

## List of modular action this will perform in order, all ActionEvent have the same targeting specification as this Action
@export var action_events : Array[ActionEvent]

## Tags and considerations, used for AI mostly
@export var utility : Utility

@export_tool_button("Auto-populate Tags")
var auto_tag_button := _auto_assign_tags

func cast(source : Entity) -> bool:	
	var last_targets : Array[Entity] = []
	
	if single_target_action_event != null:
		var dynamic_event : Variant = single_target_action_event
		var success : bool = await dynamic_event.resolve(source, last_targets)
		if not success:
			return false
		last_targets = single_target_action_event.get_last_resolved_targets()
	
	for action_event in action_events:
		var dynamic_event : Variant = action_event
		await dynamic_event.resolve(source, last_targets)
		last_targets = action_event.get_last_resolved_targets()
	
	return true

func _auto_assign_tags() -> void:
	if utility == null:
		push_warning("Cannot auto-assign tags: 'utility' subresource is null.")
		return
	
	var tag_dict : Dictionary[Utility.Tag, bool] = {}
	
	for action_event : ActionEvent in [single_target_action_event] + action_events:
		if action_event == null:
			continue
		
		var curr_tags = action_event.get_tags()
		for tag in curr_tags:
			tag_dict[tag] = true
	
	## Populate the list
	var typed_tags: Array[Utility.Tag] = []
	typed_tags.assign(tag_dict.keys())
	
	utility.tags = typed_tags
	
	utility.notify_property_list_changed()
	notify_property_list_changed()
	print("Successfully auto-filled %d tags" % utility.tags.size())
