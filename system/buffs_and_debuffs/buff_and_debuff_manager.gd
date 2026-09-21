class_name BuffAndDebuffManager
extends RefCounted

var all_buffs_and_debuffs : Array[BuffAndDebuff]
var _pending_removals : Array[BuffAndDebuff] = []

func get_all_buff_and_debuffs() -> Array[BuffAndDebuff]:
	return all_buffs_and_debuffs

func add_buff_and_debuff(buff_and_debuff : BuffAndDebuff) -> void:
	all_buffs_and_debuffs.append(buff_and_debuff)
	buff_and_debuff.buff_and_debuff_expired.connect(remove_buff_and_debuff)

func remove_buff_and_debuff(buff_and_debuff : BuffAndDebuff) -> void:
	_pending_removals.append(buff_and_debuff)

func tick_down() -> void:
	for buff_and_debuff in all_buffs_and_debuffs:
		buff_and_debuff.tick_down()
	
	if _pending_removals.is_empty():
		return
	
	for buff_and_debuff in _pending_removals:
		all_buffs_and_debuffs.erase(buff_and_debuff)
	
	_pending_removals.clear()

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
	var true_multiplicative_product := 1.0
	
	for buff_and_debuff in all_buffs_and_debuffs:
		additive_sum += buff_and_debuff.get_shield_additive(index)
		additive_multiplicative_sum += buff_and_debuff.get_shield_additive_multiplicative(index)
		true_multiplicative_product *= (1.0 + buff_and_debuff.get_shield_true_multiplicative(index))
	
	return (base + additive_sum) * (1.0 + additive_multiplicative_sum) * true_multiplicative_product

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

func compute_final_damage_dealt_multiplier() -> float:
	var result : float = 1.0
	for buff_and_debuff in all_buffs_and_debuffs:
		result *= (1.0 + buff_and_debuff.final_damage_dealt_true_multiplicative)
	
	return result

func compute_final_damage_received_multiplier() -> float:
	var result : float = 1.0
	for buff_and_debuff in all_buffs_and_debuffs:
		result *= (1.0 + buff_and_debuff.final_damage_received_true_multiplicative)
	
	return result

func get_contributors_health() -> Array[BuffAndDebuff]:
	return all_buffs_and_debuffs.filter(
		func(buff_and_debuff : BuffAndDebuff): 
			return buff_and_debuff.has_health_modifications()
	)

func get_contributors_shield(damage_type : DamageAndDoT.DamageType) -> Array[BuffAndDebuff]:
	return all_buffs_and_debuffs.filter(
		func(buff_and_debuff : BuffAndDebuff): 
			return buff_and_debuff.has_shield_modifications(damage_type)
	)

func get_contributors_potency() -> Array[BuffAndDebuff]:
	return all_buffs_and_debuffs.filter(
		func(buff_and_debuff : BuffAndDebuff): 
			return buff_and_debuff.has_potency_modifications()
	)

func get_contributors_mastery() -> Array[BuffAndDebuff]:
	return all_buffs_and_debuffs.filter(
		func(buff_and_debuff : BuffAndDebuff): 
			return buff_and_debuff.has_mastery_modifications()
	)

func get_contributors_final_damage_dealt() -> Array[BuffAndDebuff]:
	return all_buffs_and_debuffs.filter(
		func(buff_and_debuff : BuffAndDebuff): 
			return buff_and_debuff.has_final_damage_dealt_modifications()
	)

func get_contributors_final_damage_received() -> Array[BuffAndDebuff]:
	return all_buffs_and_debuffs.filter(
		func(buff_and_debuff : BuffAndDebuff): 
			return buff_and_debuff.has_final_damage_received_modifications()
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
		
		var add := buff_and_debuff.get_packed_shields_additive()
		var add_mult := buff_and_debuff.get_packed_shields_additive_multiplicative()
		var true_mult := buff_and_debuff.get_packed_shields_true_multiplicative()
		for i in DamageAndDoT.ELEMENT_COUNT:
			shields_additive[i] += add[i]
			shields_additive_multiplicative[i] += add_mult[i]
			shields_true_multiplicative[i] *= (1.0 + true_mult[i])
		
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
