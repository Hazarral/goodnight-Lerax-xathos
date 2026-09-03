class_name CascadeDamageToShieldCombatLogEntry
extends CombatLogEntry

var damage_type : DamageAndDoT.DamageType
var total_amount : int
var damage_to_shields : PackedInt64Array

const WRONG_DAMAGE_PREFIX := "> Wrong ELement! "
const VOID_DAMAGE_PREFIX := "> Void Damage! "

const NO_SHIELD_DAMAGE := "> %s has no [color=%s]%s Shield[/color]!"
const BASIC_HEADER_TEMPLATE := "%s's Shields received a total of [color=%s]%d %s Damage[/color]"
const BASIC_SHIELD_DAMAGE_TEMPLATE := ">> [color=%s]%s Shield[/color] received [color=%s]%d %s Damage[/color]"

const ADVANCED_HEADER_TEMPLATE := "%s's Shields received [color=%s]%.2f%%[/color] damage for a total of [color=%s]%d %s Damage[/color]"

const DEVELOPER_HEADER_TEMPLATE := "%s's Shields received [color=%s]%.2f%%[/color] damage for a total of [color=%s]%d %s Damage[/color], Cost Multiplier = %.2f"

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

func _is_void_damage() -> bool:
	return damage_type == DamageAndDoT.DamageType.VOID

func _get_damage_multiplier() -> float:
	if _is_void_damage():
		return DamageAndDoT.VOID_MULTIPLIER_AGAINST_SHIELD
	
	return DamageAndDoT.PENALIZED_MULTIPLIER_AGAINST_SHIELD

func _get_damage_effectiveness() -> float:
	return 100.0 / _get_damage_multiplier()

func _get_no_shield_text() -> String:
	return NO_SHIELD_DAMAGE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.get_damage_color_hex(damage_type), DamageAndDoT.get_damage_type_name(damage_type)
	]

func render_basic() -> String:
	if total_amount <= 0:
		return _get_no_shield_text()
	
	var text := VOID_DAMAGE_PREFIX if _is_void_damage() else WRONG_DAMAGE_PREFIX
	
	text += BASIC_HEADER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.get_damage_color_hex(damage_type),
		total_amount,
		DamageAndDoT.get_damage_type_name(damage_type)
	] + "\n"
	
	for i in range(damage_to_shields.size()):
		if damage_to_shields[i] <= 0:
			continue
			
		var shield_type := i as DamageAndDoT.DamageType
		text += BASIC_SHIELD_DAMAGE_TEMPLATE % [
			DamageAndDoT.get_damage_color_hex(shield_type),
			DamageAndDoT.get_damage_type_name(shield_type),
			DamageAndDoT.get_damage_color_hex(damage_type),
			damage_to_shields[i],
			DamageAndDoT.get_damage_type_name(damage_type)
		] + "\n"
	
	return text.trim_suffix("\n")

func render_advanced() -> String:
	if total_amount <= 0:
		return _get_no_shield_text()
	
	var text := VOID_DAMAGE_PREFIX if _is_void_damage() else WRONG_DAMAGE_PREFIX
	
	text += ADVANCED_HEADER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.GENERIC_COLOR_HEX,
		_get_damage_effectiveness(),
		DamageAndDoT.get_damage_color_hex(damage_type),
		total_amount,
		DamageAndDoT.get_damage_type_name(damage_type)
	] + "\n"
	
	for i in range(damage_to_shields.size()):
		if damage_to_shields[i] <= 0:
			continue
		
		var shield_type := i as DamageAndDoT.DamageType
		text += BASIC_SHIELD_DAMAGE_TEMPLATE % [
			DamageAndDoT.get_damage_color_hex(shield_type),
			DamageAndDoT.get_damage_type_name(shield_type),
			DamageAndDoT.get_damage_color_hex(damage_type),
			damage_to_shields[i],
			DamageAndDoT.get_damage_type_name(damage_type)
		] + "\n"
	
	return text.trim_suffix("\n")

func render_developer() -> String:
	var text := VOID_DAMAGE_PREFIX if _is_void_damage() else WRONG_DAMAGE_PREFIX
	text += STAGE_TEMPLATE % [DamageAndDoT.GENERIC_COLOR_HEX, stage, turn_number] + "\n"
	if total_amount <= 0:
		return text + _get_no_shield_text()
	
	text += DEVELOPER_HEADER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.GENERIC_COLOR_HEX,
		_get_damage_effectiveness(),
		DamageAndDoT.get_damage_color_hex(damage_type),
		total_amount,
		DamageAndDoT.get_damage_type_name(damage_type),
		_get_damage_multiplier()
	] + "\n"
	
	for i in range(damage_to_shields.size()):
		var shield_type := i as DamageAndDoT.DamageType
		text += BASIC_SHIELD_DAMAGE_TEMPLATE % [
			DamageAndDoT.get_damage_color_hex(shield_type),
			DamageAndDoT.get_damage_type_name(shield_type),
			DamageAndDoT.get_damage_color_hex(damage_type),
			damage_to_shields[i],
			DamageAndDoT.get_damage_type_name(damage_type),
		] + "\n"
	
	return text.trim_suffix("\n")
