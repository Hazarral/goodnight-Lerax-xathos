class_name BuffAndDebuffManager
extends RefCounted

var all_buffs_and_debuffs : Array[BuffAndDebuff]

func add_buff_and_debuff(buff_and_debuff : BuffAndDebuff) -> void:
	all_buffs_and_debuffs.append(buff_and_debuff)

func remove_buff_and_debuff(buff_and_debuff : BuffAndDebuff) -> void:
	all_buffs_and_debuffs.erase(buff_and_debuff)

func compute_health(base : float) -> float:
	var additive_sum := 0.0
	var additive_multiplicative_sum := 0.0
	for buff_and_debuff in all_buffs_and_debuffs:
		additive_sum += buff_and_debuff.health_additive
		additive_multiplicative_sum += buff_and_debuff.health_additive_multiplicative
	
	var result := (base + additive_sum) * (1.0 + additive_multiplicative_sum)
	
	for buff_and_debuff in all_buffs_and_debuffs:
		result *= (1.0 + buff_and_debuff.health_true_multiplicative)
		
	return result

func compute_shield(index : int, base : float) -> float:
	var additive_sum := 0.0
	var additive_multiplicative_sum := 0.0
	for buff_and_debuff in all_buffs_and_debuffs:
		additive_sum += buff_and_debuff.shields_additive[index]
		additive_multiplicative_sum += buff_and_debuff.shields_additive_multiplicative[index]
	
	var result := (base + additive_sum) * (1.0 + additive_multiplicative_sum)
	
	for buff_and_debuff in all_buffs_and_debuffs:
		result *= (1.0 + buff_and_debuff.shields_true_multiplicative[index])
		
	return result

func compute_potency(base : float) -> float:
	var additive_sum := 0.0
	var additive_multiplicative_sum := 0.0
	for buff_and_debuff in all_buffs_and_debuffs:
		additive_sum += buff_and_debuff.potency_additive
		additive_multiplicative_sum += buff_and_debuff.potency_additive_multiplicative
	
	var result := (base + additive_sum) * (1.0 + additive_multiplicative_sum)
	
	for buff_and_debuff in all_buffs_and_debuffs:
		result *= (1.0 + buff_and_debuff.potency_true_multiplicative)
		
	return result

func compute_mastery(base : float) -> float:
	var additive_sum := 0.0
	var additive_multiplicative_sum := 0.0
	for buff_and_debuff in all_buffs_and_debuffs:
		additive_sum += buff_and_debuff.mastery_additive
		additive_multiplicative_sum += buff_and_debuff.mastery_additive_multiplicative
	
	var result := (base + additive_sum) * (1.0 + additive_multiplicative_sum)
	
	for buff_and_debuff in all_buffs_and_debuffs:
		result *= (1.0 + buff_and_debuff.mastery_true_multiplicative)
		
	return result

func compute_final_damage_dealt(raw_damage_dealt : float) -> float:
	var result : float = raw_damage_dealt
	for buff_and_debuff in all_buffs_and_debuffs:
		result *= (1.0 + buff_and_debuff.final_damage_dealt_true_multiplicative)
	
	return result

func compute_final_damage_received(raw_damage_received : float) -> float:
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

func get_summary() -> BuffAndDebuffSummary:
	# Health
	var health_additive : float = 0.0
	var health_additive_multiplicative : float = 0.0
	var health_true_multiplicative : float = 1.0  # running product of (1 + x); converted at the end

	## Shields (one entry per shield slot)
	var shields_additive : PackedFloat32Array = PackedFloat32Array()
	shields_additive.resize(DamageAndDoT.ELEMENT_COUNT)
	
	var shields_additive_multiplicative : PackedFloat32Array = PackedFloat32Array()
	shields_additive_multiplicative.resize(DamageAndDoT.ELEMENT_COUNT)
	
	var shields_true_multiplicative : PackedFloat32Array = PackedFloat32Array()  # running products
	shields_true_multiplicative.resize(DamageAndDoT.ELEMENT_COUNT)
	shields_true_multiplicative.fill(1.0)

	## Potency
	var potency_additive : float = 0.0
	var potency_additive_multiplicative : float = 0.0
	var potency_true_multiplicative : float = 1.0

	## Mastery
	var mastery_additive : float = 0.0
	var mastery_additive_multiplicative : float = 0.0
	var mastery_true_multiplicative : float = 1.0

	## Damage dealt and received
	var final_damage_dealt_true_multiplicative : float = 1.0
	var final_damage_received_true_multiplicative : float = 1.0
	
	for buff_and_debuff in all_buffs_and_debuffs:
		health_additive += buff_and_debuff.health_additive
		health_additive_multiplicative += buff_and_debuff.health_additive_multiplicative
		health_true_multiplicative *= (1.0 + buff_and_debuff.health_true_multiplicative)
		
		for i in buff_and_debuff.shields_additive.size():
			shields_additive[i] += buff_and_debuff.shields_additive[i]
		
		for i in buff_and_debuff.shields_additive_multiplicative.size():
			shields_additive_multiplicative[i] += buff_and_debuff.shields_additive_multiplicative[i]
		
		for i in buff_and_debuff.shields_true_multiplicativ.size():
			shields_true_multiplicative[i] *= (1.0 + buff_and_debuff.shields_true_multiplicativ[i])
		
		potency_additive += buff_and_debuff.potency_additive
		potency_additive_multiplicative += buff_and_debuff.potency_additive_multiplicative
		potency_true_multiplicative *= (1.0 + buff_and_debuff.potency_true_multiplicative)
		
		mastery_additive += buff_and_debuff.mastery_additive
		mastery_additive_multiplicative += buff_and_debuff.mastery_additive_multiplicative
		mastery_true_multiplicative *= (1.0 + buff_and_debuff.mastery_true_multiplicative)
		
		final_damage_dealt_true_multiplicative *= (1.0 + buff_and_debuff.final_damage_dealt_true_multiplicative)
		final_damage_received_true_multiplicative *= (1.0 + buff_and_debuff.final_damage_received_true_multiplicative)
	
	return BuffAndDebuffSummary.new(
		health_additive,
		health_additive_multiplicative,
		health_true_multiplicative,
		shields_additive,
		shields_additive_multiplicative,
		shields_true_multiplicative,
		potency_additive,
		potency_additive_multiplicative,
		potency_true_multiplicative,
		mastery_additive,
		mastery_additive_multiplicative,
		mastery_true_multiplicative,
		final_damage_dealt_true_multiplicative,
		final_damage_received_true_multiplicative
	)	
