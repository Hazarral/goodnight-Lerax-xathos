@tool
class_name Utility
extends Resource

enum Tag {
	DAMAGE,
	HEAL,
	APPLY_BURN,
	APPLY_CURRENT,
	APPLY_WIND_SHEAR,
	APPLY_POISON,
	APPLY_SHOCK,
	APPLY_BLEED,
	APPLY_CRUMBLE,
	APPLY_FROSTBITE,
	APPLY_VOID,
	APPLY_RANDOM_DOT,
	APPLY_STATUS_EFFECT,		## Neutral by design, not actually considered
	APPLY_BUFF,
	APPLY_DEBUFF
}

enum Consideration {
	MATCHING_SHIELD,			## Boolean
	FROSTBITE_BOUNTY,			## Additive
	EARLY_COMBAT,
	HIGH_HP_TARGET,				## Current HP
	LOW_HP_TARGET,				## Current HP
	HIGH_TARGET_COUNT,
	HIGH_WIND_SHEARED_COUNT,
	HIGH_ACTIVE_SHIELD_COUNT,
	TOTAL_DOT_DEALT,			## Damage but DoT version, the potential
	HIGH_DOT_COUNT,				## Target has a lot of DoT instances
	HIGH_DOT_DAMAGE,			## Target has high total DoT damage received
	DOT_EXIST					## Boolean
}

##TODO: Populate this!!!
const TAG_CONSIDERATION : Dictionary[Tag, Array] = {
	Tag.DAMAGE : [
		Consideration.MATCHING_SHIELD,
		Consideration.FROSTBITE_BOUNTY,
		Consideration.HIGH_HP_TARGET,
		Consideration.LOW_HP_TARGET
	],
	Tag.HEAL : [
		Consideration.LOW_HP_TARGET
	]
}

@export var tags : Array[Tag] = []

@export var considerations : Array[Consideration] = []

@export_tool_button("Auto-populate Considerations")
var auto_tag_button = _auto_assign_considerations

func _auto_assign_considerations() -> void:
	# Loop through every tag currently assigned to this action
	for current_tag in tags:
		assert(TAG_CONSIDERATION.has(current_tag), "ACTION CONFIG ERROR: Nonexistent tag %s" % current_tag)
		var auto_considerations: Array = TAG_CONSIDERATION[current_tag]
		
		# Add the consideration if it isn't already in the list
		for cons in auto_considerations:
			if not cons in considerations:
				considerations.append(cons)
