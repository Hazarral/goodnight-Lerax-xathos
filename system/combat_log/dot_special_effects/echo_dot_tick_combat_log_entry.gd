class_name EchoDoTTickCombatLogEntry
extends CombatLogEntry

var dot_instance : DoTInstance
var effectiveness : float
var amount : int

const BASIC_TEMPLATE := "[color=%s]> %s[/color] [color=%s]echoed[/color] on %s"
const DEVELOPER_TEMPLATE := "[color=%s]> %s[/color] [color=%s]echoed[/color] on %s at [color=%s]%.2f%% Effectiveness[/color]"

func _init(
	p_turn_number : int, 
	p_actor : Entity, 
	p_stage : String, 
	p_dot_instance : DoTInstance,
	p_effectiveness : float,
	p_amount : int
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	dot_instance = p_dot_instance
	effectiveness = p_effectiveness
	amount = p_amount

func render_basic() -> String:
	var damage_type := dot_instance.damage_type
	var dot_type := DamageAndDoT.get_dot(damage_type)
	return BASIC_TEMPLATE % [
		DamageAndDoT.get_damage_color_hex(damage_type), DamageAndDoT.get_damage_over_time_name(dot_type),
		DamageAndDoT.WATER_COLOR_HEX,
		actor.get_entity_name_with_suffix()
	]

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	
	var damage_type := dot_instance.damage_type
	var dot_type := DamageAndDoT.get_dot(damage_type)
	
	text += DEVELOPER_TEMPLATE % [
		DamageAndDoT.get_damage_color_hex(damage_type), DamageAndDoT.get_damage_over_time_name(dot_type),
		DamageAndDoT.WATER_COLOR_HEX,
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.WATER_COLOR_HEX, effectiveness * 100.0
	]
	
	return text
