class_name CombatUI
extends Control

## Lifespan
@onready var lifespan_value_label := $Frame/Root/Topbar/TopbarRow/Lifespan/LifespanValue

@export var player_faction_entity_templates : Array[EntityTemplate]
@export var enemy_faction_entity_templates : Array[EntityTemplate]
var player_side : Array[Entity]
var enemy_side : Array[Entity]

@onready var enemy_roster_header := $Frame/Root/HBoxContainer/VBoxContainer/EntityInfoRow/EnemyPanel/EnemyCol/Header
const ENEMY_ROSTER_BASE_HEADER := "ENEMIES"
const ENEMY_ROSTER_HAS_REINFORCEMENT_HEADER := "ENEMIES (REINFORCEMENT: %d)"

@onready var player_roster_list := $Frame/Root/HBoxContainer/VBoxContainer/EntityInfoRow/PartyPanel/PartyCol/RosterScroll/RosterList
@onready var enemy_roster_list := $Frame/Root/HBoxContainer/VBoxContainer/EntityInfoRow/EnemyPanel/EnemyCol/RosterScroll/RosterList

## 1. INSPECTOR
@onready var inspector_name_label := $Frame/Root/HBoxContainer/VBoxContainer/EntityInfoRow/InspectorPanel/InspectorCol/InspScroll/InspBody/TitleRow/Name
@onready var inspector_state_label := $Frame/Root/HBoxContainer/VBoxContainer/EntityInfoRow/InspectorPanel/InspectorCol/InspScroll/InspBody/TitleRow/State
@onready var inspector_hp_label := $Frame/Root/HBoxContainer/VBoxContainer/EntityInfoRow/InspectorPanel/InspectorCol/InspScroll/InspBody/HPLine
@onready var inspector_potency_label := $Frame/Root/HBoxContainer/VBoxContainer/EntityInfoRow/InspectorPanel/InspectorCol/InspScroll/InspBody/PotencyLine
@onready var inspector_mastery_label := $Frame/Root/HBoxContainer/VBoxContainer/EntityInfoRow/InspectorPanel/InspectorCol/InspScroll/InspBody/MasteryLine
@onready var inspector_shield_grid := $Frame/Root/HBoxContainer/VBoxContainer/EntityInfoRow/InspectorPanel/InspectorCol/InspScroll/InspBody/ShieldGrid
@onready var inspector_elemental_dot_list := $Frame/Root/HBoxContainer/VBoxContainer/EntityInfoRow/InspectorPanel/InspectorCol/InspScroll/InspBody/ElementalDoTList
@onready var inspector_status_effect_list := $Frame/Root/HBoxContainer/VBoxContainer/EntityInfoRow/InspectorPanel/InspectorCol/InspScroll/InspBody/StatusEffectList
@onready var inspector_buff_and_debuff_bar := $Frame/Root/HBoxContainer/VBoxContainer/EntityInfoRow/InspectorPanel/InspectorCol/InspScroll/InspBody/BuffAndDebuffBar

const ENTITY_INFO_CARD_SCENE : PackedScene = preload("res://ui/entity_info_card.tscn")
const SHIELD_CHIP_SCENE : PackedScene = preload("res://ui/shield_chip.tscn")
const DOT_BAR_SCENE : PackedScene = preload("res://ui/dot_bar.tscn")
const STATUS_EFFECT_BAR_SCENE : PackedScene = preload("res://ui/status_effect_bar.tscn")

const INSPECTOR_STATE_TEXT := "[%s]"
const STATE_ALIVE_TEXT := "ALIVE"
const STATE_DEAD_TEXT := "DEAD"

const INSPECTOR_HP_TEXT := "HP: %d / %d"
const INSPECTOR_POTENCY_TEXT := "Potency: %d"
const INSPECTOR_MASTERY_TEXT := "Mastery: %d"

var selected_card : EntityInfoCard = null

@onready var void_bar := $Frame/Root/HBoxContainer/VBoxContainer/EntityInfoRow/InspectorPanel/InspectorCol/InspScroll/InspBody/VoidBar

## 2. Action bar
@onready var current_entity_name_label := $Frame/Root/HBoxContainer/VBoxContainer/ActionBar/ActionBarRow/MarginContainer/VBoxContainer/HBoxContainer/PortraitCell/PortraitName
@onready var current_entity_potency_label := $Frame/Root/HBoxContainer/VBoxContainer/ActionBar/ActionBarRow/MarginContainer/VBoxContainer/HBoxContainer/PortraitCell/PotencyLabel
@onready var current_entity_mastery_label := $Frame/Root/HBoxContainer/VBoxContainer/ActionBar/ActionBarRow/MarginContainer/VBoxContainer/HBoxContainer/PortraitCell/MasteryLabel

