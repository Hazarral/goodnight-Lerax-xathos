class_name StatusEffectBar
extends PanelContainer

@onready var status_name_label := $VBoxContainer/HBoxContainer/StatusName
@onready var duration_label := $VBoxContainer/HBoxContainer/Duration
@onready var description_label := $VBoxContainer/Description

var status_effect : StatusEffect

const STATUS_NAME_TEXT := "[color=%s]%s[/color]"

func setup(p_status_effect : StatusEffect) -> void:
	status_effect = p_status_effect

func render() -> void:
	status_name_label.text = STATUS_NAME_TEXT % [DamageAndDoT.GENERIC_COLOR_HEX, status_effect.get_effect_name()]
	
	duration_label.text = DisplayUtility.formatted_permanence(status_effect.duration, status_effect.is_permanent)
	
	description_label.text = status_effect.get_description()
