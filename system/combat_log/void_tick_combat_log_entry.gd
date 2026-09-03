class_name VoidTickCombatLogEntry
extends CombatLogEntry

var amount : int
var stacks : int
var turns_elapsed : int

## NOTE: only one of these pairs will be populated depending on actor's faction;
## the other stays default/unused, guarded by is_player_faction() in render_developer()
var dragon_max_hp : int
var dragon_total_max_shield : int
var potency : int
var mastery : int
var highest_enemy_potency : int
var highest_enemy_mastery : int
var total_target_attrition : int

const BASIC_TEMPLATE := "> [color=%s]The Primordial Void[/color] gnawed at %s"
const ADVANCED_TEMPLATE := "> [color=%s]The Primordial Void[/color] gnawed at %s (%d Stack%s, %.2f%% Multiplier)"

const DEVELOPER_TEMPLATE_TO_ENEMY := ">> [color=%s]The Primordial Void[/color] gnawed at %s for ([color=%s]%.2f[/color] * [color=%s]%d[/color] + [color=%s]%.2f[/color] * [color=%s]%d[/color] + [color=%s]%.2f[/color] * [color=%s]%d[/color]^[color=%s]%.1f[/color] + [color=%s]%.2f[/color] * [color=%s]%d[/color]^[color=%s]%.1f[/color] + [color=%s]%d[/color]^[color=%s]%.1f[/color]) * [color=%s]%d[/color] * [color=%s]%.2f%%[/color] = [color=%s]%d %s Damage[/color] before mitigation"
const DEVELOPER_TEMPLATE_TO_PLAYER := ">> [color=%s]The Primordial Void[/color] gnawed at %s for ([color=%s]%d[/color] + [color=%s]%.2f[/color] * ln([color=%s]%d[/color] + 1) + [color=%s]%.2f[/color] * ln([color=%s]%d[/color] + 1) + [color=%s]%d[/color]^[color=%s]%.1f[/color]) * [color=%s]%d[/color] * [color=%s]%.2f%%[/color] = [color=%s]%d %s Damage[/color] before mitigation"

func _init(
	p_turn_number : int,
	p_actor : Entity,
	p_stage : String,
	p_amount : int,
	p_stacks : int,
	p_turns_elapsed : int,
	p_total_target_attrition : int,
	p_dragon_max_hp : int = 0,
	p_dragon_total_max_shield : int = 0,
	p_potency : int = 0,
	p_mastery : int = 0,
	p_highest_enemy_potency : int = 0,
	p_highest_enemy_mastery : int = 0,
) -> void:
	super(p_turn_number, p_actor, p_stage)
	amount = p_amount
	stacks = p_stacks
	turns_elapsed = p_turns_elapsed
	total_target_attrition = p_total_target_attrition
	dragon_max_hp = p_dragon_max_hp
	dragon_total_max_shield = p_dragon_total_max_shield
	potency = p_potency
	mastery = p_mastery
	highest_enemy_potency = p_highest_enemy_potency
	highest_enemy_mastery = p_highest_enemy_mastery

func render_basic() -> String:	
	return BASIC_TEMPLATE % [
		DamageAndDoT.VOID_COLOR_HEX,
		actor.get_entity_name_with_suffix()
	]

func render_advanced() -> String:
	return ADVANCED_TEMPLATE % [
		DamageAndDoT.VOID_COLOR_HEX,
		actor.get_entity_name_with_suffix(),
		stacks, "s" if stacks > 1 else "",
		pow(DamageAndDoT.ESCALATION_MULTIPLIER_BASE, turns_elapsed) * 100.0
	]

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	var escalation_percent := pow(DamageAndDoT.ESCALATION_MULTIPLIER_BASE, turns_elapsed) * 100.0
	
	if actor.is_player_faction():
		# NOTE: player takes enemy->player formula
		text += DEVELOPER_TEMPLATE_TO_PLAYER % [
			DamageAndDoT.VOID_COLOR_HEX,
			actor.get_entity_name_with_suffix(),
			DamageAndDoT.GENERIC_COLOR_HEX, DamageAndDoT.ENEMY_BASE_DAMAGE,
			DamageAndDoT.GENERIC_COLOR_HEX, DamageAndDoT.ENEMY_POTENCY_COEFFICIENT_SCALING,
			DamageAndDoT.GENERIC_COLOR_HEX, highest_enemy_potency,
			DamageAndDoT.GENERIC_COLOR_HEX, DamageAndDoT.ENEMY_MASTERY_COEFFICIENT_SCALING,
			DamageAndDoT.GENERIC_COLOR_HEX, highest_enemy_mastery,
			DamageAndDoT.GENERIC_COLOR_HEX, total_target_attrition,
			DamageAndDoT.GENERIC_COLOR_HEX, DamageAndDoT.TOTAL_ATTRITION_EXPONENT_SCALING,
			DamageAndDoT.GENERIC_COLOR_HEX, stacks,
			DamageAndDoT.GENERIC_COLOR_HEX, escalation_percent,
			DamageAndDoT.VOID_COLOR_HEX, amount, DamageAndDoT.get_damage_over_time_name(DamageAndDoT.DoT.VOID)
		]
	else:
		# NOTE: enemy takes player->enemy formula
		text += DEVELOPER_TEMPLATE_TO_ENEMY % [
			DamageAndDoT.VOID_COLOR_HEX,
			actor.get_entity_name_with_suffix(),
			DamageAndDoT.GENERIC_COLOR_HEX, DamageAndDoT.MAX_HP_SCALING,
			DamageAndDoT.GENERIC_COLOR_HEX, dragon_max_hp,
			DamageAndDoT.GENERIC_COLOR_HEX, DamageAndDoT.TOTAL_MAX_SHIELD_SCALING,
			DamageAndDoT.GENERIC_COLOR_HEX, dragon_total_max_shield,
			DamageAndDoT.GENERIC_COLOR_HEX, DamageAndDoT.POTENCY_COEFFICIENT_SCALING,
			DamageAndDoT.GENERIC_COLOR_HEX, potency,
			DamageAndDoT.GENERIC_COLOR_HEX, DamageAndDoT.POTENCY_EXPONENT_SCALING,
			DamageAndDoT.GENERIC_COLOR_HEX, DamageAndDoT.MASTERY_COEFFICIENT_SCALING,
			DamageAndDoT.GENERIC_COLOR_HEX, mastery,
			DamageAndDoT.GENERIC_COLOR_HEX, DamageAndDoT.MASTERY_EXPONENT_SCALING,
			DamageAndDoT.GENERIC_COLOR_HEX, total_target_attrition,
			DamageAndDoT.GENERIC_COLOR_HEX, DamageAndDoT.TOTAL_ATTRITION_EXPONENT_SCALING,
			DamageAndDoT.GENERIC_COLOR_HEX, stacks,
			DamageAndDoT.GENERIC_COLOR_HEX, escalation_percent,
			DamageAndDoT.VOID_COLOR_HEX, amount, DamageAndDoT.get_damage_over_time_name(DamageAndDoT.DoT.VOID)
		]
	
	return text
