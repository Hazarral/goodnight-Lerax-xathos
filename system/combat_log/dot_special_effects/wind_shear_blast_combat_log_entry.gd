class_name WindShearBlastCombatLogEntry
extends CombatLogEntry

var targets : Array[Entity]
var effectiveness : float

const BASIC_HEADER_TEMPLATE := "> %s [color=%s]blasted[/color] Wind Sheared targets"
const ADVANCED_HEADER_TEMPLATE := "> %s [color=%s]blasted[/color] Wind Sheared targets (%.2f%% Total Wind Shear Damage)"
const DEVELOPER_HEADER_TEMPLATE := "> %s [color=%s]blasted[/color] Wind Sheared targets, Afflicted count = [color=%s]%d[/color], Effectiveness = [color=%s]%.2f%%[/color]"

const DETAIL_TEMPLATE := "[ul]%s is blasted with [color=%s]Wind[/color][/ul]"

func _init(
	p_turn_number : int, 
	p_actor : Entity, 
	p_stage : String, 
	p_targets : Array[Entity],
	p_effectiveness : float
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	targets = p_targets
	effectiveness = p_effectiveness

func _render_detail() -> String:
	var text := ""
	
	for target in targets:
		text += DETAIL_TEMPLATE % [
			target.get_entity_name_with_suffix(), 
			DamageAndDoT.WIND_COLOR_HEX
		]
	
	return text

func render_basic() -> String:
	return BASIC_HEADER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.WIND_COLOR_HEX
	]

func render_advanced() -> String:
	var text := ADVANCED_HEADER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.WIND_COLOR_HEX,
		effectiveness * 100.0
	]
	text += _render_detail()
	return text

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += DEVELOPER_HEADER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.WIND_COLOR_HEX,
		DamageAndDoT.WIND_COLOR_HEX, targets.size() + 1,
		DamageAndDoT.WIND_COLOR_HEX, effectiveness * 100.0
	]
	text += _render_detail() 
	return text
