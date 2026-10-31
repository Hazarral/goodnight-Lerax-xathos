class_name UtilityEntry
extends Resource

@export var tag : Utility.Tag
@export var target_faction : ActionEvent.TargetFaction
@export var target_mode : ActionEvent.TargetMode

func _init(
	p_tag : Utility.Tag = Utility.Tag.DAMAGE, 
	p_target_faction : ActionEvent.TargetFaction = ActionEvent.TargetFaction.ALL, 
	p_target_mode : ActionEvent.TargetMode = ActionEvent.TargetMode.ALL_INDEPENDENT_FILTER
) -> void:
	tag = p_tag
	target_faction = p_target_faction
	target_mode = p_target_mode
