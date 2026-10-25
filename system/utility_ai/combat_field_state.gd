class_name CombatFieldState
extends RefCounted

##TODO: implement the combat field state here, show info of everything an AI needs to know
var draechen_player : EntityView

var ally_on_field : Array[EntityView]
var enemy_on_field : Array[EntityView]

var turn_order : Array[EntityView]
var current_turn_index := 0
var turn_counter := 0
var round_counter := 0

var views_by_id : Dictionary[int, EntityView] = {}

func _view_of(e : Entity) -> EntityView:
	var id := e.get_instance_id()
	if not views_by_id.has(id):
		views_by_id[id] = EntityView.new(e)
	return views_by_id[id]

func _init() -> void:
	##NOTE: It will automatically snapshot info from CombatSystem
	draechen_player = EntityView.new(CombatSystem.get_the_draechen())
	
	ally_on_field.assign(CombatSystem.get_on_field(true).map(_view_of))
	enemy_on_field.assign(CombatSystem.get_on_field(false).map(_view_of))
	turn_order.assign(CombatSystem.turn_order.map(_view_of))
	
	current_turn_index = CombatSystem.current_turn_index
	turn_counter = CombatSystem.turn_counter
	round_counter = CombatSystem.round_counter
