class_name AIProfile
extends Resource

const MIN_BIAS := -10.0
const MAX_BIAS := 10.0
const BIAS_STEP := 0.1
const MIN_WEIGHT := -10.0
const MAX_WEIGHT := 10.0
const WEIGHT_STEP := 0.5

## 5 base biases
@export_group("Base Biases", "bias")
@export_range(MIN_BIAS, MAX_BIAS, BIAS_STEP) var bias_damage_player : float = 0.0
@export_range(MIN_BIAS, MAX_BIAS, BIAS_STEP) var bias_heal_self : float = 0.0
@export_range(MIN_BIAS, MAX_BIAS, BIAS_STEP) var bias_heal_enemy : float = 0.0
@export_range(MIN_BIAS, MAX_BIAS, BIAS_STEP) var bias_buff_self : float = 0.0
@export_range(MIN_BIAS, MAX_BIAS, BIAS_STEP) var bias_debuff_player : float = 0.0

@export_group("Consideration Weights", "weight")
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_matching_shield : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_frostbite_bounty : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_early_combat : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_high_hp_target : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_low_hp_target : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_low_hp_ally : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_low_hp_self : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_high_target_count : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_high_wind_sheared_count : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_high_active_shield_count : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_high_max_shield_value : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_total_dot_dealt : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_high_dot_count : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_high_dot_damage : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_dot_exist : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_cooldown : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_ap_cost : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_missing_self_buff : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_missing_target_debuff : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_excess_ap : float = 1.0
@export_range(MIN_WEIGHT, MAX_WEIGHT, WEIGHT_STEP) var weight_prevent_ap_overcap : float = 1.0

func get_weight(consideration: Utility.Consideration) -> float:
	match consideration:
		Utility.Consideration.MATCHING_SHIELD: return weight_matching_shield
		Utility.Consideration.FROSTBITE_BOUNTY: return weight_frostbite_bounty
		Utility.Consideration.EARLY_COMBAT: return weight_early_combat
		Utility.Consideration.HIGH_HP_TARGET: return weight_high_hp_target
		Utility.Consideration.LOW_HP_TARGET: return weight_low_hp_target
		Utility.Consideration.LOW_HP_ALLY: return weight_low_hp_ally
		Utility.Consideration.LOW_HP_SELF: return weight_low_hp_self
		Utility.Consideration.HIGH_TARGET_COUNT: return weight_high_target_count
		Utility.Consideration.HIGH_WIND_SHEARED_COUNT: return weight_high_wind_sheared_count
		Utility.Consideration.HIGH_ACTIVE_SHIELD_COUNT: return weight_high_active_shield_count
		Utility.Consideration.HIGH_MAX_SHIELD_VALUE: return weight_high_max_shield_value
		Utility.Consideration.TOTAL_DOT_DEALT: return weight_total_dot_dealt
		Utility.Consideration.HIGH_DOT_COUNT: return weight_high_dot_count
		Utility.Consideration.HIGH_DOT_DAMAGE: return weight_high_dot_damage
		Utility.Consideration.DOT_EXIST: return weight_dot_exist
		Utility.Consideration.COOLDOWN: return weight_cooldown
		Utility.Consideration.AP_COST: return weight_ap_cost
		Utility.Consideration.MISSING_SELF_BUFF: return weight_missing_self_buff
		Utility.Consideration.MISSING_TARGET_DEBUFF: return weight_missing_target_debuff
		Utility.Consideration.EXCESS_AP: return weight_excess_ap
		Utility.Consideration.PREVENT_AP_OVERCAP: return weight_prevent_ap_overcap
	push_warning("No weight defined for consideration: %s" % Utility.Consideration.find_key(consideration))
	return 0.0
