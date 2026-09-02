class_name EntityInfoCard
extends PanelContainer

@export_group("Debug")
@export var entity_template : EntityTemplate
@export var debug_mode : bool

@export_group("Runtime")
@export var show_ap : bool

var entity : Entity
var is_active_turn : bool = false
var is_selected : bool = false
var is_targetable : bool = false

@onready var name_label := $MarginContainer/CardVBox/NameRow/Name
@onready var state_label := $MarginContainer/CardVBox/NameRow/State
@onready var shield_status_label := $MarginContainer/CardVBox/ShieldStatusLabel
@onready var ap_label:= $MarginContainer/CardVBox/APLabel
@onready var hp_label := $MarginContainer/CardVBox/HPLabel
@onready var hp_bar := $MarginContainer/CardVBox/HPBar

const STATE_NAME_ALIVE := "ALIVE"
const STATE_NAME_DEAD := "DEAD"

enum ShieldState {
	NO_SHIELD,		## No shield at all, all max == 0
	FULLY_SHIELDED, ## All active shields are not broken
	BREACHED,		## At least 1 active shield is breached
	ALL_BREACHED	## All active shields are breached
}

const SHIELD_STATE_NAME : Dictionary[ShieldState, String] = {
	ShieldState.NO_SHIELD : "[No Shield]",
	ShieldState.FULLY_SHIELDED : "[Fully Shielded]",
	ShieldState.BREACHED : "[Shield Breached]",
	ShieldState.ALL_BREACHED : "[All Shield Breached]"
}

const STATE_TEXT := "[%s]"
const SHIELD_STATE_TEXT := "%s"
const AP_TEXT := "> %d / %d AP (+%d / turn)"
const HP_TEXT := "> %d / %d HP"

signal card_pressed(card : EntityInfoCard)

func _ready() -> void:
	if debug_mode:
		if entity_template == null:
			push_error("No entity template found in debug mode! Please set an entity template")
			return
		
		setup(Entity.new(entity_template))
		render()
		print("Debug mode rendered")
		return

func setup(p_entity : Entity, p_show_ap : bool = true) -> void:
	entity = p_entity
	hp_bar.max_value = entity.get_max_hp()
	show_ap = p_show_ap

func set_selected(value: bool) -> void:
	is_selected = value
	_refresh_visual_state()

func set_active_turn(value : bool) -> void:
	is_active_turn = value
	_refresh_visual_state()

func set_targetable(value : bool) -> void:
	is_targetable = value
	_refresh_visual_state()

func _set_font_opacity() -> void:
	var opacity := 1.0 if entity.current_state == Entity.State.ALIVE else 0.5
	name_label.modulate.a = opacity
	state_label.modulate.a = opacity
	shield_status_label.modulate.a = opacity
	ap_label.modulate.a = opacity
	hp_label.modulate.a = opacity

func _refresh_visual_state() -> void:
	if is_targetable:
		theme_type_variation = "CardPanelTargetable"
	elif is_selected:
		theme_type_variation = "CardPanelSelected"
	elif is_active_turn:
		theme_type_variation = "CardPanelActiveTurn" 
	else:
		theme_type_variation = "CardPanel"
	
	_set_font_opacity()

func _get_entity_state_name() -> String:
	if entity.current_state == Entity.State.ALIVE:
		return STATE_NAME_ALIVE
	
	return STATE_NAME_DEAD

func render() -> void:
	if entity == null:
		push_error("No entity found for render! Please call setup(entity) first")
		return
	
	name_label.text = entity.template.entity_name
	state_label.text = STATE_TEXT % _get_entity_state_name() 
	shield_status_label.text = SHIELD_STATE_TEXT % SHIELD_STATE_NAME.get(get_shield_state())
	
	ap_label.visible = show_ap
	ap_label.text = AP_TEXT % [
		entity.current_action_point, 
		entity.template.max_action_point, 
		entity.template.action_point_regen_per_turn
	]
	
	hp_label.text = HP_TEXT % [
		entity.current_hp,
		entity.get_max_hp()
	]
	
	hp_bar.value = entity.current_hp

func get_shield_state() -> ShieldState:
	if entity.has_no_shields():
		return ShieldState.NO_SHIELD
	
	if entity.are_all_shields_breached():
		return ShieldState.ALL_BREACHED
	
	if entity.is_any_shield_breached():
		return ShieldState.BREACHED
	
	return ShieldState.FULLY_SHIELDED

func _on_mouse_entered() -> void:
	modulate = Color(0.75, 0.75, 0.75)  # grey-out on hover

func _on_mouse_exited() -> void:
	modulate = Color(1, 1, 1)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_pressed.emit(self)
