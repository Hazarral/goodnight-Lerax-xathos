class_name BuffAndDebuff
extends Resource

@export var buff_and_debuff_name : String = ""

@export_group("Duration and permanence")
@export var duration : int = 0
@export var is_permanent : bool = false

## Health
@export_group("Health")
@export var health_additive : float = 0.0
@export var health_additive_multiplicative : float = 0.0
@export var health_true_multiplicative : float = 0.0

@export_group("Shields Additive")
@export var fire_shield_additive : float = 0.0
@export var water_shield_additive : float = 0.0
@export var wind_shield_additive : float = 0.0
@export var poison_shield_additive : float = 0.0
@export var lightning_shield_additive : float = 0.0
@export var physical_shield_additive : float = 0.0
@export var earth_shield_additive : float = 0.0
@export var ice_shield_additive : float = 0.0

@export_group("Shields Additive Multiplicative")
@export var fire_shield_additive_multiplicative : float = 0.0
@export var water_shield_additive_multiplicative : float = 0.0
@export var wind_shield_additive_multiplicative : float = 0.0
@export var poison_shield_additive_multiplicative : float = 0.0
@export var lightning_shield_additive_multiplicative : float = 0.0
@export var physical_shield_additive_multiplicative : float = 0.0
@export var earth_shield_additive_multiplicative : float = 0.0
@export var ice_shield_additive_multiplicative : float = 0.0

@export_group("Shields True Multiplicative")
@export var fire_shield_true_multiplicative : float = 0.0
@export var water_shield_true_multiplicative : float = 0.0
@export var wind_shield_true_multiplicative : float = 0.0
@export var poison_shield_true_multiplicative : float = 0.0
@export var lightning_shield_true_multiplicative : float = 0.0
@export var physical_shield_true_multiplicative : float = 0.0
@export var earth_shield_true_multiplicative : float = 0.0
@export var ice_shield_true_multiplicative : float = 0.0

## Potency
@export_group("Potency")
@export var potency_additive : float = 0.0
@export var potency_additive_multiplicative : float = 0.0
@export var potency_true_multiplicative : float = 0.0

## Mastery
@export_group("Mastery")
@export var mastery_additive : float = 0.0
@export var mastery_additive_multiplicative : float = 0.0
@export var mastery_true_multiplicative : float = 0.0

## Damage dealt and received
@export_group("Final damage dealt and received")
@export var final_damage_dealt_true_multiplicative : float = 0.0
@export var final_damage_received_true_multiplicative : float = 0.0

var owner : Entity
signal buff_and_debuff_expired(buff_and_debuff : BuffAndDebuff)

func get_packed_shields_additive() -> PackedFloat32Array:
	return _pack_shields([
		fire_shield_additive, water_shield_additive, wind_shield_additive, poison_shield_additive,
		lightning_shield_additive, physical_shield_additive, earth_shield_additive, ice_shield_additive
	])

func get_packed_shields_additive_multiplicative() -> PackedFloat32Array:
	return _pack_shields([
		fire_shield_additive_multiplicative, water_shield_additive_multiplicative,
		wind_shield_additive_multiplicative, poison_shield_additive_multiplicative,
		lightning_shield_additive_multiplicative, physical_shield_additive_multiplicative,
		earth_shield_additive_multiplicative, ice_shield_additive_multiplicative
	])

func get_packed_shields_true_multiplicative() -> PackedFloat32Array:
	return _pack_shields([
		fire_shield_true_multiplicative, water_shield_true_multiplicative,
		wind_shield_true_multiplicative, poison_shield_true_multiplicative,
		lightning_shield_true_multiplicative, physical_shield_true_multiplicative,
		earth_shield_true_multiplicative, ice_shield_true_multiplicative
	])

