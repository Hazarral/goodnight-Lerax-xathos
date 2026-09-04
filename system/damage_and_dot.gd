extends Node

enum DamageType {
	FIRE = 0,
	WATER = 1,
	WIND = 2,
	POISON = 3,
	LIGHTNING = 4,
	PHYSICAL = 5,
	EARTH = 6,
	ICE = 7,
	VOID = 8,
}

enum DoT {
	BURN = 0,
	CURRENT = 1,
	WIND_SHEAR = 2,
	POISON = 3,
	SHOCK = 4,
	BLEED = 5,
	CRUMBLE = 6,
	FROSTBITE = 7,
	VOID = 8
}

enum Coefficient {
	DAMAGE_POTENCY = 0,
	DAMAGE_MASTERY = 1,
	ATTRITION_POTENCY = 2,
	ATTRITION_MASTERY = 3
}

# The Master Balance Table
# Format: [Damage Potency, Damage Mastery, Attrition Potency, Attrition Mastery]
const DOT_COEFFICIENTS : Dictionary[DoT, PackedFloat32Array] = {
	DoT.BURN:       [2.0, 0.1, 0.1, 1.5],
	DoT.CURRENT:    [0.2, 0.2, 0.2, 0.2],
	DoT.WIND_SHEAR: [1.0, 0.1, 0.1, 2.0],
	DoT.POISON:     [0.2, 0.1, 0.5, 3.0],
	DoT.SHOCK:      [1.5, 0.5, 0.2, 0.5],
	DoT.BLEED:      [0.1, 0.1, 1.0, 1.0],
	DoT.CRUMBLE:    [2.5, 0.1, 0.5, 0.5],
	DoT.FROSTBITE:  [0.5, 0.5, 1.0, 1.5]
}

const ELEMENT_COUNT := 8
const MAX_DURATION := 10
const MAX_BURN_TIERS := 5

const VOID_MULTIPLIER_AGAINST_SHIELD := 1.0
const PENALIZED_MULTIPLIER_AGAINST_SHIELD := 2.0

# Damage types
const FIRE := &"Fire"
const WATER := &"Water"
const WIND := &"Wind"
const POISON := &"Poison"
const LIGHTNING := &"Lightning"
const PHYSICAL := &"Physical"
const EARTH := &"Earth"
const ICE := &"Ice"
const VOID := &"Void"

# DoT types
const BURN := &"Burn"
const CURRENT := &"Current"
const WIND_SHEAR := &"Wind Shear"
const SHOCK := &"Shock"
const BLEED := &"Bleed"
const CRUMBLE := &"Crumble"
const FROSTBITE := &"Frostbite"

# Colors
const FIRE_COLOR_HEX := "#eb571e"
const WATER_COLOR_HEX := "#44a1e2"
const WIND_COLOR_HEX := "#6da88f"
const POISON_COLOR_HEX := "#5ed85d"
const LIGHTNING_COLOR_HEX := "#8040ed"
const PHYSICAL_COLOR_HEX := "#b8b8b8"
const EARTH_COLOR_HEX := "#876600"
const ICE_COLOR_HEX := "#bad3fb"
const VOID_COLOR_HEX := "#ff1d75"
const GENERIC_COLOR_HEX := "#ffd4cc"
const HEALING_COLOR_HEX := "#00f0d8"
const TURN_LABEL_COLOR_HEX := "#ebe134"

## Special effects
const MAX_FIRE_MULTIPLIER := 3.0
const FIRE_MULTIPLIER_STEP := 0.5

const CURRENT_BASE_ECHO_EFFECTIVENESS := 20.0
const CURRENT_ECHO_MASTERY_COEFFICIENT := 0.25

const WIND_SHEAR_BASE_SPREAD_EFFECTIVENESS := 20.0
const WIND_SHEAR_SPREAD_MASTERY_COEFFICIENT := 0.1
const WIND_SHEAR_BASE_BLAST_EFFECTIVENESS := 40.0
const WIND_SHEAR_BLAST_BASE_ADDITIONAL_TARGET_EFFECTIVENESS := 50.0
const WIND_SHEAR_BLAST_ADDITIONAL_TARGET_POTENCY_COEFFICIENT := 0.3

