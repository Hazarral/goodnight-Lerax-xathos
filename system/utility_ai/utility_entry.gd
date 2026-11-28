class_name UtilityEntry
extends Resource

@export var tag : Utility.Tag
@export var target_faction : ActionEvent.TargetFaction
@export var target_mode : ActionEvent.TargetMode

static func create(
	p_tag : Utility.Tag,
	p_target_faction : ActionEvent.TargetFaction, 
	p_target_mode : ActionEvent.TargetMode
) -> UtilityEntry:
	var entry := UtilityEntry.new()
	entry.tag = p_tag
	entry.target_faction = p_target_faction
	entry.target_mode = p_target_mode
	return entry
