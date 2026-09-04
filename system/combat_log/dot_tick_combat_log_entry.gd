class_name DoTTickCombatLogEntry
extends CombatLogEntry

var dot_instance : DoTInstance

const BASIC_TEMPLATE := "[color=%s]> %s[/color] ticked on %s"
const DEVELOPER_TEMPLATE := "[color=%s]> %s[/color] ticked on %s for ([color=%s]%.2f[/color] + [color=%s]%d[/color] + [color=%s]%.2f[/color] + [color=%s]%.2f[/color]) * [color=%s]%d[/color] = [color=%s]%d %s Damage[/color] before mitigation"

func _init(
	p_turn_number : int, 
	p_actor : Entity, 
	p_stage : String, 
	p_dot_instance : DoTInstance,
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	dot_instance = p_dot_instance

func render_basic() -> String:
	var damage_type := dot_instance.damage_type
	var dot_type := DamageAndDoT.get_dot(damage_type)
	return BASIC_TEMPLATE % [
		DamageAndDoT.get_damage_color_hex(damage_type), DamageAndDoT.get_damage_over_time_name(dot_type),
		actor.get_entity_name_with_suffix()
	]

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	
	var damage_type := dot_instance.damage_type
	var dot_type := DamageAndDoT.get_dot(damage_type)
	var coefs : PackedFloat32Array = DamageAndDoT.DOT_COEFFICIENTS.get(dot_type)
	var potency_coef : float = coefs[DamageAndDoT.Coefficient.DAMAGE_POTENCY]
	var mastery_coef : float = coefs[DamageAndDoT.Coefficient.DAMAGE_MASTERY]
	
	text += DEVELOPER_TEMPLATE % [
		DamageAndDoT.get_damage_color_hex(damage_type), DamageAndDoT.get_damage_over_time_name(dot_type),
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.get_damage_color_hex(damage_type), dot_instance.base_damage,
		DamageAndDoT.get_damage_color_hex(damage_type), dot_instance.duration,
		DamageAndDoT.get_damage_color_hex(damage_type), potency_coef * dot_instance.get_current_potency(),
		DamageAndDoT.get_damage_color_hex(damage_type), mastery_coef * dot_instance.get_current_mastery(),
		DamageAndDoT.get_damage_color_hex(damage_type), dot_instance.stacks,
		DamageAndDoT.get_damage_color_hex(damage_type), ceili(dot_instance.calculate_damage()), DamageAndDoT.get_damage_type_name(damage_type)
	]
	
	return text
