class_name BuffAndDebuffBar
extends PanelContainer

@onready var summary_description := $VBoxContainer/SummaryDescription
@onready var dropdown_button := $VBoxContainer/HBoxContainer/DropdownButton
@onready var detail_dropdown_button := $VBoxContainer/DetailDropdownButton
@onready var detail_list := $VBoxContainer/DetailList

const BUFF_AND_DEBUFF_DETAIL := preload("res://ui/buff_and_debuff_detail.tscn")

var entity : Entity

const FIELD_PER_SHIELD := 3

func _ready() -> void:
	summary_description.visible = false
	detail_dropdown_button.visible = false
	detail_list.visible = false

func setup(p_entity : Entity) -> void:
	entity = p_entity

func render() -> void:
	summary_description.text = ""
	
	var summary := entity.get_buff_and_debuff_summary()
	
	summary_description.text += DisplayUtility.HEALTH_DESCRIPTION % DisplayUtility.stat_args(
		summary.health_additive,
		summary.health_additive_multiplicative,
		summary.health_true_multiplicative
	)
	
	## Precisely String and Float
	var shield_args : Array[Variant] = []
	for i in DamageAndDoT.ELEMENT_COUNT:
		var stat_args := DisplayUtility.stat_args(
			summary.shields_additive[i],
			summary.shields_additive_multiplicative[i],
			summary.shields_true_multiplicative[i]
		)
		
		shield_args.append_array(
			[DamageAndDoT.get_damage_color_hex(i as DamageAndDoT.DamageType)] + stat_args
		)
	
	summary_description.text += DisplayUtility.SHIELD_DESCRIPTION % shield_args
	
	summary_description.text += DisplayUtility.POTENCY_DESCRIPTION % DisplayUtility.stat_args(
		summary.potency_additive,
		summary.potency_additive_multiplicative,
		summary.potency_true_multiplicative
	)
	
	summary_description.text += DisplayUtility.MASTERY_DESCRIPTION % DisplayUtility.stat_args(
		summary.mastery_additive,
		summary.mastery_additive_multiplicative,
		summary.mastery_true_multiplicative
	)
	
	summary_description.text += DisplayUtility.FINAL_DAMAGE_DEALT_AND_RECEIVED % [
		DisplayUtility.get_color_hex(summary.final_damage_dealt_true_multiplicative, 1.0),
		summary.final_damage_dealt_true_multiplicative,
		DisplayUtility.get_color_hex(summary.final_damage_received_true_multiplicative, 1.0),
		summary.final_damage_received_true_multiplicative
	]
	
	_populate_buff_and_debuff_details()

func _on_dropdown_button_pressed() -> void:
	summary_description.visible = not summary_description.visible
	detail_dropdown_button.visible = not detail_dropdown_button.visible

func _on_detail_dropdown_button_pressed() -> void:
	detail_list.visible = not detail_list.visible

func _populate_buff_and_debuff_details() -> void:
	DisplayUtility.clear_children([detail_list])
	var all_buff_and_debuffs := entity.get_all_buff_and_debuffs()
	
	for buff_and_debuff in all_buff_and_debuffs:
		var detail_bar := BUFF_AND_DEBUFF_DETAIL.instantiate()
		detail_list.add_child(detail_bar)
		detail_bar.setup(buff_and_debuff)
		detail_bar.render()
