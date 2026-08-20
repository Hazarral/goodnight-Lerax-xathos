class_name ShieldChip
extends PanelContainer

@onready var element_label := $ChipVBox/ElementLabel
@onready var value_label := $ChipVBox/ValLabel
@onready var shield_bar := $ChipVBox/ShieldBar

var entity : Entity
var damage_type : DamageAndDoT.DamageType

func setup(p_entity : Entity, p_damage_type : DamageAndDoT.DamageType) -> void:
	entity = p_entity
	damage_type = p_damage_type

func render() -> void:
	if not entity:
		push_error("No entity found for render! Please call setup(entity, damage_type) first")
		return
	
	var current := entity.current_shields[damage_type]
	var max_val := entity.get_max_shield(damage_type)
	var attrition := entity.get_attrition(damage_type)  # however your Entity exposes this
	
	element_label.text = DamageAndDoT.DamageType.keys()[damage_type]
	
	var text := "%d / %d" % [current, max_val]
	if attrition > 0:
		text += " [font_size=12][color=#ff006a](−%d)[/color][/font_size]" % attrition
	value_label.text = text
	
	shield_bar.set_values(current, max_val, attrition)
