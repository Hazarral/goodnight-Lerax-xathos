class_name CombatUI
extends Control

@onready var inspector_title_label := $Frame/Root/MidRow/InspectorPanel/InspectorCol/InspScroll/InspBody/TitleRow/Title
@onready var inspector_hp_label := $Frame/Root/MidRow/InspectorPanel/InspectorCol/InspScroll/InspBody/HPLine
@onready var inspector_void_label := $Frame/Root/MidRow/InspectorPanel/InspectorCol/InspScroll/InspBody/VoidRow/VoidHBox/VoidDesc
@onready var inspector_shield_grid := $Frame/Root/MidRow/InspectorPanel/InspectorCol/InspScroll/InspBody/ShieldGrid

@onready var player_roster_list := $Frame/Root/MidRow/PartyPanel/PartyCol/RosterScroll/RosterList
@onready var enemy_roster_list := $Frame/Root/MidRow/EnemyPanel/EnemyCol/RosterScroll/RosterList

const SHIELD_CHIP_SCENE : PackedScene = preload("res://ui/shield_chip.tscn")

const INSPECTOR_TITLE_TEXT := "%s [%s]"
const STATE_ALIVE_TEXT := "ALIVE"
const STATE_DEAD_TEXT := "DEAD"

const INSPECTOR_HP_TEXT := "HP: %d / %d"

## This script is a THEME REFERENCE, not final combat UI wiring.
## It shows the pattern for turning a KnownAction (action + cooldown_remaining)
## into a themed Button with correct disabled state and label text,
## using only CombatTheme.tres — no textures anywhere.

func _ready() -> void:
	_demo_populate_action_list()
	for entity_card : EntityInfoCard in player_roster_list.get_children():
		entity_card.card_pressed.connect(_on_entity_info_card_pressed)
	for entity_card : EntityInfoCard in enemy_roster_list.get_children():
		entity_card.card_pressed.connect(_on_entity_info_card_pressed)	
	
func _on_entity_info_card_pressed(entity : Entity) -> void:
	for child in inspector_shield_grid.get_children():
		child.queue_free()
	
	inspector_title_label.text = INSPECTOR_TITLE_TEXT % [
		entity.template.entity_name,
		STATE_ALIVE_TEXT if entity.current_state == Entity.State.ALIVE else STATE_DEAD_TEXT
	]
	
	inspector_hp_label.text = INSPECTOR_HP_TEXT % [
		entity.current_hp,
		entity.get_max_hp()
	]
	
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		var damage_type := i as DamageAndDoT.DamageType
		if entity.has_shield(damage_type):
			var shield_chip : ShieldChip = SHIELD_CHIP_SCENE.instantiate()
			inspector_shield_grid.add_child(shield_chip)
			shield_chip.setup(entity, damage_type)
			shield_chip.render()

## Example of the exact pattern you'd use once KnownAction/Entity are wired in:
## for k in draechen.known_actions:
##     _add_action_button(k.action, k.is_ready(), k.cooldown_remaining)
func _demo_populate_action_list() -> void:
	var list := $Frame/Root/ActionBar/ActionBarRow/ActionScroll/ActionList

	# Clear any placeholder buttons left in the scene, rebuild from "data"
	for child in list.get_children():
		child.queue_free()

	# Fake KnownAction-shaped data for the demo; replace with real known_actions
	var demo_actions := [
		{"name": "Bite", "ap": 2, "cooldown": 0},
		{"name": "Claw", "ap": 2, "cooldown": 0},
		{"name": "Fire Breath", "ap": 2, "cooldown": 2},
		{"name": "Void Maw", "ap": 4, "cooldown": 0},
		{"name": "Wing Buffet", "ap": 3, "cooldown": 1},
		{"name": "Tail Sweep", "ap": 3, "cooldown": 0},
		{"name": "Frost Exhale", "ap": 3, "cooldown": 0},
	]

	for data in demo_actions:
		_add_action_button(data.name, data.ap, data.cooldown)


func _add_action_button(action_name: String, ap_cost: int, cooldown_remaining: int) -> void:
	var list := $Frame/Root/ActionBar/ActionBarRow/ActionScroll/ActionList

	var btn := Button.new()
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.custom_minimum_size = Vector2(0, 34)

	# AP cost is ALWAYS shown; cooldown is an ADDITIONAL badge, never a replacement.
	var label_text := "%s        %d AP" % [action_name, ap_cost]
	if cooldown_remaining > 0:
		label_text += "  ·  CD %d" % cooldown_remaining
		btn.disabled = true

	btn.text = label_text
	btn.pressed.connect(func(): _on_action_pressed(action_name))
	list.add_child(btn)


func _on_action_pressed(action_name: String) -> void:
	print("Cast pressed: ", action_name)
	# Real implementation calls KnownAction.cast() here and re-renders on result.