@onready var end_turn_button := $Frame/Root/HBoxContainer/VBoxContainer/ActionBar/ActionBarRow/MarginContainer/VBoxContainer/EndTurnButton

const CURRENT_ENTITY_POTENCY_TEXT := "Potency: %d"
const CURRENT_ENTITY_MASTERY_TEXT := "Mastery: %d"

@onready var ap_label := $Frame/Root/HBoxContainer/VBoxContainer/ActionBar/ActionBarRow/ActionScroll/VBoxContainer/APBlock/APLabel

const AP_TEXT := "ACTION POINTS: %d / %d (+%d / TURN)"

@onready var action_list := $Frame/Root/HBoxContainer/VBoxContainer/ActionBar/ActionBarRow/ActionScroll/VBoxContainer/ActionList

const ACTION_BUTTON := preload("res://ui/action_button.tscn")

## 3. Signal and input
var is_awaiting_target : bool = false
var valid_target_pool : Array[Entity] = []
var pending_action_index : int = -1   # which action button is currently mid-targeting
var pending_source : Entity = null

## 4. Combat log
@onready var combat_log_label := $Frame/Root/HBoxContainer/LogPanel/LogCol/LogScroll/LogText

var current_combat_log_mode := CombatLog.DisplayMode.BASIC

func _ready() -> void:
	EventBus.combat_initialization_finished.connect(_set_time_to_live)
	EventBus.target_requested.connect(_on_target_requested)
	EventBus.force_refresh_turn_ui.connect(_refresh_turn_ui)
	EventBus.log_updated.connect(_set_combat_log)
	
	_combat_mockup()
	_refresh_turn_ui()

static func clear_children(container_list : Array[Node]) -> void:
	for container in container_list:
		for child in container.get_children():
			child.queue_free()

func _set_time_to_live() -> void:
	print("Setting time to live...")
	lifespan_value_label.text = CombatSystem.get_the_draechen().get_time_to_live_str()

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
	if current_entity == null:
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
			_clear_pending_target_state()
			EventBus.target_resolved.emit(card.entity)
		# else: invalid click while targeting — ignore, or flash a rejection cue
		return
	
	## Only 1 card is read at a time
	_clear_selected_card()
	card.set_selected(true)
	selected_card = card
	
	_set_inspector(card.entity)

func _input(event : InputEvent) -> void:
	if is_awaiting_target and event.is_action_pressed("target_cancel"):
		_clear_pending_target_state()
		EventBus.target_resolved.emit(null)  # cancel = resolved with null

func _clear_pending_target_state() -> void:
	is_awaiting_target = false
	pending_action_index = -1
	pending_source = null
	_clear_target_highlight()

func _clear_selected_card() -> void:
	if selected_card:
		selected_card.set_selected(false)

func _set_inspector(entity : Entity) -> void:
	clear_children([
		inspector_shield_grid, 
		inspector_elemental_dot_list,
		inspector_status_effect_list
	])
	
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
		var damage_over_time := DamageAndDoT.get_dot(damage_type)
		var has_shield := entity.has_shield(damage_type)
		var has_dot := entity.has_dot(damage_over_time)
		
		if has_shield:
			var shield_chip : ShieldChip = SHIELD_CHIP_SCENE.instantiate()
			inspector_shield_grid.add_child(shield_chip)
			shield_chip.setup(entity, damage_type)
			shield_chip.render()
		
		if has_dot:
			var dot_bar : DoTBar = DOT_BAR_SCENE.instantiate()
			inspector_elemental_dot_list.add_child(dot_bar)
			dot_bar.setup(entity, entity.active_dots[damage_over_time])
			dot_bar.render()
	
	void_bar.visible = entity.has_void()
	if entity.has_void():
		void_bar.setup(entity)
		void_bar.render()
	
	var status_effects := entity.get_status_effects()
	for status_effect in status_effects:
		var status_bar := STATUS_EFFECT_BAR_SCENE.instantiate()
		inspector_status_effect_list.add_child(status_bar)
		status_bar.setup(status_effect)
		status_bar.render()
	
	inspector_buff_and_debuff_bar.setup(entity)
	inspector_buff_and_debuff_bar.render()

func _add_roster_for_faction(is_player_faction : bool) -> void:
	_add_roster(CombatSystem.get_on_field(is_player_faction), is_player_faction)

