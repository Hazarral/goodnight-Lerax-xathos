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

@onready var name_label := $CardVBox/NameRow/Name
@onready var state_label := $CardVBox/NameRow/State
@onready var shield_status_label := $CardVBox/ShieldStatusLabel
@onready var ap_label:= $CardVBox/APLabel
@onready var hp_label := $CardVBox/HPLabel
@onready var hp_bar := $CardVBox/HPBar

const STATE_NAME_ALIVE := "ALIVE"
const STATE_NAME_DEAD := "DEAD"

enum ShieldState {
	NO_SHIELD,		## No shield at all, all max == 0
	FULLY_SHIELDED, ## All active shields are not broken
	BREACHED,		## At least 1 active shield is breached
	ALL_BREACHED	## All active shields are breached
}

const SHIELD_STATE_NAME : Dictionary[ShieldState, String] = {
	ShieldState.NO_SHIELD : "No Shield",
	ShieldState.FULLY_SHIELDED : "Fully Shielded",
	ShieldState.BREACHED : "Shield Breached",
	ShieldState.ALL_BREACHED : "All Shield Breached"
}

const STATE_TEXT := "[%s]"
const SHIELD_STATE_TEXT := "%s"
const AP_TEXT := "> %d / %d AP (+%d / turn)"
const HP_TEXT := "> %d / %d HP"

signal card_pressed(card : EntityInfoCard)

func _ready() -> void:
	if debug_mode:
		if not entity_template:
			push_error("No entity template found in debug mode! Please set an entity template")
			return
		
		setup(Entity.new(entity_template))
		render()
		print("Debug mode rendered")
		return
	
	print("Using non-debug mode")

func setup(p_entity : Entity, p_show_ap : bool = true) -> void:
	entity = p_entity
	hp_bar.max_value = entity.get_max_hp()
	show_ap = p_show_ap

func set_selected(value: bool) -> void:
	is_selected = value
	_refresh_visual_state()

func set_active_turn(is_active : bool) -> void:
	is_active_turn = is_active
	_refresh_visual_state()

func _refresh_visual_state() -> void:
	var color := Color.WHITE
	if is_selected:
		color = Color("#d97757")
	if is_active_turn:
		color = Color("7ba17eff")  # or a distinct color if you want them visually different
	
	name_label.modulate = color
	state_label.modulate = color
	shield_status_label.modulate = color
	ap_label.modulate = color
	hp_label.modulate = color

func _get_entity_state_name() -> String:
	if entity.current_state == Entity.State.ALIVE:
		return STATE_NAME_ALIVE
	
	return STATE_NAME_DEAD

func render() -> void:
	if not entity:
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
	
	if show_ap:
		print("Showing AP for %s" % entity.template.entity_name)
	
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
		emit_signal("card_pressed", self)
