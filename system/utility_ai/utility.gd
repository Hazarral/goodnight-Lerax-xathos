@tool
class_name Utility
extends Resource

enum Tag {
	DAMAGE = 0,
	HEAL = 1,
	SINGLE_TARGET = 2,			## Self cast is always single target implicitly
	MULTI_TARGET = 3,			## Also known as AoE
	APPLY_BURN = 4,
	APPLY_CURRENT = 5,
	APPLY_WIND_SHEAR = 6,
	APPLY_POISON = 7,
	APPLY_SHOCK = 8,
	APPLY_BLEED = 9,
	APPLY_CRUMBLE = 10,
	APPLY_FROSTBITE = 11,
	APPLY_VOID = 12,
	APPLY_RANDOM_DOT = 13,
	APPLY_STATUS_EFFECT = 14,	## Neutral by design, not actually considered
	APPLY_BUFF = 15,
	APPLY_DEBUFF = 16
}

enum Consideration {
	MATCHING_SHIELD = 0,		## Boolean
	FROSTBITE_BOUNTY = 1,		## Additive
	EARLY_COMBAT = 2,
	HIGH_HP_TARGET = 3,			## Current HP
	LOW_HP_TARGET = 4,			## Current HP
	LOW_HP_ALLY = 5,
	LOW_HP_SELF = 6,
	HIGH_TARGET_COUNT = 7,
	HIGH_WIND_SHEARED_COUNT = 8,
	HIGH_ACTIVE_SHIELD_COUNT = 9,
	HIGH_MAX_SHIELD_VALUE = 10,
	TOTAL_DOT_DEALT = 11,		## Damage but DoT version, the potential
	HIGH_DOT_COUNT = 12,		## Target has a lot of DoT instances
	HIGH_DOT_DAMAGE = 13,		## Target has high total DoT damage received
	DOT_EXIST = 14,				## Boolean
	COOLDOWN = 15,
	AP_COST = 16,
	MISSING_SELF_BUFF = 17,		## Boolean: Returns 1.0 if the caster DOES NOT have the buff, 0.0 if they already do.
	MISSING_TARGET_DEBUFF = 18,	## Boolean: Returns 1.0 if the target DOES NOT have the debuff.
	EXCESS_AP = 19,				## Additive/Curve: Scores higher the closer the caster is to their Max AP.
	PREVENT_AP_OVERCAP = 20		## Additive, [0.0, 1.0] to reward some actions to burn AP, must be dynamic
}

## Always attached to every action, regardless of tags
const ALWAYS : Array[Consideration] = [
	Consideration.COOLDOWN,
	Consideration.AP_COST,
	Consideration.EXCESS_AP,
	Consideration.PREVENT_AP_OVERCAP
]

## This table is entirely heuristics and not the end-all-be-all truth
const TAG_CONSIDERATION : Dictionary[Tag, Array] = {
	Tag.DAMAGE : [
		Consideration.MATCHING_SHIELD,
		Consideration.FROSTBITE_BOUNTY,
		Consideration.LOW_HP_TARGET
	],
	Tag.HEAL : [
		Consideration.LOW_HP_ALLY,
		Consideration.LOW_HP_SELF
	],
	Tag.SINGLE_TARGET : [
		Consideration.HIGH_TARGET_COUNT # Most of the time this is ignored with a weight of 0.0 
	],
	Tag.MULTI_TARGET : [
		Consideration.HIGH_TARGET_COUNT # More targets = higher score, more reasons to use AoE!
	],
	Tag.APPLY_BURN : [
		Consideration.MATCHING_SHIELD,
		Consideration.EARLY_COMBAT,
		Consideration.HIGH_HP_TARGET,
		Consideration.TOTAL_DOT_DEALT
	],
	Tag.APPLY_CURRENT : [
		Consideration.MATCHING_SHIELD,
		Consideration.DOT_EXIST,
		Consideration.HIGH_DOT_DAMAGE
	],
	Tag.APPLY_WIND_SHEAR : [
		Consideration.MATCHING_SHIELD,
		Consideration.DOT_EXIST,
		Consideration.HIGH_DOT_DAMAGE,
		Consideration.HIGH_TARGET_COUNT,
		Consideration.HIGH_WIND_SHEARED_COUNT
	],
	Tag.APPLY_POISON : [
		Consideration.MATCHING_SHIELD,
		Consideration.LOW_HP_TARGET
	],
	Tag.APPLY_SHOCK : [
		Consideration.MATCHING_SHIELD,
		Consideration.LOW_HP_TARGET
	],
	Tag.APPLY_BLEED : [
		Consideration.MATCHING_SHIELD,
		Consideration.LOW_HP_TARGET
	],
	Tag.APPLY_CRUMBLE : [
		Consideration.MATCHING_SHIELD,
		Consideration.HIGH_MAX_SHIELD_VALUE,
		Consideration.HIGH_ACTIVE_SHIELD_COUNT
	],
	Tag.APPLY_FROSTBITE : [
		Consideration.MATCHING_SHIELD,
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
		Consideration.MISSING_SELF_BUFF,  # CRITICAL: Prevents casting buff if it's already active.
		Consideration.EXCESS_AP,          # Good heuristic: Buff when you have plenty of AP to combo next turn.
		Consideration.EARLY_COMBAT        # Buffs generally yield more value the earlier they are cast.
	],
	Tag.APPLY_DEBUFF : [
		Consideration.MISSING_TARGET_DEBUFF, # Don't waste turns applying Vulnerability to someone who already has it.
		Consideration.HIGH_HP_TARGET         # Debuffing the healthiest target yields the best mathematical return on damage.
	]
}


static func get_tag_name(tag : Tag) -> String:
	return Tag.keys()[tag]

@export var utility_entries : Array[UtilityEntry] = []

@export var considerations : Array[Consideration] = []

@export_tool_button("Auto-populate Considerations")
## Auto-fill considerations based on current tags
var auto_consider_button := _auto_assign_considerations

func _auto_assign_considerations() -> void:
	## NOTE: Safety check before clearing anything
	for entry in utility_entries:
		var tag := entry.tag
		assert(TAG_CONSIDERATION.has(tag), "ACTION CONFIG ERROR: Nonexistent tag %s" % tag)
		
	var new_considerations: Array[Consideration] = []
	new_considerations.assign(ALWAYS)
	
	# Loop through every tag currently assigned to this action
	for entry in utility_entries:
		var auto_considerations : Array = TAG_CONSIDERATION[entry.tag]
		# Add the consideration if it isn't already in the list
		for cons in auto_considerations:
			if not cons in new_considerations:
				new_considerations.append(cons)
	
	considerations = new_considerations
	notify_property_list_changed()
	print("Successfully auto-filled %d considerations" % considerations.size())
