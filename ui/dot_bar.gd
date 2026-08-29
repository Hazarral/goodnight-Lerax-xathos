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
const BURN_STAGE_DETAIL := " (x%.1f)"

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
		
		if dot_type == DamageAndDoT.DoT.BURN:
			details_label.text += BURN_STAGE_DETAIL % instance.get_burn_multiplier()
		
		details_label.text += "\n"

func _on_dropdown_button_pressed() -> void:
	# "XOR with 1" trick
	details_label.visible = not details_label.visible
