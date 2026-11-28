class_name CombatFieldState
extends RefCounted

##TODO: implement the combat field state here, show info of everything an AI needs to know
var draechen_player : Entity

var ally_on_field : Array[Entity]
var enemy_on_field : Array[Entity]

var turn_order : Array[Entity]
var current_turn_index := 0
var turn_counter := 0
var round_counter := 0

func _init() -> void:
	##NOTE: It will automatically snapshot info from CombatSystem
	draechen_player = CombatSystem.get_the_draechen()
	
	ally_on_field.assign(CombatSystem.get_on_field(true))
	enemy_on_field.assign(CombatSystem.get_on_field(false))
	turn_order.assign(CombatSystem.turn_order)
	
	current_turn_index = CombatSystem.current_turn_index
	turn_counter = CombatSystem.turn_counter
	round_counter = CombatSystem.round_counter
