class_name CombatUI
extends Control

@export var player_faction_entity_templates : Array[EntityTemplate]
@export var enemy_faction_entity_templates : Array[EntityTemplate]
var player_side : Array[Entity]
var enemy_side : Array[Entity]

@onready var enemy_roster_header := $Frame/Root/MidRow/EnemyPanel/EnemyCol/Header
const ENEMY_ROSTER_BASE_HEADER := "ENEMIES"
const ENEMY_ROSTER_HAS_REINFORCEMENT_HEADER := "ENEMIES (REINFORCEMENT: %d)"

## 1. INSPECTOR
@onready var inspector_name_label := $Frame/Root/MidRow/InspectorPanel/InspectorCol/InspScroll/InspBody/TitleRow/Name
@onready var inspector_state_label := $Frame/Root/MidRow/InspectorPanel/InspectorCol/InspScroll/InspBody/TitleRow/State
@onready var inspector_hp_label := $Frame/Root/MidRow/InspectorPanel/InspectorCol/InspScroll/InspBody/HPLine
@onready var inspector_potency_label := $Frame/Root/MidRow/InspectorPanel/InspectorCol/InspScroll/InspBody/PotencyLine
@onready var inspector_mastery_label := $Frame/Root/MidRow/InspectorPanel/InspectorCol/InspScroll/InspBody/MasteryLine

@onready var inspector_void_label := $Frame/Root/MidRow/InspectorPanel/InspectorCol/InspScroll/InspBody/VoidRow/VoidHBox/VoidDesc
@onready var inspector_shield_grid := $Frame/Root/MidRow/InspectorPanel/InspectorCol/InspScroll/InspBody/ShieldGrid

@onready var player_roster_list := $Frame/Root/MidRow/PartyPanel/PartyCol/RosterScroll/RosterList
@onready var enemy_roster_list := $Frame/Root/MidRow/EnemyPanel/EnemyCol/RosterScroll/RosterList

const ENTITY_INFO_CARD_SCENE : PackedScene = preload("res://ui/entity_info_card.tscn")
const SHIELD_CHIP_SCENE : PackedScene = preload("res://ui/shield_chip.tscn")

const INSPECTOR_STATE_TEXT := "[%s]"
const STATE_ALIVE_TEXT := "ALIVE"
const STATE_DEAD_TEXT := "DEAD"

const INSPECTOR_HP_TEXT := "HP: %d / %d"
const INSPECTOR_POTENCY_TEXT := "Potency: %d"
const INSPECTOR_MASTERY_TEXT := "Mastery: %d"

var selected_card : EntityInfoCard = null

@onready var action_list := $Frame/Root/ActionBar/ActionBarRow/ActionScroll/VBoxContainer/ActionList

## This script is a THEME REFERENCE, not final combat UI wiring.
## It shows the pattern for turning a KnownAction (action + cooldown_remaining)
## into a themed Button with correct disabled state and label text,
## using only CombatTheme.tres — no textures anywhere.

func _ready() -> void:
	_demo_populate_action_list()
	_combat_mockup()
	
func _init_inspector() -> void:
	for entity_card : EntityInfoCard in player_roster_list.get_children():
		entity_card.card_pressed.connect(_on_entity_info_card_pressed)
	for entity_card : EntityInfoCard in enemy_roster_list.get_children():
		entity_card.card_pressed.connect(_on_entity_info_card_pressed)	
	
	inspector_name_label.text = ""
	inspector_state_label.text = ""
	inspector_hp_label.text = ""
	inspector_potency_label.text = ""
	inspector_mastery_label.text = ""

func _combat_mockup() -> void:
	CombatSystem.initialize_combat(player_faction_entity_templates, enemy_faction_entity_templates)
	_add_roster_for_faction(true)
	_add_roster_for_faction(false)
	_update_enemy_roster_header()
	_init_inspector()

func _on_entity_info_card_pressed(card : EntityInfoCard) -> void:
	## Only 1 card is read at a time
	if selected_card:
		selected_card.set_selected(false)
	card.set_selected(true)
	selected_card = card
	
	for child in inspector_shield_grid.get_children():
		child.queue_free()
	
	var entity := card.entity
	
	inspector_name_label.text = entity.template.entity_name
	inspector_state_label.text = INSPECTOR_STATE_TEXT % [
		STATE_ALIVE_TEXT if entity.current_state == Entity.State.ALIVE else STATE_DEAD_TEXT
	]
	
	inspector_hp_label.text = INSPECTOR_HP_TEXT % [
		entity.current_hp,
		entity.get_max_hp()
	]
	
	inspector_potency_label.text = INSPECTOR_POTENCY_TEXT % entity.get_potency()
	inspector_mastery_label.text = INSPECTOR_MASTERY_TEXT % entity.get_mastery()
	
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		var damage_type := i as DamageAndDoT.DamageType
		if entity.has_shield(damage_type):
			var shield_chip : ShieldChip = SHIELD_CHIP_SCENE.instantiate()
			inspector_shield_grid.add_child(shield_chip)
			shield_chip.setup(entity, damage_type)
			shield_chip.render()

func _add_roster_for_faction(is_player_faction : bool) -> void:
	_add_roster(CombatSystem.get_on_field(is_player_faction), is_player_faction)

func _add_roster(faction : Array[Entity], is_player_faction : bool) -> void:
	var roster_list := player_roster_list if is_player_faction else enemy_roster_list
	
	for entity in faction:
		var entity_card := ENTITY_INFO_CARD_SCENE.instantiate()
		roster_list.add_child(entity_card)
		entity_card.setup(entity)
		entity_card.render()

func _update_enemy_roster_header() -> void:
	var reinforcement_count := CombatSystem.get_enemy_reinforcement_count()
	if reinforcement_count > 0:
		enemy_roster_header.text = ENEMY_ROSTER_HAS_REINFORCEMENT_HEADER % reinforcement_count
	else:
		enemy_roster_header.text = ENEMY_ROSTER_BASE_HEADER

## --- EVERYTHING BELOW THIS LINE WAS AI-GENERATED ---

## Example of the exact pattern you'd use once KnownAction/Entity are wired in:
## for k in draechen.known_actions:
##     _add_action_button(k.action, k.is_ready(), k.cooldown_remaining)
func _demo_populate_action_list() -> void:
	# Clear any placeholder buttons left in the scene, rebuild from "data"
	for child in action_list.get_children():
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
	action_list.add_child(btn)

func _on_action_pressed(action_name: String) -> void:
	print("Cast pressed: ", action_name)
	# Real implementation calls KnownAction.cast() here and re-renders on result.
