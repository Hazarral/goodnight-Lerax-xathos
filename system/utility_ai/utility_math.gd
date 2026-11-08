class_name UtilityMath
extends Object

const MIN_VAL : float = -1.0
const MAX_VAL : float = 1.0
const RANGE : float = MAX_VAL - MIN_VAL

const LOGISTICS_EXPONENT_COEFFICIENT : float = 10.0
const LOGISTICS_EXPONENT_MIDPOINT : float = 0.5

const EXPONENTIAL_DECAY_COEFFICIENT : float = 0.1

const LOGARITHMIC_MAX_COUNT : int = CombatSystem.MAX_ALIVE_ENEMY_ON_FIELD

const LINEAR_EXTRAPOLATION_MAX_COUNT : int = DamageAndDoT.ELEMENT_COUNT

const FROSTBITE_BOUNTY_BASE : float = 0.2
const FROSTBITE_BOUNTY_BASE_MAX : float = 0.6
const FROSTBITE_BOUNTY_BASE_MAX_ICE : float = 1.4

const BOOLEAN_TRUE := MAX_VAL
const BOOLEAN_FALSE := MIN_VAL

## Specific considerations
const EARLY_COMBAT_TURN_COUNTER_WEIGHT := 0.5

static func _logistics(value : float, is_decreasing : bool = false) -> float:
	## Typically used in HighHPTarget and LowHPTarget
	var sgn := 1 if is_decreasing else -1
	var power : float = sgn * LOGISTICS_EXPONENT_COEFFICIENT * (value - LOGISTICS_EXPONENT_MIDPOINT)
	return MIN_VAL + RANGE / (1 + exp(power))

static func _exponential_decay(value : float) -> float:
	return MIN_VAL + RANGE * exp(-EXPONENTIAL_DECAY_COEFFICIENT * maxf(value, 0.0))

static func _logarithmic(value : int) -> float:
	## Typically used in HighTargetCount
	var v := clampi(value, 0, LOGARITHMIC_MAX_COUNT)
	return MIN_VAL + RANGE * log(v + 1) / log(LOGARITHMIC_MAX_COUNT + 1)

static func _lerp(value : int) -> float:
	## Typically used with HighShieldCount
	var v := clampi(value, 0, LINEAR_EXTRAPOLATION_MAX_COUNT)
	return MIN_VAL + RANGE * v / LINEAR_EXTRAPOLATION_MAX_COUNT

static func _frostbite_bounty(current_shield_ratio : float, is_ice_shield : bool) -> float:
	#var base_max := FROSTBITE_BOUNTY_BASE_MAX_ICE if is_ice_shield else FROSTBITE_BOUNTY_BASE_MAX
	#return FROSTBITE_BOUNTY_BASE + base_max * (1 - current_shield_ratio)
	## NOTE: This needs heavy rework, so it is archived
	return 0.0

static func _boolean(value : bool) -> float:
	return BOOLEAN_TRUE if value else BOOLEAN_FALSE

static func get_raw_score(
	actor : Entity, 
	target : Entity, 
	damage_types : Array[DamageAndDoT.DamageType],
	dot_types : Array[DamageAndDoT.DoT],
	consideration : Utility.Consideration, 
	combat_field_state : CombatFieldState
) -> float:
	match consideration:
		Utility.Consideration.MATCHING_SHIELD:
			return _matching_shield_score(damage_types, dot_types, target)
		Utility.Consideration.FROSTBITE_BOUNTY:
			## WORK IN PROGRESS, will be updated later
			## TODO: rework Frostbite bounty scoring
			return 0.0
		Utility.Consideration.EARLY_COMBAT:
			## PLACEHOLDER
			return _early_combat_score(combat_field_state)
		Utility.Consideration.HIGH_HP_TARGET:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.LOW_HP_TARGET:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.LOW_HP_ALLY:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.LOW_HP_SELF:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.HIGH_TARGET_COUNT:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.HIGH_WIND_SHEARED_COUNT:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.HIGH_ACTIVE_SHIELD_COUNT:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.HIGH_MAX_SHIELD_VALUE:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.TOTAL_DOT_DEALT:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.HIGH_DOT_COUNT:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.HIGH_DOT_DAMAGE:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.DOT_EXIST:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.COOLDOWN:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.AP_COST:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.MISSING_SELF_BUFF:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.MISSING_TARGET_DEBUFF:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.EXCESS_AP:
			## PLACEHOLDER
			return 0.0
		Utility.Consideration.PREVENT_AP_OVERCAP:
			## PLACEHOLDER
			return 0.0
	
	## Guard for any enum value added later without a case
	push_error("Unhandled consideration: %s" % Utility.Consideration.keys()[consideration])
	return 0.0

static func _matching_shield_score(
	damage_types : Array[DamageAndDoT.DamageType], 
	dot_types : Array[DamageAndDoT.DoT], 
	target : Entity
) -> float:
	## NOTE: Naive version, scales linearly with matching count, 
	## damage_types and dot_types are guaranteed to have no duplicate
	if damage_types.is_empty():
		return MIN_VAL
	
	var result := 0.0
	for damage_type in damage_types:
		if not target.has_shield(damage_type):
			continue
		
		result += MAX_VAL
	
	for dot_type in dot_types:
		if not target.has_shield(DamageAndDoT.get_damage_type(dot_type)):
			continue
		
		result += MAX_VAL
	
	return result

static func _early_combat_score(combat_field_state : CombatFieldState) -> float:
	var round_counter := combat_field_state.round_counter
	var turn_counter := combat_field_state.turn_counter
	
	var progression := (
		round_counter + 
		EARLY_COMBAT_TURN_COUNTER_WEIGHT * log(turn_counter + 1)
	) 
	
	return _exponential_decay(progression)
