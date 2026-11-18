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
const HIGH_MAX_SHIELD_RATIO_CAP := 0.5
const HIGH_TOTAL_DOT_RATIO_CAP := 1.0

const LOW_HP_TARGET_MIN_VAL := -0.5
const HIGH_HP_TARGET_MIN_VAL = -0.2

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

static func _lerp_float(value : float, max_value : float) -> float:
	## Typically used with HighMaxShieldValue, where value is a ratio
	var t := clampf(value / max_value, 0.0, 1.0)
	return MIN_VAL + RANGE * t

static func _frostbite_bounty(current_shield_ratio : float, is_ice_shield : bool) -> float:
	#var base_max := FROSTBITE_BOUNTY_BASE_MAX_ICE if is_ice_shield else FROSTBITE_BOUNTY_BASE_MAX
	#return FROSTBITE_BOUNTY_BASE + base_max * (1 - current_shield_ratio)
	## NOTE: This needs heavy rework, so it is archived
	return 0.0

static func _boolean(value : bool) -> float:
	return BOOLEAN_TRUE if value else BOOLEAN_FALSE

static func get_raw_score(scoring_context : ScoringContext, consideration : Utility.Consideration) -> float:
	var actor := scoring_context.actor
	var target := scoring_context.target
	var target_count := scoring_context.target_count
	var damage_types := scoring_context.damage_types
	var dot_instances := scoring_context.dot_instances
	var combat_field_state := scoring_context.combat_field_state
	
	##TODO: Replace target count with valid_target_count and add an is_single boolean
	
	match consideration:
		Utility.Consideration.MATCHING_SHIELD:
			return _matching_shield_score(damage_types, dot_instances, target)
		Utility.Consideration.FROSTBITE_BOUNTY:
			## WORK IN PROGRESS, will be updated later
			## TODO: rework Frostbite bounty scoring
			return 0.0
		Utility.Consideration.EARLY_COMBAT:
			return _early_combat_score(combat_field_state)
		Utility.Consideration.HIGH_HP_TARGET:
			return _high_hp_target_score(target)
		Utility.Consideration.LOW_HP_TARGET:
			return _low_hp_target_score(target)
		Utility.Consideration.LOW_HP_ALLY:
			# Yes, an ally is a target too
			# This will not check if the target is the same faction as actor 
			return _low_hp_target_score(target)
		Utility.Consideration.LOW_HP_SELF:
			return _low_hp_target_score(actor)
		Utility.Consideration.HIGH_TARGET_COUNT:
			return _high_target_count_score(target_count)
		Utility.Consideration.HIGH_WIND_SHEARED_COUNT:
			return _high_wind_sheared_count_score(actor)
		Utility.Consideration.HIGH_ACTIVE_SHIELD_COUNT:
			return _high_active_shield_count_score(target)
		Utility.Consideration.HIGH_MAX_SHIELD_VALUE:
			return _high_max_shield_value_score(target)
		Utility.Consideration.TOTAL_DOT_DEALT:
			return _total_dot_dealt_score(actor, target, dot_instances)
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
	dot_instances : Array[DoTInstance], 
	target : Entity
) -> float:
	## NOTE: Naive version, scales linearly with matching count, 
	## damage_types and dot_types are guaranteed to have no duplicate
	var total := damage_types.size() + dot_instances.size()
	if total == 0:
		return MIN_VAL
	
	var match_count := 0
	for damage_type in damage_types:
		if target.has_shield(damage_type):
			match_count += 1
	
	for dot_instance in dot_instances:
		if target.has_shield(dot_instance.damage_type):
			match_count += 1
	
	# Fraction will try to fill up from min to max
	return MIN_VAL + RANGE * float(match_count) / total

static func _early_combat_score(combat_field_state : CombatFieldState) -> float:
	var round_counter := combat_field_state.round_counter
	var turn_counter := combat_field_state.turn_counter
	
	var progression := (
		round_counter + 
		EARLY_COMBAT_TURN_COUNTER_WEIGHT * log(turn_counter + 1)
	) 
	
	return _exponential_decay(progression)

static func _high_hp_target_score(target : Entity) -> float:
	return clampf(_logistics(float(target.current_hp) / target.get_max_hp(), false), HIGH_HP_TARGET_MIN_VAL, MAX_VAL)

static func _low_hp_target_score(target : Entity) -> float:
	return clampf(_logistics(float(target.current_hp) / target.get_max_hp(), true), LOW_HP_TARGET_MIN_VAL, MAX_VAL)

static func _high_target_count_score(target_count : int) -> float:
	return _logarithmic(target_count)

static func _high_wind_sheared_count_score(actor : Entity) -> float:
	# Opposite faction
	var faction := ActionEvent.TargetFaction.ENEMY if actor.is_player_faction() else ActionEvent.TargetFaction.PLAYER
	var target_count := DamageAndDoT.get_wind_shear_special_effect_targets(null, faction).size()
	return _logarithmic(target_count)

static func _high_active_shield_count_score(target : Entity) -> float:
	return _lerp(target.get_active_shield_count())

static func _high_max_shield_value_score(target : Entity) -> float:
	var ratio := target.get_total_max_shield() / maxf(target.max_hp, 1.0)
	return _lerp_float(ratio, HIGH_MAX_SHIELD_RATIO_CAP)

## Helper
static func calculate_total_dot_damage(dot_instance : DoTInstance, potency : int, mastery : int) -> float:
	var dot_type : DamageAndDoT.DoT = DamageAndDoT.get_dot(dot_instance.damage_type)
	var duration : int = dot_instance.duration  # use your actual field name
	
	if dot_type == DamageAndDoT.DoT.VOID:
		push_error("Void has special damage! Please use VoidInstance.get_void_damage(...)")
		return 0.0
	
	var total := 0.0
	for i in range(maxi(duration, 0)):
		var remaining := duration - i  # D, D-1, ..., 1
		var tick := DamageAndDoT.calculate_dot_damage(
			dot_type, 
			dot_instance.base_damage, 
			potency, 
			mastery, 
			dot_instance.stacks, 
			remaining
		)
		if dot_instance is BurnInstance:
			tick *= dot_instance.get_burn_multiplier(i)
		total += tick
	return total

static func _get_effective_pool(target : Entity, damage_type : DamageAndDoT.DamageType) -> int:
	if target.has_shield(damage_type):
		return target.current_hp + target.current_shields[damage_type]  # 0 if breached
	return target.current_hp + 2 * target.get_total_current_shield()

static func _total_dot_dealt_score(actor : Entity, target : Entity, dot_instances : Array[DoTInstance]) -> float:
	if dot_instances.is_empty():
		return MIN_VAL
	
	var potency := actor.get_potency()
	var mastery := actor.get_mastery()
	var ratio := 0.0
	for dot_instance in dot_instances:
		var damage := calculate_total_dot_damage(dot_instance, potency, mastery)
		ratio += damage / maxi(_get_effective_pool(target, dot_instance.damage_type), 1)
	
	return MIN_VAL + RANGE * clampf(ratio / HIGH_TOTAL_DOT_RATIO_CAP, 0.0, 1.0)
