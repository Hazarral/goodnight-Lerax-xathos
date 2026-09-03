class_name VoidInstance
extends RefCounted

var target : Entity
const damage_type := DamageAndDoT.DamageType.VOID
var stacks : int
var is_player_faction : bool

var turns_elapsed : int

func _init(p_target : Entity, p_stacks : int, p_is_player_faction : bool) -> void:
	target = p_target
	stacks = p_stacks
	is_player_faction = p_is_player_faction
	turns_elapsed = 0

func escalate() -> void:
	turns_elapsed += 1

func deal_damage(the_draechen : Draechen) -> void:
	var void_damage := get_current_damage(the_draechen)
	
	var damage_event := DamageEvent.new(
		null,
		target,
		DamageAndDoT.DamageType.VOID,
		void_damage
	)
	
	CombatSystem.register_combat_event(damage_event)
	CombatSystem.process_combat_event_queue()

func get_current_damage(the_draechen : Draechen) -> int:
	var void_damage := 0
	var encounter_potency_and_mastery := CombatSystem.get_highest_enemy_potency_and_mastery()
	
	if is_player_faction:
		void_damage = ceili(
			DamageAndDoT.get_void_damage_to_player(
				encounter_potency_and_mastery.potency,
				encounter_potency_and_mastery.mastery,
				target.get_total_attrition(),
				stacks,
				turns_elapsed
			)	
		)
		print("Getting Void damage against player...")
	else:
		void_damage = ceili(
			DamageAndDoT.get_void_damage_to_enemy(
				the_draechen.get_max_hp(), 
				the_draechen.get_total_max_shield(),
				the_draechen.get_potency(),
				the_draechen.get_mastery(),
				target.get_total_attrition(),
				stacks,
				turns_elapsed
			)
		)
		print("Getting Void damage against enemy...")
	
	return void_damage

func apply_stacks(incoming_stacks : int) -> void:
	stacks += incoming_stacks
