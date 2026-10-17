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

static func _make_view(entity : Entity) -> EntityView:
	return EntityView.new(entity)

func _init() -> void:
	##NOTE: It will automatically snapshot info from CombatSystem
	draechen_player = EntityView.new(CombatSystem.get_the_draechen())
	
	ally_on_field = CombatSystem.get_on_field(true).map(_make_view)
	enemy_on_field = CombatSystem.get_on_field(false).map(_make_view)
	turn_order = CombatSystem.turn_order.map(_make_view)
	
	current_turn_index = CombatSystem.current_turn_index
	turn_counter = CombatSystem.turn_counter
	round_counter = CombatSystem.round_counter
