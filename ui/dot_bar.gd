class_name DoTBar
extends PanelContainer

@onready var dropdown_button := $VBoxContainer/HBoxContainer/Button
@onready var dot_header := $VBoxContainer/HBoxContainer/DoTHeader
@onready var details_label := $VBoxContainer/Details

var entity : Entity
var dot_instance_array : DoTInstanceArray

const HEADER_TEXT_FRONT := "[color=%s]%s[/color]"
const SHIELD_PRESENT_TEXT_PART := " -> [color=%s]%s Shield[/color]"
const HEADER_TEXT_BACK := ", %d Damage, %d Attrition, %d Turn%s left"

## DoT Specific details
const BURN_STAGE_DETAIL := " (x%.1f)"
const CURRENT_ECHO_EFFECTIVENESS_DETAIL := " (%.2f%% Echo)"
const WIND_SHEAR_SPREAD_EFFECTIVENESS_DETAIL := " (%.2f%% Spread)"
const WIND_SHEAR_BLAST_TARGET_COUNT_DETAIL := " (%.2f%% Blast)"
const POISON_EXPLOSION_EFFECTIVENESS_DETAIL := " (%.2f%% Total Attrition Bomb on Death)"
const SHOCK_EFFECTIVENESS_DETAIL := " (%.2f%% per AP)"
const BLEED_HEALING_REDUCTION_EFFECTIVENESS_DETAIL := " (%.2f%% Healing reduced, "
const BLEED_ANTI_HEAL_DAMAGE_DETAIL := "%.2f%% + %d damage on heal)"
const CRUMBLE_SPLASH_EFFECTIVENESS_DETAIL := " (%.2f%% Shield Splash)"
const FROSTBITE_DETAIL:= " (Prone to Shield Break)"

const DETAIL_LINE_TEXT := "> %s, %.2f Base Damage, %.2f Attrition, %d Stack%s, %d Turn%s"


func setup(p_entity : Entity, p_dot_instance_array : DoTInstanceArray) -> void:
	entity = p_entity
	dot_instance_array = p_dot_instance_array
	details_label.visible = false

func render() -> void:	
	var dot_type := dot_instance_array.get_dot_type()
	var damage_type := DamageAndDoT.get_damage_type(dot_type)
	dot_header.text = HEADER_TEXT_FRONT % [
		DamageAndDoT.get_damage_color_hex(damage_type),
		DamageAndDoT.get_damage_over_time_name(dot_type)
	]
	if entity.has_shield(damage_type):
		dot_header.text += SHIELD_PRESENT_TEXT_PART % [
			DamageAndDoT.get_damage_color_hex(damage_type),
			DamageAndDoT.get_damage_type_name(damage_type)
		]
	
	var highest_duration := dot_instance_array.get_highest_duration()
	dot_header.text += HEADER_TEXT_BACK % [
		ceili(dot_instance_array.calculate_total_damage()),
		ceili(dot_instance_array.calculate_total_attrition()),
		highest_duration,
		"s" if highest_duration != 1 else ""
	]
	
	_add_special_effect_detail_to_header(dot_instance_array)
	
	details_label.text = ""
	for instance in dot_instance_array.data:
		details_label.text += DETAIL_LINE_TEXT % [
			instance.source.template.entity_name,
			instance.base_damage,
			instance.calculate_attrition(),
			instance.stacks,
			"s" if instance.stacks != 1 else "",
			instance.duration,
			"s" if instance.duration != 1 else ""
		]
		
		if instance is BurnInstance:
			details_label.text += BURN_STAGE_DETAIL % instance.get_burn_multiplier()
		
		
		details_label.text += "\n"

func _add_special_effect_detail_to_header(instance_array : DoTInstanceArray) -> void:
	var dot_type := instance_array.get_dot_type()
	var highest_potency := instance_array.get_highest_potency()
	var highest_mastery := instance_array.get_highest_mastery()
	var all_stacks_count := instance_array.get_all_stacks_count()
	var bonus_text := ""
	match dot_type:
		DamageAndDoT.DoT.BURN:
			pass
		DamageAndDoT.DoT.CURRENT:
			bonus_text = CURRENT_ECHO_EFFECTIVENESS_DETAIL % DamageAndDoT.get_current_echo_effectiveness(highest_mastery, true)
		DamageAndDoT.DoT.WIND_SHEAR:
			var afflicted_count := DamageAndDoT.get_wind_shear_special_effect_targets(entity, entity.is_player_faction()).size() + 1
			bonus_text = WIND_SHEAR_SPREAD_EFFECTIVENESS_DETAIL % DamageAndDoT.get_wind_shear_spread_effectiveess(highest_mastery, true)
			bonus_text += WIND_SHEAR_BLAST_TARGET_COUNT_DETAIL % (afflicted_count * 100.0)
		DamageAndDoT.DoT.POISON:
			pass
		DamageAndDoT.DoT.SHOCK:
			pass
		DamageAndDoT.DoT.BLEED:
			var healing_reduction_percent := DamageAndDoT.get_bleed_healing_reduction(highest_mastery, true)
			bonus_text = BLEED_HEALING_REDUCTION_EFFECTIVENESS_DETAIL % minf(100.0, healing_reduction_percent)
			bonus_text += BLEED_ANTI_HEAL_DAMAGE_DETAIL % [
				healing_reduction_percent,
				DamageAndDoT.get_bleed_anti_heal_flat_damage_bonus(highest_potency, all_stacks_count)
			]
		DamageAndDoT.DoT.CRUMBLE:
			bonus_text = CRUMBLE_SPLASH_EFFECTIVENESS_DETAIL % DamageAndDoT.get_crumble_splash_effectiveness(highest_potency, true)
		DamageAndDoT.DoT.FROSTBITE:
			bonus_text = FROSTBITE_DETAIL
	
	dot_header.text += bonus_text

func _on_dropdown_button_pressed() -> void:
	# "XOR with 1" trick
	details_label.visible = not details_label.visible
