class_name CascadeDamageToShieldCombatLogEntry
extends CombatLogEntry

var damage_type : DamageAndDoT.DamageType
var total_amount : int
var damage_to_shields : PackedInt64Array

const BASIC_HEADER_TEMPLATE := "> Wrong Element! %s's [color=%s]%s Shield[/color] received a total of [color=%s]%d %s Damage[/color]"
const BASIC_SHIELD_DAMAGE_TEMPLATE := "> [color=%s]%s Shield[/color] received [color=%s]%d %s Damage[/color]"

const ADVANCED_HEADER_TEMPLATE := "> Wrong Element! %s's [color=%s]%s Shield[/color] received %d%% less damage for a total of [color=%s]%d %s Damage[/color]"
const ADVANCED_SHIELD_DAMAGE_TEMPLATE := "> %s's [color=%s]%s Shield[/color] received [color=%s]%d %s Damage[/color] (Penalized)"

const DEVELOPER_HEADER_TEMPLATE := "> Wrong Element! %s's [color=%s]%s Shield[/color] received penalized damage for a total of [color=%s]%d %s Damage[/color], Cost Multiplier = %.2f"

func _init(
	p_turn_number : int, 
	p_actor : Entity, 
	p_stage : String, 
	p_damage_type : DamageAndDoT.DamageType,
	p_total_amount : int,
	p_damage_to_shields : PackedInt64Array
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	damage_type = p_damage_type
	total_amount = p_total_amount
	damage_to_shields = p_damage_to_shields

func render_basic() -> String:
	var text := BASIC_HEADER_TEMPLATE % [
		actor.template.entity_name,
		DamageAndDoT.get_damage_color_hex(damage_type),
		DamageAndDoT.get_damage_type_name(damage_type),
		DamageAndDoT.get_damage_color_hex(damage_type),
		total_amount,
		DamageAndDoT.get_damage_type_name(damage_type),
	]
	
	text += BASIC_SHIELD_DAMAGE_TEMPLATE % [
		
	]

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := STAGE_TEMPLATE % [DamageAndDoT.GENERIC_COLOR_HEX, stage, turn_number] + "\n"
	text += render_basic()
	return text
