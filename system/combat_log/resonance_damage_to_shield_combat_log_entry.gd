class_name ResonanceDamageToShieldCombatLogEntry
extends CombatLogEntry

var damage_type : DamageAndDoT.DamageType
var amount : int

const BASIC_TEMPLATE := "> Resonance! %s's [color=%s]%s Shield[/color] received [color=%s]%d %s Damage[/color]"

func _init(
	p_turn_number : int, 
	p_actor : Entity, 
	p_stage : String, 
	p_damage_type : DamageAndDoT.DamageType,
	p_amount : int,
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	damage_type = p_damage_type
	amount = p_amount

func render_basic() -> String:
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.get_damage_color_hex(damage_type), DamageAndDoT.get_damage_type_name(damage_type),
		DamageAndDoT.get_damage_color_hex(damage_type), amount, DamageAndDoT.get_damage_type_name(damage_type),
	]

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += render_basic()
	return text

func execute_visuals() -> void:
	if CombatLog.entity_info_card_registry.has(actor):
		var card := CombatLog.entity_info_card_registry[actor]
		card.sync_shield_state()