func _add_roster(faction : Array[Entity], is_player_faction : bool) -> void:
	var roster_list := player_roster_list if is_player_faction else enemy_roster_list
	
	for entity in faction:
		var entity_card := ENTITY_INFO_CARD_SCENE.instantiate()
		roster_list.add_child(entity_card)
		entity_card.setup(entity, is_player_faction)
		entity_card.render()
		CombatLog.register_entity(entity, entity_card)

func _update_enemy_roster_header() -> void:
	var reinforcement_count := CombatSystem.get_enemy_reinforcement_count()
	if reinforcement_count > 0:
		enemy_roster_header.text = ENEMY_ROSTER_HAS_REINFORCEMENT_HEADER % reinforcement_count
	else:
		enemy_roster_header.text = ENEMY_ROSTER_BASE_HEADER

func _populate_action_list(entity : Entity) -> void:
	# Clear any placeholder buttons left in the scene, rebuild from "data"
	for child in action_list.get_children():
		child.queue_free()
	
	for i in entity.known_actions.size():
		_add_action_button(entity, i)

func _add_action_button(entity : Entity, index : int) -> void:
	var btn := ACTION_BUTTON.instantiate()
	action_list.add_child(btn)
	btn.setup(entity, index)
	btn.render()
	btn.pressed_action.connect(_on_action_pressed)

func _on_action_pressed(entity : Entity, index : int) -> void:
	if is_awaiting_target:
		return
	
	pending_action_index = index
	pending_source = entity
	
	await entity.cast_action(index)
	_refresh_turn_ui()

func _on_target_requested(_event : ActionEvent, target_faction : ActionEvent.TargetFaction, target_state : ActionEvent.TargetState) -> void:
	is_awaiting_target = true
	valid_target_pool = CombatSystem.get_valid_targets(target_faction, target_state)
	_highlight_targetable_cards(valid_target_pool)

func _refresh_active_turn_cards() -> void:
	var current_entity := CombatSystem.get_current_actor()
	for card : EntityInfoCard in player_roster_list.get_children():
		card.set_active_turn(card.entity == current_entity)
		#card.render()
	for card : EntityInfoCard in enemy_roster_list.get_children():
		card.set_active_turn(card.entity == current_entity)
		#card.render()

func _refresh_turn_ui() -> void:
	_clear_selected_card()
	_refresh_active_turn_cards()
	_set_inspector(CombatSystem.get_current_actor())
	_update_action_bar()
	_update_combat_log()

func _update_end_turn_button() -> void:
	var opacity := 0.5 if CombatLog.is_log_playing() else 1.0
	end_turn_button.modulate.a = opacity

func _on_end_turn_button_pressed() -> void:
	if not CombatLog.is_log_playing():
		CombatSystem.end_current_actor_turn()

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

func _update_combat_log() -> void:
	## We use basic for now
	CombatLog.play_logs()

func _on_tab_bar_tab_changed(tab: int) -> void:
	current_combat_log_mode = tab as CombatLog.DisplayMode
	_set_combat_log()

func _set_combat_log() -> void:
	combat_log_label.text = CombatLog.get_log(current_combat_log_mode)

enum ExportMode {
	RAW,
	PARSED,
}

const BASIC_LOG_EXPORT := "user://basic_combat_log.txt"
const ADVANCED_LOG_EXPORT := "user://advanced_combat_log.txt"
const DEVELOPER_LOG_EXPORT := "user://developer_combat_log.txt"

func _export_combat_log(mode: ExportMode) -> void:
	var export_path := ""
	match current_combat_log_mode:
		CombatLog.DisplayMode.BASIC:
			export_path = BASIC_LOG_EXPORT
		CombatLog.DisplayMode.ADVANCED:
			export_path = ADVANCED_LOG_EXPORT
		CombatLog.DisplayMode.DEVELOPER:
			export_path = DEVELOPER_LOG_EXPORT
	
	var file := FileAccess.open(export_path, FileAccess.WRITE)
	match mode:
		ExportMode.RAW:
			file.store_string(combat_log_label.text)
		ExportMode.PARSED:
			file.store_string(combat_log_label.get_parsed_text())
	
	file.close()
	print("Combat log saved to: ", ProjectSettings.globalize_path(export_path))

func _on_export_raw_log_pressed() -> void:
	_export_combat_log(ExportMode.RAW)

func _on_export_parsed_log_pressed() -> void:
	_export_combat_log(ExportMode.PARSED)
