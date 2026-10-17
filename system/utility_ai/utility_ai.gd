class_name UtilityAI
extends RefCounted

##TODO: decide where the weights should go, if they are pure attributes or a class
##TODO: implement the scoring functions here as well

const LOGISTICS_EXPONENT_COEFFICIENT : float = 10.0
const LOGISTICS_EXPONENT_MIDPOINT : float = 0.5

const EXPONENTIAL_DECAY_COEFFICIENT : float = 0.1

static func _logistics(min_val : float, max_val : float, value : float) -> float:
	var power : float = -LOGISTICS_EXPONENT_COEFFICIENT * (value - LOGISTICS_EXPONENT_MIDPOINT)
	return min_val + (max_val - min_val) / (1 + exp(power))

static func _exponential_decay(min_val : float, max_val : float, value : float) -> float:
	return min_val + (max_val - min_val) * exp(-EXPONENTIAL_DECAY_COEFFICIENT * value)
