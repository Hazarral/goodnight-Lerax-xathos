class_name ShieldUI
extends VBoxContainer

@onready var shield_label := $ShieldLabel
@onready var shield_bar := $ShieldBar

const SHIELD_LABEL_TEXT := "%d/%d %s Shield"

# Called once when creating the UI
func setup_visuals(damage_type: int, max_val: int) -> void:
	shield_bar.max_value = max_val
	shield_bar.value = max_val
	
	var new_style = StyleBoxFlat.new()
	new_style.bg_color = Color(DamageAndDoT.get_damage_color_hex(damage_type))
	shield_bar.add_theme_stylebox_override("fill", new_style)

func update_visuals(damage_type: int, current_val: int, max_val: int) -> void:
	shield_bar.value = current_val
	shield_label.text = "%d/%d %s Shield" % [
		current_val, 
		max_val, 
		DamageAndDoT.get_damage_type_name(damage_type)
	]
