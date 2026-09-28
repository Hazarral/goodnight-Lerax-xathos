class_name BuffAndDebuffDetail
extends PanelContainer

@onready var name_label := $VBoxContainer/HBoxContainer/Name
@onready var duration_label := $VBoxContainer/HBoxContainer/Duration
@onready var description := $VBoxContainer/Description

var buff_and_debuff : BuffAndDebuff

func _ready() -> void:
	description.visible = false

func setup(p_buff_and_debuff : BuffAndDebuff) -> void:
	buff_and_debuff = p_buff_and_debuff

func render() -> void:
	name_label.text = buff_and_debuff.buff_and_debuff_name
	duration_label.text = DisplayUtility.formatted_permanence(buff_and_debuff.duration, buff_and_debuff.is_permanent)
	
	description.text = ""
	
	_render_health_modifications()
	_render_shield_modifications()
	_render_potency_modifications()
	_render_mastery_modifications()
	_render_final_damage_dealt_modifications()
	_render_final_damage_received_modifications()
	
func _render_health_modifications() -> void:
	if not buff_and_debuff.has_health_modifications():
		return
	
	description.text += DisplayUtility.HEALTH_DESCRIPTION % DisplayUtility.stat_args(
		buff_and_debuff.health_additive,
		buff_and_debuff.health_additive_multiplicative,
		1 + buff_and_debuff.health_true_multiplicative
	)

func _render_shield_modifications() -> void:
	var shield_string_arr := PackedStringArray()
	var add := buff_and_debuff.get_packed_shields_additive()
	var add_mult := buff_and_debuff.get_packed_shields_additive_multiplicative()
	var true_mult := buff_and_debuff.get_packed_shields_true_multiplicative()
	
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		var damage_type := i as DamageAndDoT.DamageType
		if buff_and_debuff.has_shield_modifications(damage_type):
			var stat_args := DisplayUtility.stat_args(
				add[i],
				add_mult[i],
				1 + true_mult[i]
			)
			
			var arg_array := [
				DamageAndDoT.get_damage_color_hex(damage_type), 
				DamageAndDoT.get_damage_type_name(damage_type)
			] + stat_args
			
			shield_string_arr.append(DisplayUtility.INDIVIDUAL_SHIELD_DESCRIPTION % arg_array)
	
	if not shield_string_arr.is_empty():
		description.text += DisplayUtility.SHIELD_HEADER + "".join(shield_string_arr)

func _render_potency_modifications() -> void:
	if not buff_and_debuff.has_potency_modifications():
		return
	
	description.text += DisplayUtility.POTENCY_DESCRIPTION % DisplayUtility.stat_args(
		buff_and_debuff.potency_additive,
		buff_and_debuff.potency_additive_multiplicative,
		1 + buff_and_debuff.potency_true_multiplicative
	)

func _render_mastery_modifications() -> void:
	if not buff_and_debuff.has_mastery_modifications():
		return
	
	description.text += DisplayUtility.MASTERY_DESCRIPTION % DisplayUtility.stat_args(
		buff_and_debuff.mastery_additive,
		buff_and_debuff.mastery_additive_multiplicative,
		1 + buff_and_debuff.mastery_true_multiplicative
	)

func _render_final_damage_dealt_modifications() -> void:
	if not buff_and_debuff.has_final_damage_dealt_modifications():
		return
	
	description.text += DisplayUtility.FINAL_DAMAGE_DEALT_AND_RECEIVED % [
		DisplayUtility.get_color_hex(buff_and_debuff.final_damage_dealt_true_multiplicative, 1.0),
		1 + buff_and_debuff.final_damage_dealt_true_multiplicative
	]

func _render_final_damage_received_modifications() -> void:
	if not buff_and_debuff.has_final_damage_received_modifications():
		return
	
	description.text += DisplayUtility.FINAL_DAMAGE_DEALT_AND_RECEIVED % [
		DisplayUtility.get_color_hex(buff_and_debuff.final_damage_received_true_multiplicative, 1.0),
		1 + buff_and_debuff.final_damage_received_true_multiplicative
	]

func _on_dropdown_button_pressed() -> void:
	description.visible = not description.visible
