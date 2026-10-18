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

static func _logistics(value : float, is_decreasing : bool = false) -> float:
	## Typically used in HighHPTarget and LowHPTarget
	var sgn := 1 if is_decreasing else -1
	var power : float = sgn * LOGISTICS_EXPONENT_COEFFICIENT * (value - LOGISTICS_EXPONENT_MIDPOINT)
	return MIN_VAL + RANGE / (1 + exp(power))

static func _exponential_decay(value : float) -> float:
	return MIN_VAL + RANGE * exp(-EXPONENTIAL_DECAY_COEFFICIENT * value)

static func _logarithmic(value : int) -> float:
	## Typically used in HighTargetCount
	return MIN_VAL + RANGE * log(value + 1) / log(LOGARITHMIC_MAX_COUNT + 1)

static func _lerp(value : int) -> float:
	## Typically used with HighShieldCount
	return MIN_VAL + RANGE * value / LINEAR_EXTRAPOLATION_MAX_COUNT

static func _frostbite_bounty(current_shield_ratio : float, is_ice_shield : bool) -> float:
	var base_max := FROSTBITE_BOUNTY_BASE_MAX_ICE if is_ice_shield else FROSTBITE_BOUNTY_BASE_MAX
	return FROSTBITE_BOUNTY_BASE + base_max * (1 - current_shield_ratio)

static func _boolean(value : bool) -> float:
	return BOOLEAN_TRUE if value else BOOLEAN_FALSE
