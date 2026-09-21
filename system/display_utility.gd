extends Node

## General
const FINITE_DURATION_TEXT := "%d Turn%s"
const PERMANENT_DURATION_TEXT := "Permanent"

const BUFF_COLOR := "#18F553"
const NEUTRAL_COLOR := "#E8E2D4"
const DEBUFF_COLOR := "#DE2410"

const HEALTH_DESCRIPTION := "> Health: [color=%s]%s%s[/color], [color=%s]%s%s%%[/color], [color=%s]x%s[/color]\n"
const SHIELD_DESCRIPTION := """> Shields: 
[ul][color=%s]Fire[/color]: [color=%s]%s%s[/color], [color=%s]%s%s%%[/color], [color=%s]x%s[/color]
[color=%s]Water[/color]: [color=%s]%s%s[/color], [color=%s]%s%s%%[/color], [color=%s]x%s[/color]
[color=%s]Wind[/color]: [color=%s]%s%s[/color], [color=%s]%s%s%%[/color], [color=%s]x%s[/color]
[color=%s]Poison[/color]: [color=%s]%s%s[/color], [color=%s]%s%s%%[/color], [color=%s]x%s[/color]
[color=%s]Lightning[/color]: [color=%s]%s%s[/color], [color=%s]%s%s%%[/color], [color=%s]x%s[/color]
[color=%s]Physical[/color]: [color=%s]%s%s[/color], [color=%s]%s%s%%[/color], [color=%s]x%s[/color]
[color=%s]Earth[/color]: [color=%s]%s%s[/color], [color=%s]%s%s%%[/color], [color=%s]x%s[/color]
[color=%s]Ice[/color]: [color=%s]%s%s[/color], [color=%s]%s%s%%[/color], [color=%s]x%s[/color][/ul]\n"""
const POTENCY_DESCRIPTION := "> Potency: [color=%s]%s%s[/color], [color=%s]%s%s%%[/color], [color=%s]x%s[/color]\n"
const MASTERY_DESCRIPTION := "> Mastery: [color=%s]%s%s[/color], [color=%s]%s%s%%[/color], [color=%s]x%s[/color]\n"
const FINAL_DAMAGE_DEALT_AND_RECEIVED := "> Final Damage Dealt/Received: [color=%s]x%s[/color] / [color=%s]x%s[/color]\n"

## Buff and debuff details
const SHIELD_HEADER := "> Shields:\n"
const INDIVIDUAL_SHIELD_DESCRIPTION := "[ul][color=%s]%s[/color]: [color=%s]%s%s[/color], [color=%s]%s%s%%[/color], [color=%s]x%s[/color][/ul]\n"
const FINAL_DAMAGE_DEALT := "> Final Damage Dealt: [color=%s]x%s[/color]"
const FINAL_DAMAGE_RECEIVED := "> Final Damage Received: [color=%s]x%s[/color]"

func get_color_hex(current_val : float, base_val : float) -> String:
	if current_val > base_val:
		return BUFF_COLOR
	
	if abs(current_val - base_val) < 1e-4:
		return NEUTRAL_COLOR
	
	return DEBUFF_COLOR

func display_sign(value : float) -> String:
	## Returns "+" for non-negative values; negative values print their own "-" via %.2f
	return "+" if value >= 0.0 else ""

func stat_args(additive : float, additive_multiplicative : float, true_multiplicative : float) -> Array[Variant]:
	return [
		get_color_hex(additive, 0.0), display_sign(additive), formatted_val(additive),
		get_color_hex(additive_multiplicative, 0.0), display_sign(additive_multiplicative), formatted_val(additive_multiplicative * 100.0),
		get_color_hex(true_multiplicative, 1.0), formatted_val(true_multiplicative)
	]

func formatted_val(value : float) -> String:
	if GlobalSettings.buff_and_debuff_display_fixed_precision:
		return ("%.%df" % GlobalSettings.buff_and_debuff_display_precision) % value
	
	return String.num(value, GlobalSettings.buff_and_debuff_display_precision)

func clear_children(container_list : Array[Node]) -> void:
	for container in container_list:
		for child in container.get_children():
			child.queue_free()

func formatted_permanence(duration : int, is_permanent : bool) -> String:
	if is_permanent:
		return DisplayUtility.PERMANENT_DURATION_TEXT
	
	return DisplayUtility.FINITE_DURATION_TEXT % [
		duration,
		"s" if duration != 1 else ""
	]
