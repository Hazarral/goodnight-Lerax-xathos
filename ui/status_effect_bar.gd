class_name StatusEffectBar
extends PanelContainer

@onready var status_name_label := $VBoxContainer/HBoxContainer/StatusName
@onready var duration_label := $VBoxContainer/HBoxContainer/Duration
@onready var description_label := $VBoxContainer/Description

var status_effect : StatusEffect

const STATUS_NAME_TEXT := "[color=%s]%s[/color]"
const FINITE_DURATION_TEXT := "%d Turn%s"
const PERMANENT_DURATION_TEXT := "Permanent"

func setup(p_status_effect : StatusEffect) -> void:
	status_effect = p_status_effect

func render() -> void:
	status_name_label.text = STATUS_NAME_TEXT % [DamageAndDoT.GENERIC_COLOR_HEX, status_effect.get_effect_name()]
	
	if status_effect.is_permanent:
		duration_label.text = PERMANENT_DURATION_TEXT
	else:
		duration_label.text = FINITE_DURATION_TEXT % [
			status_effect.duration,
			"s" if status_effect.duration != 1 else ""
		]
	
	description_label.text = status_effect.get_description()
