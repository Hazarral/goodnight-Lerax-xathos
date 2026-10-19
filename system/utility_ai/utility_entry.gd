class_name UtilityEntry
extends Resource

@export var tag : Utility.Tag
@export var target_faction : ActionEvent.TargetFaction
@export var target_mode : ActionEvent.TargetMode

func _init(p_tag : Utility.Tag, p_target_faction : ActionEvent.TargetFaction, p_target_mode : ActionEvent.TargetMode) -> void:
	tag = p_tag
	target_faction = p_target_faction
	target_mode = p_target_mode