const SHOCK_BASE_DAMAGE_ON_ACTION_EFFECTIVENESS := 30.0
const SHOCK_DAMAGE_ON_ACTION_POTENCY_COEFFICIENT := 0.25
const SHOCK_MAX_AP_SCALING := 3

const POISON_BASE_ATTRITION_EXPLOSION_EFFECTIVENESS := 30.0
const POISON_ATTRITION_EXPLOSION_MASTERY_COEFFICIENT := 0.2

const BLEED_HEALING_REDUCTION_MASTERY_COEFFICIENT := 0.5
const BLEED_BONUS_FLAT_DAMAGE_POTENCY_COEFFICIENT := 1.5
const BLEED_BONUS_FLAT_DAMAGE_STACKS_COEFFICIENT := 10.0
const BLEED_RUPTURE_DAMAGE_CAP_COEFFICIENT := 10.0

const CRUMBLE_BASE_SPLASH := 20.0
const CRUMBLE_SPLASH_POTENCY_COEFFICIENT := 0.35

const FROSTBITE_NON_ICE_SHIELD_BREAK_COEFFICIENT := 0.5
const FROSTBITE_ICE_SHIELD_BREAK_COEFFICIENT := 1.0

func get_dot(damage_type : DamageType) -> DoT:
	return damage_type as DoT

func get_damage_type(damage_over_time_type : DoT) -> DamageType:
	return damage_over_time_type as DamageType

func get_damage_type_name(damage_type : DamageType) -> String:
	match damage_type:
		DamageType.FIRE: return FIRE
		DamageType.WATER: return WATER
		DamageType.WIND: return WIND
		DamageType.POISON: return POISON
		DamageType.LIGHTNING: return LIGHTNING
		DamageType.PHYSICAL: return PHYSICAL
		DamageType.EARTH: return EARTH
		DamageType.ICE: return ICE
		DamageType.VOID: return VOID
	return ""

func get_damage_over_time_name(damage_over_time : DoT) -> String:
	match damage_over_time:
		DoT.BURN: return BURN
		DoT.CURRENT: return CURRENT
		DoT.WIND_SHEAR: return WIND_SHEAR
		DoT.POISON: return POISON
		DoT.SHOCK: return SHOCK
		DoT.BLEED: return BLEED
		DoT.CRUMBLE: return CRUMBLE
		DoT.FROSTBITE: return FROSTBITE
		DoT.VOID: return VOID
	return ""

func get_damage_color_hex(damage_type : DamageType) -> String:
	match damage_type:
		DamageType.FIRE: return FIRE_COLOR_HEX
		DamageType.WATER: return WATER_COLOR_HEX
		DamageType.WIND: return WIND_COLOR_HEX
		DamageType.POISON: return POISON_COLOR_HEX
		DamageType.LIGHTNING: return LIGHTNING_COLOR_HEX
		DamageType.PHYSICAL: return PHYSICAL_COLOR_HEX
		DamageType.EARTH: return EARTH_COLOR_HEX
		DamageType.ICE: return ICE_COLOR_HEX
		DamageType.VOID: return VOID_COLOR_HEX
	return ""

## CALCULATE DAMAGE
func calculate_dot_damage(dot_type : DoT, base_damage : float, potency : int, mastery : int, stacks : int, duration : int) -> float:
	if dot_type == DoT.VOID:
		push_error("Void has special damage! Please use VoidInstance.get_void_damage(...)")
		return 0.0
	
	var coefs : PackedFloat32Array = DOT_COEFFICIENTS.get(dot_type)
	var potency_coef : float = coefs[Coefficient.DAMAGE_POTENCY]
	var mastery_coef : float = coefs[Coefficient.DAMAGE_MASTERY]
	
	var raw_damage : float = (base_damage + duration + (potency_coef * potency) + (mastery_coef * mastery)) * stacks
	
	return raw_damage

## CALCULATE ATTRITION
func calculate_dot_attrition(dot_type : DoT, base_damage : float, potency : int, mastery : int, stacks : int, duration : int) -> float:
	if dot_type == DoT.VOID:
		push_error("Void has no Attrition!")
		return 0.0
	
	var coefs : PackedFloat32Array = DOT_COEFFICIENTS.get(dot_type)
	var potency_coef : float = coefs[Coefficient.ATTRITION_POTENCY]
	var mastery_coef : float = coefs[Coefficient.ATTRITION_MASTERY]
	
	var raw_attrition : float = (base_damage + stacks + (potency_coef * potency) + (mastery_coef * mastery)) * duration
	
	return raw_attrition

