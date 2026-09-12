class_name BuffAndDebuffManager
extends RefCounted

var all_buffs_and_debuffs : Array[BuffAndDebuff]

func add_buff_and_debuff(buff_and_debuff : BuffAndDebuff) -> void:
	all_buffs_and_debuffs.append(buff_and_debuff)

func remove_buff_and_debuff(buff_and_debuff : BuffAndDebuff) -> void:
	all_buffs_and_debuffs.erase(buff_and_debuff)

func compute_health(base : int) -> float:
	var additive_sum := 0.0
	var additive_multiplicative_sum := 0.0
	for buff_and_debuff in all_buffs_and_debuffs:
		additive_sum += buff_and_debuff.health_additive
		additive_multiplicative_sum += buff_and_debuff.health_additive_multiplicative
	
	var result := (base + additive_sum) * (1.0 + additive_multiplicative_sum)
	
	for buff_and_debuff in all_buffs_and_debuffs:
		result *= (1.0 + buff_and_debuff.health_true_multiplicative)
		
	return result

func compute_all_shields(base : PackedInt64Array) -> PackedInt64Array:
	var result := PackedInt64Array()
	result.resize(base.size())
	
	for damage_type in base.size():
		var additive_sum := 0.0
		var additive_multiplicative_sum := 0.0
		for buff_and_debuff in all_buffs_and_debuffs:
			additive_sum += buff_and_debuff.shields_additive[damage_type]
			additive_multiplicative_sum += buff_and_debuff.shields_additive_multiplicative[damage_type]
		
		var shield_value := (base[damage_type] + additive_sum) * (1.0 + additive_multiplicative_sum)
		
		for buff_and_debuff in all_buffs_and_debuffs:
			shield_value *= (1.0 + buff_and_debuff.shields_true_multiplicative[damage_type])
		
		result[damage_type] = ceili(shield_value)
	
	return result

func compute_potency(base : int) -> float:
	var additive_sum := 0.0
	var additive_multiplicative_sum := 0.0
	for buff_and_debuff in all_buffs_and_debuffs:
		additive_sum += buff_and_debuff.potency_additive
		additive_multiplicative_sum += buff_and_debuff.potency_additive_multiplicative
	
	var result := (base + additive_sum) * (1.0 + additive_multiplicative_sum)
	
	for buff_and_debuff in all_buffs_and_debuffs:
		result *= (1.0 + buff_and_debuff.potency_true_multiplicative)
		
	return result

func compute_mastery(base : int) -> float:
	var additive_sum := 0.0
	var additive_multiplicative_sum := 0.0
	for buff_and_debuff in all_buffs_and_debuffs:
		additive_sum += buff_and_debuff.mastery_additive
		additive_multiplicative_sum += buff_and_debuff.mastery_additive_multiplicative
	
	var result := (base + additive_sum) * (1.0 + additive_multiplicative_sum)
	
	for buff_and_debuff in all_buffs_and_debuffs:
		result *= (1.0 + buff_and_debuff.mastery_true_multiplicative)
		
	return result

func compute_final_damage_dealt(raw_damage_dealt : int) -> float:
	var result : float = raw_damage_dealt
	for buff_and_debuff in all_buffs_and_debuffs:
		result *= (1.0 + buff_and_debuff.final_damage_dealt_true_multiplicative)
	
	return result

func compute_final_damage_received(raw_damage_received : int) -> float:
	var result : float = raw_damage_received
	for buff_and_debuff in all_buffs_and_debuffs:
		result *= (1.0 + buff_and_debuff.final_damage_received_true_multiplicative)
	
	return result

func get_contributors_health() -> Array[BuffAndDebuff]:
	return all_buffs_and_debuffs.filter(
		func(buff_and_debuff : BuffAndDebuff): 
			return (
				buff_and_debuff.health_additive != 0.0 or 
				buff_and_debuff.health_additive_multiplicative != 0.0 or 
				buff_and_debuff.health_true_multiplicative != 0.0
			)
	)

func get_contributors_shield(damage_type : DamageAndDoT.DamageType) -> Array[BuffAndDebuff]:
	return all_buffs_and_debuffs.filter(
		func(buff_and_debuff : BuffAndDebuff): 
			return (
				buff_and_debuff.shields_additive[damage_type] != 0.0 or 
				buff_and_debuff.shields_additive_multiplicative[damage_type] != 0.0 or 
				buff_and_debuff.shields_true_multiplicative[damage_type] != 0.0
			)
	)

func get_contributors_potency() -> Array[BuffAndDebuff]:
	return all_buffs_and_debuffs.filter(
		func(buff_and_debuff : BuffAndDebuff): 
			return (
				buff_and_debuff.potency_additive != 0.0 or 
				buff_and_debuff.potency_additive_multiplicative != 0.0 or 
				buff_and_debuff.potency_true_multiplicative != 0.0
			)
	)

func get_contributors_mastery() -> Array[BuffAndDebuff]:
	return all_buffs_and_debuffs.filter(
		func(buff_and_debuff : BuffAndDebuff): 
			return (
				buff_and_debuff.mastery_additive != 0.0 or 
				buff_and_debuff.mastery_additive_multiplicative != 0.0 or 
				buff_and_debuff.mastery_true_multiplicative != 0.0
			)
	)

func get_contributors_final_damage_dealt() -> Array[BuffAndDebuff]:
	return all_buffs_and_debuffs.filter(
		func(buff_and_debuff : BuffAndDebuff): 
			return buff_and_debuff.final_damage_dealt_true_multiplicative != 0.0
	)

func get_contributors_final_damage_received() -> Array[BuffAndDebuff]:
	return all_buffs_and_debuffs.filter(
		func(buff_and_debuff : BuffAndDebuff): 
			return buff_and_debuff.final_damage_received_true_multiplicative != 0.0
	)
