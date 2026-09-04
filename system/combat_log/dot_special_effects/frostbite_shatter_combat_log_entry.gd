class_name FrostbiteShatterCombatLogEntry
extends CombatLogEntry

var damage_type : DamageAndDoT.DamageType

const BASIC_TEMPLATE := "> %s's [color=%s]%s Shield[/color] [color=%s]shattered[/color]!"

func _init(
	p_turn_number : int,
	p_actor : Entity,
	p_stage : String,
	p_damage_type : DamageAndDoT.DamageType
) -> void:
	super(p_turn_number, p_actor, p_stage)
	damage_type = p_damage_type

func render_basic() -> String:	
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.get_damage_color_hex(damage_type), DamageAndDoT.get_damage_type_name(damage_type),
		DamageAndDoT.ICE_COLOR_HEX
	]

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += render_basic()
	return text