## CURRENT
func get_current_echo_effectiveness(mastery : int, use_percent : bool = false) -> float:
	var value := (CURRENT_BASE_ECHO_EFFECTIVENESS + CURRENT_ECHO_MASTERY_COEFFICIENT * mastery)
	if use_percent:
		return value
	
	return value / 100.0	

func get_current_echo_damage(total_damage : float, mastery : int) -> float:
	return total_damage * get_current_echo_effectiveness(mastery)

## WIND SHEAR
func get_wind_shear_spread_target_condition(source : Entity, target : Entity) -> bool:
	return target.has_dot(DoT.WIND_SHEAR) and target != source

func get_wind_shear_special_effect_targets(source : Entity, is_player_faction : bool) -> Array[Entity]:
	var faction := ActionEvent.TargetFaction.PLAYER if is_player_faction else ActionEvent.TargetFaction.ENEMY
	var valid_targets = CombatSystem.get_valid_targets(faction, ActionEvent.TargetState.ALL).filter(
		func (entity : Entity) -> bool: return DamageAndDoT.get_wind_shear_spread_target_condition(source, entity)
	)
	return valid_targets

func get_wind_shear_spread_effectiveess(mastery : int, use_percent : bool = false) -> float:
	var value := (WIND_SHEAR_BASE_SPREAD_EFFECTIVENESS + WIND_SHEAR_SPREAD_MASTERY_COEFFICIENT * mastery)
	if use_percent:
		return value
		
	return value / 100.0

func get_wind_shear_spread_damage(total_damage : float, mastery : int) -> float:
	return total_damage * get_wind_shear_spread_effectiveess(mastery)

func get_wind_shear_blast_effectiveness(potency : int, afflicted_count : int, use_percent : bool = false) -> float:
	var value := WIND_SHEAR_BASE_BLAST_EFFECTIVENESS + (WIND_SHEAR_BLAST_BASE_ADDITIONAL_TARGET_EFFECTIVENESS + WIND_SHEAR_BLAST_ADDITIONAL_TARGET_POTENCY_COEFFICIENT * potency) * (afflicted_count)
	if use_percent:
		return value
	
	return value / 100.0

func get_wind_shear_blast_damage(total_wind_shear_damage : float, potency : int, afflicted_count : int) -> float:
	return total_wind_shear_damage * get_wind_shear_blast_effectiveness(potency, afflicted_count)

## SHOCK
func get_shock_damage_on_action_effectiveness(potency : int, use_percent : bool = false) -> float:
	var value := SHOCK_BASE_DAMAGE_ON_ACTION_EFFECTIVENESS + SHOCK_DAMAGE_ON_ACTION_POTENCY_COEFFICIENT * potency
	if use_percent:
		return value
	
	return value / 100.0

func get_shock_damage_on_action(total_shock_damage : float, potency : int, action_point_spent : int) -> float:
	var multiplier := minf(SHOCK_MAX_AP_SCALING, action_point_spent)
	return total_shock_damage * get_shock_damage_on_action_effectiveness(potency) * multiplier

## POISON
func get_poison_attrition_explosion_effectiveness(mastery : int, use_percent : bool = false) -> float:
	var value := POISON_BASE_ATTRITION_EXPLOSION_EFFECTIVENESS + POISON_ATTRITION_EXPLOSION_MASTERY_COEFFICIENT * mastery
	if use_percent:
		return value
	
	return value / 100.0 

func get_poison_attrition_explosion_damage(total_attrition : int, mastery : int) -> float:
	return total_attrition * get_poison_attrition_explosion_effectiveness(mastery)

func get_poison_special_effect_targets(source : Entity, is_player_faction : bool) -> Array[Entity]:
	var faction := ActionEvent.TargetFaction.PLAYER if is_player_faction else ActionEvent.TargetFaction.ENEMY
	var valid_targets = CombatSystem.get_valid_targets(faction, ActionEvent.TargetState.ALL).filter(
		func (entity : Entity) -> bool: return entity != source
	)
	return valid_targets

