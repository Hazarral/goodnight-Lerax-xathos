class_name BuffAndDebuff
extends Resource

@export_group("Duration and permanence")
@export var duration : int = 0
@export var is_permanent : bool = false

## Health
@export_group("Health")
@export var health_additive : float = 0.0
@export var health_additive_multiplicative : float = 0.0
@export var health_true_multiplicative : float = 0.0

## Shield
@export_group("Shields")
@export var shields_additive : PackedFloat32Array = PackedFloat32Array()
@export var shields_additive_multiplicative : PackedFloat32Array = PackedFloat32Array()
@export var shields_true_multiplicative : PackedFloat32Array = PackedFloat32Array()

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

func _init(p_duration : int) -> void:
	shields_additive.resize(DamageAndDoT.ELEMENT_COUNT)
	shields_additive_multiplicative.resize(DamageAndDoT.ELEMENT_COUNT)
	shields_true_multiplicative.resize(DamageAndDoT.ELEMENT_COUNT)
	duration = p_duration

func set_health_buff_and_debuff(additive : float, additive_multiplicative : float, true_multiplicative : float) -> void:
	health_additive = additive
	health_additive_multiplicative = additive_multiplicative
	health_true_multiplicative = true_multiplicative

func set_shields_buff_and_debuff(additive : PackedFloat32Array, additive_multiplicative : PackedFloat32Array, true_multiplicative : PackedFloat32Array) -> void:
	shields_additive = additive
	shields_additive_multiplicative = additive_multiplicative
	shields_true_multiplicative = true_multiplicative

func set_potency_buff_and_debuff(additive : float, additive_multiplicative : float, true_multiplicative : float) -> void:
	potency_additive = additive
	potency_additive_multiplicative = additive_multiplicative
	potency_true_multiplicative = true_multiplicative

func set_mastery_buff_and_debuff(additive : float, additive_multiplicative : float, true_multiplicative : float) -> void:
	mastery_additive = additive
	mastery_additive_multiplicative = additive_multiplicative
	mastery_true_multiplicative = true_multiplicative

func set_final_damage_dealt_and_received_buff_and_debuff(damage_dealt_multiplicative : float, damage_received_multiplicative : float) -> void:
	final_damage_dealt_true_multiplicative = damage_dealt_multiplicative
	final_damage_received_true_multiplicative = damage_received_multiplicative

func tick_down() -> void:
	if is_permanent:
		return
	
	duration -= 1
	if duration <= 0:
		expire()

func expire() -> void:
	EventBus.buff_and_debuff_expired.emit(self)
