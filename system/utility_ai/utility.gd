@tool
class_name Utility
extends Resource

enum Tag {
	DAMAGE,
	HEAL,
	SINGLE_TARGET,			## Self cast is always single target implicitly
	MULTI_TARGET,			## Also known as AoE
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
	HIGH_MAX_SHIELD_VALUE,
	TOTAL_DOT_DEALT,			## Damage but DoT version, the potential
	HIGH_DOT_COUNT,				## Target has a lot of DoT instances
	HIGH_DOT_DAMAGE,			## Target has high total DoT damage received
	DOT_EXIST,					## Boolean
	COOLDOWN,
	AP_COST
}

const TAG_CONSIDERATION : Dictionary[Tag, Array] = {
	Tag.DAMAGE : [
		Consideration.MATCHING_SHIELD,
		Consideration.FROSTBITE_BOUNTY,
		Consideration.HIGH_HP_TARGET,
		Consideration.LOW_HP_TARGET
	],
	Tag.HEAL : [
		Consideration.LOW_HP_TARGET
	],
	Tag.SINGLE_TARGET : [
		Consideration.HIGH_TARGET_COUNT # Most of the time this is ignored with a weight of 0.0 
	],
	Tag.MULTI_TARGET : [
		Consideration.HIGH_TARGET_COUNT # More targets = higher score, more reasons to use AoE!
	],
	Tag.APPLY_BURN : [
		Consideration.EARLY_COMBAT,
		Consideration.HIGH_HP_TARGET,
		Consideration.TOTAL_DOT_DEALT
	],
	Tag.APPLY_CURRENT : [
		Consideration.DOT_EXIST,
		Consideration.HIGH_DOT_DAMAGE
	],
	Tag.APPLY_WIND_SHEAR : [
		Consideration.DOT_EXIST,
		Consideration.HIGH_DOT_DAMAGE,
		Consideration.HIGH_TARGET_COUNT,
		Consideration.HIGH_WIND_SHEARED_COUNT
	],
	Tag.APPLY_POISON : [
		Consideration.LOW_HP_TARGET
	],
	Tag.APPLY_SHOCK : [
		Consideration.LOW_HP_TARGET
	],
	Tag.APPLY_BLEED : [
		Consideration.LOW_HP_TARGET
	],
	Tag.APPLY_CRUMBLE : [
		Consideration.HIGH_MAX_SHIELD_VALUE,
		Consideration.HIGH_ACTIVE_SHIELD_COUNT
	],
	Tag.APPLY_FROSTBITE : [
		Consideration.HIGH_MAX_SHIELD_VALUE,
		Consideration.FROSTBITE_BOUNTY
	],
	Tag.APPLY_VOID : [
		Consideration.EARLY_COMBAT,
		Consideration.HIGH_HP_TARGET
	],
	Tag.APPLY_RANDOM_DOT : [
		Consideration.FROSTBITE_BOUNTY
	],
	Tag.APPLY_STATUS_EFFECT : [
		# Nothing, status effect is too broad
	],
	Tag.APPLY_BUFF : [
		# Nothing, buff is too broad
	],
	Tag.APPLY_DEBUFF : [
		# Nothing, debuff is too broad
	]
}

@export var tags : Array[Tag] = []

@export var considerations : Array[Consideration] = []

@export_tool_button("Auto-populate Considerations")
## Auto-fill considerations based on current tags
var auto_consider_button := _auto_assign_considerations

func _auto_assign_considerations() -> void:
	## NOTE: Safety check before clearing anything
	for current_tag in tags:
		assert(TAG_CONSIDERATION.has(current_tag), "ACTION CONFIG ERROR: Nonexistent tag %s" % current_tag)
		
	var new_considerations: Array[Consideration] = []
	
	# Loop through every tag currently assigned to this action
	for current_tag in tags:
		var auto_considerations : Array = TAG_CONSIDERATION[current_tag]
		# Add the consideration if it isn't already in the list
		for cons in auto_considerations:
			if not cons in new_considerations:
				new_considerations.append(cons)
	
	considerations = new_considerations
	notify_property_list_changed()
	print("Successfully auto-filled %d considerations" % considerations.size())
