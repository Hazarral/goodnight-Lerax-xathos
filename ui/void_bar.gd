class_name VoidBar
extends PanelContainer

@onready var void_name_label := $VBoxContainer/HBoxContainer/VoidName
@onready var stacks_label := $VBoxContainer/HBoxContainer/Stacks
@onready var description_label := $VBoxContainer/Description

var entity : Entity

const VOID_NAME_TEXT := "[color=%s]VOID[/color]"
const VOID_STACKS_TEXT := "%d Stack%s"
const DESCRIPTION_TEXT := """> Current Damage per Turn: [color=%s]%d[/color]
> Turns Elapsed: [color=%s]%d[/color]
> Multiplier: [color=%s]%.2f%%[/color]
"""

func setup(p_entity : Entity) -> void:
	entity = p_entity

func render() -> void:
	var void_stacks := entity.get_void_stacks()
	var void_elapsed_turns := entity.get_void_elapsed_turns()
	
	void_name_label.text = VOID_NAME_TEXT % DamageAndDoT.VOID_COLOR_HEX
	
	stacks_label.text = VOID_STACKS_TEXT % [
		void_stacks,
		"s" if void_stacks > 1 else ""
	]
	
	description_label.text = DESCRIPTION_TEXT % [
		DamageAndDoT.VOID_COLOR_HEX, entity.get_current_void_damage(),
		DamageAndDoT.VOID_COLOR_HEX, void_elapsed_turns,
		DamageAndDoT.VOID_COLOR_HEX, DamageAndDoT.get_void_escalation(void_elapsed_turns) * 100.0
	]
