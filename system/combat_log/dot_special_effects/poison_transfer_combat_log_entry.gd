class_name PoisonTransferCombatLogEntry
extends CombatLogEntry

var target : Entity
var poison_instances : Array[DoTInstance]

const BASIC_HEADER_TEMPLATE := "> %s's [color=%s]Poison[/color] Afflictions infected %s"
const DETAIL_TEMPLATE := "\n[ul][color=%s]Poison[/color]: Source: %s, %.2f Base Damage, %d Stacks, %d Turns[/ul]"
const DEVELOPER_DETAIL_TEMPLATE := "\n[ul][color=%s]Poison[/color]: Source = [color=%s]%s[/color], Base Damage = [color=%s]%.2f[/color], Stacks = [color=%s]%d[/color], Duration = [color=%s]%d[/color][/ul]"

func _init(
	p_turn_number : int, 
	p_actor : Entity, 
	p_stage : String, 
	p_target : Entity,
	p_poison_instances : Array[DoTInstance]
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	target = p_target
	poison_instances = p_poison_instances

func render_basic() -> String:
	return BASIC_HEADER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.POISON_COLOR_HEX,
		target.get_entity_name_with_suffix()
	]

func render_advanced() -> String:
	var text := render_basic()
	for poison_instance in poison_instances:
		text += DETAIL_TEMPLATE % [
			DamageAndDoT.POISON_COLOR_HEX,
			poison_instance.source.get_entity_name_with_suffix(),
			poison_instance.base_damage,
			poison_instance.stacks,
			poison_instance.duration
		]
	return text

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += render_basic()
	for poison_instance in poison_instances:
		text += DEVELOPER_DETAIL_TEMPLATE % [
			DamageAndDoT.POISON_COLOR_HEX,
			DamageAndDoT.GENERIC_COLOR_HEX, poison_instance.source.get_entity_name_with_suffix(),
			DamageAndDoT.POISON_COLOR_HEX, poison_instance.base_damage,
			DamageAndDoT.POISON_COLOR_HEX, poison_instance.stacks,
			DamageAndDoT.POISON_COLOR_HEX, poison_instance.duration
		]
	return text
