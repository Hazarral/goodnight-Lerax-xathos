class_name ShieldGroup
extends VBoxContainer

@export var damage_type : DamageAndDoT.DamageType
@export var shield_max_value : int

@onready var shield_label := $ShieldLabel
@onready var shield_bar := $ShieldBar

var shield_current_value : int

const SHIELD_LABEL_TEXT := "%d/%d %s Shield"

func _ready() -> void:
	setup_shield()
	update_shield_bar(shield_max_value)

func setup_shield() -> void:
	shield_bar.max_value = shield_max_value
	shield_current_value = shield_max_value
	shield_bar.value = shield_max_value
	
	var new_style = StyleBoxFlat.new()
	new_style.bg_color = Color(DamageAndDoT.get_damage_color_hex(damage_type))
	shield_bar.add_theme_stylebox_override("fill", new_style)

func is_breached() -> bool:
	return shield_current_value <= 0

func update_shield_bar(new_value : int) -> void:
	shield_label.text = SHIELD_LABEL_TEXT % [shield_bar.value, shield_bar.max_value, DamageAndDoT.get_damage_type_name(damage_type)]
	shield_bar.value = new_value
