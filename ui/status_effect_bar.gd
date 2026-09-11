class_name StatusEffectBar
extends PanelContainer

@onready var status_name_label := $VBoxContainer/HBoxContainer/StatusName
@onready var duration_label := $VBoxContainer/HBoxContainer/Duration
@onready var description_label := $VBoxContainer/Description

var display_info : StatusEffectDisplayInfo

const STATUS_NAME_TEXT := "[color=%s]%s[/color]"
const FINITE_DURATION_TEXT := "%d Turn%s"
const PERMANENT_DURATION_TEXT := "Permanent"

func setup(p_display_info : StatusEffectDisplayInfo) -> void:
	display_info = p_display_info

func render() -> void:
	status_name_label.text = STATUS_NAME_TEXT % [DamageAndDoT.GENERIC_COLOR_HEX, display_info.effect_name]
	
	if display_info.is_permanent:
		duration_label.text = PERMANENT_DURATION_TEXT
	else:
		duration_label.text = FINITE_DURATION_TEXT % [
			display_info.duration,
			"s" if display_info.duration != 1 else ""
		]
	
	description_label.text = display_info.description
