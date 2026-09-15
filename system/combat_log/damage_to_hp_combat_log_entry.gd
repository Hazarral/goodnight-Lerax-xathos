class_name DamageToHPCombatLogEntry
extends CombatLogEntry

var current_hp_before : int
var current_hp_after : int

var damage_type : DamageAndDoT.DamageType
var amount : int
var ignore_shield : bool

var shield_state : EntityInfoCard.ShieldState

const BASIC_TEMPLATE := "> %s received [color=%s]%d %s Damage[/color] to Health"

const ADVANCED_IGNORE_SHIELD_EXTRA_TEMPLATE := " directly, ignoring all Shields"

const DEVELOPER_TEMPLATE := "> %s received [color=%s]%d %s Damage[/color] to Health, ignore_shield = [color=%s]%s[/color]"

func _init(
	p_turn_number : int, 
	p_actor : Entity, 
	p_stage : String, 
	p_current_hp_before : int,
	p_current_hp_after : int,
	p_damage_type : DamageAndDoT.DamageType,
	p_amount : int,
	 p_ignore_shield : bool
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	current_hp_before = p_current_hp_before
	current_hp_after = p_current_hp_after
	damage_type = p_damage_type
	amount = p_amount
	ignore_shield = p_ignore_shield
	
	shield_state = EntityInfoCard.get_shield_state(actor)

func render_basic() -> String:
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.get_damage_color_hex(damage_type), amount, DamageAndDoT.get_damage_type_name(damage_type)
	]

func render_advanced() -> String:
	var text := render_basic()
	
	if ignore_shield:
		text += ADVANCED_IGNORE_SHIELD_EXTRA_TEMPLATE
	
	return text

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += DEVELOPER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.get_damage_color_hex(damage_type), amount, DamageAndDoT.get_damage_type_name(damage_type),
		DamageAndDoT.GENERIC_COLOR_HEX, ignore_shield
	]
	
	return text

func execute_visuals() -> void:
	if CombatLog.entity_info_card_registry.has(actor):
		var card := CombatLog.entity_info_card_registry[actor]
		var tween_time := GlobalSettings.ui_playback_delay

		card.tween_hp(current_hp_after, shield_state, tween_time)