func transfer_poison_damage_over_time(source : Entity, target : Entity) -> void:
	## NOTE: This must only be called after checking that the source has poison
	for poison_instance : DoTInstance in source.active_dots[DamageAndDoT.DoT.POISON].data:
		target.apply_dot(poison_instance)
	
	source.active_dots[DamageAndDoT.DoT.POISON].clear_all_instances()

## BLEED
func get_bleed_healing_reduction(mastery : int, use_percent : bool = false) -> float:
	var value := (BLEED_HEALING_REDUCTION_MASTERY_COEFFICIENT * mastery)
	if use_percent:
		return value
	
	return value / 100.0

func get_bleed_anti_heal_flat_damage_bonus(potency : int, stacks : int) -> float:
	return BLEED_BONUS_FLAT_DAMAGE_POTENCY_COEFFICIENT * potency + BLEED_BONUS_FLAT_DAMAGE_STACKS_COEFFICIENT * stacks

func get_bleed_anti_heal_damage(total_bleed_damage : float, total_healing : float, mastery : int, potency : int, stacks : int) -> float:
	return minf(
		BLEED_RUPTURE_DAMAGE_CAP_COEFFICIENT * total_bleed_damage, 
		total_healing * get_bleed_healing_reduction(mastery) + get_bleed_anti_heal_flat_damage_bonus(potency, stacks)
	)

## CRUMBLE
func get_crumble_splash_effectiveness(potency : int, use_percent : bool = false) -> float:
	var value := (CRUMBLE_BASE_SPLASH + CRUMBLE_SPLASH_POTENCY_COEFFICIENT * potency)
	if use_percent:
		return value
	
	return value / 100.0

func get_crumble_splash_damage(total_damage : float, potency : int) -> float:
	return total_damage * get_crumble_splash_effectiveness(potency)

## VOID
## Player scaling
const MAX_HP_SCALING := 0.01
const TOTAL_MAX_SHIELD_SCALING := 0.01
const POTENCY_COEFFICIENT_SCALING := 0.5
const POTENCY_EXPONENT_SCALING := 1.2
const MASTERY_COEFFICIENT_SCALING := 0.5
const MASTERY_EXPONENT_SCALING := 1.2
const TOTAL_ATTRITION_EXPONENT_SCALING := 0.5
const ESCALATION_MULTIPLIER_BASE := 1.20

## Enemy scaling
const ENEMY_BASE_DAMAGE := 10
const ENEMY_POTENCY_COEFFICIENT_SCALING := 10.0
const ENEMY_MASTERY_COEFFICIENT_SCALING := 10.0

func get_void_escalation(turns_elapsed : int) -> float:
	return pow(ESCALATION_MULTIPLIER_BASE, turns_elapsed)

func get_void_damage_to_enemy(dragon_max_hp : int, dragon_total_max_shield : int, potency : int, mastery: int, total_target_attrition : int, stacks : int, turns_elapsed : int) -> int:	
	return ceili(
		(
			MAX_HP_SCALING * dragon_max_hp + 
			TOTAL_MAX_SHIELD_SCALING * dragon_total_max_shield +
			POTENCY_COEFFICIENT_SCALING * pow(potency, POTENCY_EXPONENT_SCALING) +
			MASTERY_COEFFICIENT_SCALING * pow(mastery, MASTERY_EXPONENT_SCALING) + 
			pow(total_target_attrition, TOTAL_ATTRITION_EXPONENT_SCALING)
		) * stacks * get_void_escalation(turns_elapsed)
	)

func get_void_damage_to_player(highest_enemy_potency : int, highest_enemy_mastery : int, total_target_attrition : int, stacks : int, turns_elapsed : int) -> int:
	return ceili(
		(
			ENEMY_BASE_DAMAGE +
			ENEMY_POTENCY_COEFFICIENT_SCALING * log(highest_enemy_potency + 1) +
			ENEMY_MASTERY_COEFFICIENT_SCALING * log(highest_enemy_mastery + 1) +
			pow(total_target_attrition, TOTAL_ATTRITION_EXPONENT_SCALING)
		) * stacks * get_void_escalation(turns_elapsed)
	)
