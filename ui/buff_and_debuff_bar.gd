class_name BuffAndDebuffBar
extends PanelContainer

@onready var summary_description := $VBoxContainer/SummaryDescription
@onready var dropdown_button := $VBoxContainer/HBoxContainer/DropdownButton

const BUFF_COLOR := "#18F553"
const NEUTRAL_COLOR := "#E8E2D4"
const DEBUFF_COLOR := "#DE2410"

var entity : Entity
const HEALTH_DESCRIPTION := "> Health: [color=%s]%s%.2f[/color], [color=%s]%s%.2f%%[/color], [color=%s]x%.2f[/color]\n"
const SHIELD_DESCRIPTION := """> Shields: 
[ul][color=%s]Fire[/color]: [color=%s]%s%.2f[/color], [color=%s]%s%.2f%%[/color], [color=%s]x%.2f[/color]
[color=%s]Water[/color]: [color=%s]%s%.2f[/color], [color=%s]%s%.2f%%[/color], [color=%s]x%.2f[/color]
[color=%s]Wind[/color]: [color=%s]%s%.2f[/color], [color=%s]%s%.2f%%[/color], [color=%s]x%.2f[/color]
[color=%s]Poison[/color]: [color=%s]%s%.2f[/color], [color=%s]%s%.2f%%[/color], [color=%s]x%.2f[/color]
[color=%s]Lightning[/color]: [color=%s]%s%.2f[/color], [color=%s]%s%.2f%%[/color], [color=%s]x%.2f[/color]
[color=%s]Physical[/color]: [color=%s]%s%.2f[/color], [color=%s]%s%.2f%%[/color], [color=%s]x%.2f[/color]
[color=%s]Earth[/color]: [color=%s]%s%.2f[/color], [color=%s]%s%.2f%%[/color], [color=%s]x%.2f[/color]
[color=%s]Ice[/color]: [color=%s]%s%.2f[/color], [color=%s]%s%.2f%%[/color], [color=%s]x%.2f[/color][/ul]\n"""
const POTENCY_DESCRIPTION := "> Potency: [color=%s]%s%.2f[/color], [color=%s]%s%.2f%%[/color], [color=%s]x%.2f[/color]\n"
const MASTERY_DESCRIPTION := "> Mastery: [color=%s]%s%.2f[/color], [color=%s]%s%.2f%%[/color], [color=%s]x%.2f[/color]\n"
const FINAL_DAMAGE_DEALT_AND_RECEIVED := "> Final Damage Dealt/Received: [color=%s]x%.2f[/color] / [color=%s]x%.2f[/color]\n"

const FIELD_PER_SHIELD := 3

static func get_color_hex(current_val : float, base_val : float) -> String:
	if current_val > base_val:
		return BUFF_COLOR
	
	if abs(current_val - base_val) < 1e-4:
		return NEUTRAL_COLOR
	
	return DEBUFF_COLOR

func _ready() -> void:
	summary_description.visible = false

func setup(p_entity : Entity) -> void:
	entity = p_entity

func render() -> void:
	summary_description.text = ""
	
	var summary := entity.get_buff_and_debuff_summary()
	
	summary_description.text += HEALTH_DESCRIPTION % _stat_args(
		summary.health_additive,
		summary.health_additive_multiplicative,
		summary.health_true_multiplicative
	)
	
	## Precisely String and Float
	var shield_args : Array[Variant] = []
	for i in DamageAndDoT.ELEMENT_COUNT:
		var stat_args := _stat_args(
			summary.shields_additive[i],
			summary.shields_additive_multiplicative[i],
			summary.shields_true_multiplicative[i]
		)
		
		shield_args.append_array(
			[DamageAndDoT.get_damage_color_hex(i as DamageAndDoT.DamageType)] + stat_args
		)
	
	summary_description.text += SHIELD_DESCRIPTION % shield_args
	
	summary_description.text += POTENCY_DESCRIPTION % _stat_args(
		summary.potency_additive,
		summary.potency_additive_multiplicative,
		summary.potency_true_multiplicative
	)
	
	summary_description.text += MASTERY_DESCRIPTION % _stat_args(
		summary.mastery_additive,
		summary.mastery_additive_multiplicative,
		summary.mastery_true_multiplicative
	)
	
	summary_description.text += FINAL_DAMAGE_DEALT_AND_RECEIVED % [
		get_color_hex(summary.final_damage_dealt_true_multiplicative, 1.0),
		summary.final_damage_dealt_true_multiplicative,
		get_color_hex(summary.final_damage_received_true_multiplicative, 1.0),
		summary.final_damage_received_true_multiplicative
	]
	
func _stat_args(additive : float, additive_multiplicative : float, true_multiplicative : float) -> Array[Variant]:
	return [
		get_color_hex(additive, 0.0), _sign(additive), additive,
		get_color_hex(additive_multiplicative, 0.0), _sign(additive_multiplicative), additive_multiplicative * 100.0,
		get_color_hex(true_multiplicative, 1.0), true_multiplicative
	]

func _sign(value : float) -> String:
	## Returns "+" for non-negative values; negative values print their own "-" via %.2f
	return "+" if value >= 0.0 else ""

func _on_dropdown_button_pressed() -> void:
	summary_description.visible = not summary_description.visible
