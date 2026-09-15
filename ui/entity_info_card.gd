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

const STATE_TEXT := "[%s]"
const SHIELD_STATE_TEXT := "%s"
const AP_TEXT := "> %d / %d AP (+%d / turn)"
const HP_TEXT := "> %d / %d HP"

signal card_pressed(card : EntityInfoCard)

var render_dead : bool = false

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
	show_ap = p_show_ap
	hp_bar.max_value = entity.get_max_hp()

func set_selected(value: bool) -> void:
	is_selected = value
	_refresh_visual_state()

func set_active_turn(value : bool) -> void:
	is_active_turn = value
	_refresh_visual_state()

func set_targetable(value : bool) -> void:
	is_targetable = value
	_refresh_visual_state()

func set_dead_visuals() -> void:
	state_label.text = STATE_TEXT % STATE_NAME_DEAD
	_set_font_opacity(true)

func _set_font_opacity(is_dead : bool = false) -> void:
	## Set this flag permanently
	render_dead = render_dead or is_dead
	
	var opacity := 0.5 if render_dead else 1.0
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
	
	name_label.text = entity.get_entity_name_with_suffix()
	state_label.text = STATE_TEXT % _get_entity_state_name() 
	sync_shield_state()
	sync_action_point()
	
	hp_label.text = HP_TEXT % [
		entity.current_hp,
		entity.get_max_hp()
	]
	
	_set_display_hp(entity.current_hp)

func _on_mouse_entered() -> void:
	modulate = Color(0.75, 0.75, 0.75)  # grey-out on hover

func _on_mouse_exited() -> void:
	modulate = Color(1, 1, 1)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_pressed.emit(self)

func tween_hp(target_hp : int, duration: float) -> void:
	# If the user dragged the speed slider to instant
	if duration <= 0.0:
		_set_display_hp(target_hp)
		return
		
	var tween := create_tween()
	
	# Tween the physical bar
	tween.tween_property(hp_bar, "value", target_hp, duration)
	
	# Parallel tween the text label so the numbers roll down smoothly with the bar
	tween.parallel().tween_method(_set_display_hp, hp_bar.value, target_hp, duration)

# A helper setter so the tween can update the label string every frame
func _set_display_hp(display_hp : int) -> void:
	hp_bar.value = display_hp
	hp_label.text = HP_TEXT % [
		display_hp,
		entity.get_max_hp()
	]

func sync_shield_state() -> void:
	shield_status_label.text = SHIELD_STATE_TEXT % entity.get_shield_state_name()

func sync_action_point() -> void:
	ap_label.visible = show_ap
	ap_label.text = AP_TEXT % [
		entity.current_action_point, 
		entity.template.max_action_point, 
		entity.template.action_point_regen_per_turn
	]
