class_name EntityView
extends RefCounted

#An entity has several attributes
var entity_name : String

## Either on player's side or not
var is_player_faction : bool

var max_hp : int
var current_hp : int
var max_shields : PackedInt64Array
var current_shields : PackedInt64Array

var current_state := Entity.State.ALIVE

var active_dots : Array[DoTInstanceArray] = []
var void_instance : VoidInstance = null

var status_effects : Array[StatusEffect]
var buffs_and_debuffs : Array[BuffAndDebuff]

func _init(entity : Entity) -> void:
	entity_name = entity.get_entity_name_with_suffix()
	is_player_faction = entity.is_player_faction()
	
	max_hp = entity.get_max_hp()
	current_hp = entity.current_hp
	max_shields = entity.max_shields.duplicate()
	current_shields = entity.current_shields.duplicate()
	
	current_state = entity.current_state
	
	active_dots = entity.get_active_dots()
	if entity.void_instance != null:
		void_instance = entity.void_instance.duplicate()
	
	status_effects = entity.get_status_effects()
	buffs_and_debuffs = entity.get_all_buff_and_debuffs()
