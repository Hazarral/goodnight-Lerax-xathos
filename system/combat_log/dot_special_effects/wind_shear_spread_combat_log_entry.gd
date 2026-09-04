class_name WindShearSpreadCombatLogEntry
extends CombatLogEntry

var damage_types : Array[DamageAndDoT.DamageType]
var targets : Array[Entity]
var effectiveness : float

const BASIC_HEADER_TEMPLATE := "> Non-Wind-Shear Afflictions are [color=%s]spread[/color]"
const ADVANCED_HEADER_TEMPLATE := "> Non-Wind-Shear Afflictions are [color=%s]spread[/color] (%d Wind Sheared Targets, %.2f%% Effectiveness)"
const DEVELOPER_HEADER_TEMPLATE := "> Non-Wind-Shear Afflictions are [color=%s]spread[/color], Elements spread = [color=%s]%d[/color], Afflicted count = [color=%s]%d[/color], Effectiveness = [color=%s]%.2f%%[/color]"

const DETAIL_TEMPLATE := "\n[ul][color=%s]%s[/color] spread to %s[/ul]"

func _init(
	p_turn_number : int, 
	p_actor : Entity, 
	p_stage : String, 
	p_damage_types : Array[DamageAndDoT.DamageType],
	p_targets : Array[Entity],
	p_effectiveness : float
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	damage_types = p_damage_types
	targets = p_targets
	effectiveness = p_effectiveness

func _render_detail() -> String:
	var text := ""
	
	for damage_type in damage_types:
		var dot_type := DamageAndDoT.get_dot(damage_type)
		for target in targets:
			text += DETAIL_TEMPLATE % [
				DamageAndDoT.get_damage_color_hex(damage_type), DamageAndDoT.get_damage_over_time_name(dot_type),
				target.get_entity_name_with_suffix()
			]
	
	return text

func render_basic() -> String:
	var text := BASIC_HEADER_TEMPLATE % [
		DamageAndDoT.WIND_COLOR_HEX
	]
	text += _render_detail()
	return text

func render_advanced() -> String:
	var text := ADVANCED_HEADER_TEMPLATE % [
		DamageAndDoT.WIND_COLOR_HEX,
		targets.size(),
		effectiveness * 100.0
	]
	text += _render_detail()
	return text

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += DEVELOPER_HEADER_TEMPLATE % [
		DamageAndDoT.WIND_COLOR_HEX,
		DamageAndDoT.GENERIC_COLOR_HEX, damage_types.size(),
		DamageAndDoT.WIND_COLOR_HEX, targets.size() + 1,
		DamageAndDoT.WIND_COLOR_HEX, effectiveness * 100.0
	]
	text += _render_detail()
	return text