func _pack_shields(values : Array[float]) -> PackedFloat32Array:
	var packed := PackedFloat32Array()
	packed.resize(DamageAndDoT.ELEMENT_COUNT)
	
	packed[DamageAndDoT.DamageType.FIRE] = values[0]
	packed[DamageAndDoT.DamageType.WATER] = values[1]
	packed[DamageAndDoT.DamageType.WIND] = values[2]
	packed[DamageAndDoT.DamageType.POISON] = values[3]
	packed[DamageAndDoT.DamageType.LIGHTNING] = values[4]
	packed[DamageAndDoT.DamageType.PHYSICAL] = values[5]
	packed[DamageAndDoT.DamageType.EARTH] = values[6]
	packed[DamageAndDoT.DamageType.ICE] = values[7]
	
	return packed

func get_shield_additive(index : int) -> float:
	match index:
		DamageAndDoT.DamageType.FIRE: return fire_shield_additive
		DamageAndDoT.DamageType.WATER: return water_shield_additive
		DamageAndDoT.DamageType.WIND: return wind_shield_additive
		DamageAndDoT.DamageType.POISON: return poison_shield_additive
		DamageAndDoT.DamageType.LIGHTNING: return lightning_shield_additive
		DamageAndDoT.DamageType.PHYSICAL: return physical_shield_additive
		DamageAndDoT.DamageType.EARTH: return earth_shield_additive
		DamageAndDoT.DamageType.ICE: return ice_shield_additive
	return 0.0

func get_shield_additive_multiplicative(index : int) -> float:
	match index:
		DamageAndDoT.DamageType.FIRE: return fire_shield_additive_multiplicative
		DamageAndDoT.DamageType.WATER: return water_shield_additive_multiplicative
		DamageAndDoT.DamageType.WIND: return wind_shield_additive_multiplicative
		DamageAndDoT.DamageType.POISON: return poison_shield_additive_multiplicative
		DamageAndDoT.DamageType.LIGHTNING: return lightning_shield_additive_multiplicative
		DamageAndDoT.DamageType.PHYSICAL: return physical_shield_additive_multiplicative
		DamageAndDoT.DamageType.EARTH: return earth_shield_additive_multiplicative
		DamageAndDoT.DamageType.ICE: return ice_shield_additive_multiplicative
	return 0.0

func get_shield_true_multiplicative(index : int) -> float:
	match index:
		DamageAndDoT.DamageType.FIRE: return fire_shield_true_multiplicative
		DamageAndDoT.DamageType.WATER: return water_shield_true_multiplicative
		DamageAndDoT.DamageType.WIND: return wind_shield_true_multiplicative
		DamageAndDoT.DamageType.POISON: return poison_shield_true_multiplicative
		DamageAndDoT.DamageType.LIGHTNING: return lightning_shield_true_multiplicative
		DamageAndDoT.DamageType.PHYSICAL: return physical_shield_true_multiplicative
		DamageAndDoT.DamageType.EARTH: return earth_shield_true_multiplicative
		DamageAndDoT.DamageType.ICE: return ice_shield_true_multiplicative
	return 0.0

func tick_down() -> void:
	if is_permanent:
		return
	
	duration -= 1
	if duration <= 0:
		expire()

func expire() -> void:
	buff_and_debuff_expired.emit(self)

func has_health_modifications() -> bool:
	return (
		health_additive != 0.0 or 
		health_additive_multiplicative != 0.0 or 
		health_true_multiplicative != 0.0
	)

func has_shield_modifications(damage_type : DamageAndDoT.DamageType) -> bool:
	return (
		get_shield_additive(damage_type) != 0.0 or 
		get_shield_additive_multiplicative(damage_type) != 0.0 or 
		get_shield_true_multiplicative(damage_type) != 0.0
	)

func has_potency_modifications() -> bool:
	return potency_additive != 0.0 or potency_additive_multiplicative != 0.0 or potency_true_multiplicative != 0.0

func has_mastery_modifications() -> bool:
	return mastery_additive != 0.0 or mastery_additive_multiplicative != 0.0 or mastery_true_multiplicative != 0.0

func has_final_damage_dealt_modifications() -> bool:
	return final_damage_dealt_true_multiplicative != 0.0

func has_final_damage_received_modifications() -> bool:
	return final_damage_received_true_multiplicative != 0.0
