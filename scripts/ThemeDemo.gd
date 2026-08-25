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

## 2. Action bar
@onready var current_entity_name_label := $Frame/Root/ActionBar/ActionBarRow/MarginContainer/VBoxContainer/HBoxContainer/PortraitCell/PortraitName
@onready var current_entity_potency_label := $Frame/Root/ActionBar/ActionBarRow/MarginContainer/VBoxContainer/HBoxContainer/PortraitCell/PotencyLabel
@onready var current_entity_mastery_label := $Frame/Root/ActionBar/ActionBarRow/MarginContainer/VBoxContainer/HBoxContainer/PortraitCell/MasteryLabel

@onready var end_turn_button := $Frame/Root/ActionBar/ActionBarRow/MarginContainer/VBoxContainer/EndTurnButton

const CURRENT_ENTITY_POTENCY_TEXT := "Potency: %d"
const CURRENT_ENTITY_MASTERY_TEXT := "Mastery: %d"

@onready var ap_label := $Frame/Root/ActionBar/ActionBarRow/ActionScroll/VBoxContainer/APBlock/APLabel

const AP_TEXT := "ACTION POINTS: %d / %d (+%d / TURN)"

@onready var action_list := $Frame/Root/ActionBar/ActionBarRow/ActionScroll/VBoxContainer/ActionList

const ACTION_BASE_LABEL := "%s            %d AP"
const ACTION_EXTRA_COOLDOWN_LABEL := "   ·    CD %d"

## 3. Signal and input
var is_awaiting_target : bool = false
var valid_target_pool : Array[Entity] = []

func _ready() -> void:
	_combat_mockup()
	_refresh_turn_ui()
	EventBus.target_requested.connect(_on_target_requested)
	
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
	
	CombatSystem.advance_turn()

func _update_action_bar() -> void:
	var current_entity := CombatSystem.get_current_actor()
	if not current_entity:
		return
	
	current_entity_name_label.text = current_entity.template.entity_name
	current_entity_potency_label.text = CURRENT_ENTITY_POTENCY_TEXT % current_entity.get_potency()
	current_entity_mastery_label.text = CURRENT_ENTITY_MASTERY_TEXT % current_entity.get_mastery()
	
	ap_label.text = AP_TEXT % [
		current_entity.current_action_point,
		current_entity.get_max_action_point(),
		current_entity.get_action_point_regen_per_turn()
	]
	
	_populate_action_list(CombatSystem.get_current_actor())

func _on_entity_info_card_pressed(card : EntityInfoCard) -> void:
	if is_awaiting_target:
		if card.entity in valid_target_pool:
			is_awaiting_target = false
			_clear_target_highlight()
			EventBus.emit_signal("target_chosen", card.entity)
		# else: invalid click while targeting — ignore, or flash a rejection cue
		return
	
	## Only 1 card is read at a time
	_clear_selected_card()
	card.set_selected(true)
	selected_card = card
	
	_set_inspector(card.entity)

func _clear_selected_card() -> void:
	if selected_card:
		selected_card.set_selected(false)

func _set_inspector(entity : Entity) -> void:
	for child in inspector_shield_grid.get_children():
		child.queue_free()
	
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
		entity_card.setup(entity, is_player_faction)
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
func _populate_action_list(entity : Entity) -> void:
	# Clear any placeholder buttons left in the scene, rebuild from "data"
	for child in action_list.get_children():
		child.queue_free()
	
	for i in entity.known_actions.size():
		_add_action_button(entity, i)

func _add_action_button(entity : Entity, index : int) -> void:
	var known_action : KnownAction = entity.known_actions[index]
	var action : Action = known_action.action
	
	## NOTE: Styling below is subject to change, and should use some ActionButton in the future
	var btn := Button.new()
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.custom_minimum_size = Vector2(0, 34)
	
	var label_text := ACTION_BASE_LABEL % [action.action_name, action.action_point_cost]
	if known_action.cooldown_remaining > 0:
		label_text += ACTION_EXTRA_COOLDOWN_LABEL % known_action.cooldown_remaining

	btn.text = label_text
	btn.disabled = not known_action.is_castable()
	btn.pressed.connect(_on_action_pressed.bind(entity, index))
	action_list.add_child(btn)

func _on_action_pressed(entity : Entity, index : int) -> void:
	await entity.cast_action(index)
	_refresh_turn_ui()

func _on_target_requested(event : ActionEvent, target_faction : ActionEvent.TargetFaction, target_state : ActionEvent.TargetState) -> void:
	is_awaiting_target = true
	valid_target_pool = CombatSystem.get_valid_targets(target_faction, target_state)
	_highlight_targetable_cards(valid_target_pool)

func _refresh_active_turn_cards() -> void:
	var current_entity := CombatSystem.get_current_actor()
	for card : EntityInfoCard in player_roster_list.get_children():
		card.set_active_turn(card.entity == current_entity)
		card.render()
	for card : EntityInfoCard in enemy_roster_list.get_children():
		card.set_active_turn(card.entity == current_entity)
		card.render()

func _refresh_turn_ui() -> void:
	_clear_selected_card()
	_refresh_active_turn_cards()
	_set_inspector(CombatSystem.get_current_actor())
	_update_action_bar()

func _on_end_turn_button_pressed() -> void:
	CombatSystem.end_current_actor_turn()
	_refresh_turn_ui()

func _highlight_targetable_cards(targets : Array[Entity]) -> void:
	for card : EntityInfoCard in player_roster_list.get_children():
		card.set_targetable(card.entity in targets)
	for card : EntityInfoCard in enemy_roster_list.get_children():
		card.set_targetable(card.entity in targets)

func _clear_target_highlight() -> void:
	for card : EntityInfoCard in player_roster_list.get_children():
		card.set_targetable(false)
	for card : EntityInfoCard in enemy_roster_list.get_children():
		card.set_targetable(false)
