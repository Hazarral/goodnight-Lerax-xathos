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
	update_shield_bar()

func setup_shield() -> void:
	shield_bar.max_value = shield_max_value
	shield_current_value = shield_max_value
	
	var new_style = StyleBoxFlat.new()
	new_style.bg_color = Color(DamageAndDoT.get_damage_color_hex(damage_type))
	shield_bar.add_theme_stylebox_override("fill", new_style)

func damage(incoming_damage : int) -> int:
	var damage_to_shield : int = mini(shield_current_value, incoming_damage)
	if damage_to_shield > 0 and shield_current_value <= 0:
		print("%s shield broken!" % DamageAndDoT.get_damage_type_name(damage_type))
	
	shield_current_value -= damage_to_shield
	update_shield_bar()

	# Return the leftover so the caller can apply it to HP
	return incoming_damage - damage_to_shield

func is_breached() -> bool:
	return shield_current_value <= 0

func update_shield_bar() -> void:
	shield_label.text = SHIELD_LABEL_TEXT % [shield_bar.value, shield_bar.max_value, DamageAndDoT.get_damage_type_name(damage_type)]
	shield_bar.value = shield_current_value
