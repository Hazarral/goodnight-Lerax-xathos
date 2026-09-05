class_name ShockConvulsionCombatLogEntry
extends CombatLogEntry

var ap_spent : int
var effectiveness_per_ap : float

const BASIC_TEMPLATE := "> %s [color=%s]convulsed[/color] on action!"
const ADVANCED_TEMPLATE := "> %s [color=%s]convulsed[/color] on action, bursting for [color=%s]%.2f%% %s Damage![/color]"
const DEVELOPER_TEMPLATE := "> %s [color=%s]convulsed[/color] on action, AP Spent = [color=%s]%d[/color], Effectiveness per AP = [color=%s]%.2f%%[/color], Final Effectiveness = [color=%s]%.2f%%[/color]"

func _init(
	p_turn_number : int, 
	p_actor : Entity, 
	p_stage : String, 
	p_ap_spent : int,
	p_effectiveness_per_ap : float
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	ap_spent = p_ap_spent
	effectiveness_per_ap = p_effectiveness_per_ap

func render_basic() -> String:	
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.LIGHTNING_COLOR_HEX
	]

func render_advanced() -> String:
	var final_effectiveness := effectiveness_per_ap * minf(DamageAndDoT.SHOCK_MAX_AP_SCALING, ap_spent) * 100.0
	return ADVANCED_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.LIGHTNING_COLOR_HEX,
		DamageAndDoT.LIGHTNING_COLOR_HEX, final_effectiveness, DamageAndDoT.SHOCK
	]

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	var final_effectiveness := effectiveness_per_ap * minf(DamageAndDoT.SHOCK_MAX_AP_SCALING, ap_spent) * 100.0
	
	text += DEVELOPER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.LIGHTNING_COLOR_HEX,
		DamageAndDoT.GENERIC_COLOR_HEX, ap_spent,
		DamageAndDoT.LIGHTNING_COLOR_HEX, effectiveness_per_ap * 100.0,
		DamageAndDoT.LIGHTNING_COLOR_HEX, final_effectiveness
	]
	return text
