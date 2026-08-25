class_name EntityTemplate
extends Resource

#An entity has several attributes
@export var entity_name : String

## Either on player's side or not
@export var is_player_faction : bool

## Potency increases how strong damage is
@export var potency : int

## Mastery increases Attrition, which reduces Shield capacity
@export var mastery : int

@export var max_hp : int

@export_group("Elemental Shields")
@export var fire_shield : int = 0
@export var water_shield : int = 0
@export var wind_shield : int = 0
@export var poison_shield : int = 0
@export var lightning_shield : int = 0
@export var physical_shield : int = 0
@export var earth_shield : int = 0
@export var ice_shield : int = 0

@export_group("Action Points")
@export var max_action_point : int
@export var starting_action_point : int
@export var action_point_regen_per_turn : int

@export_group("Innate Actions")
@export var innate_actions : Array[Action]

# The compiler creates the optimized array ONCE when spawning.
func get_packed_shields() -> PackedInt64Array:
	var packed := PackedInt64Array()
	packed.resize(DamageAndDoT.ELEMENT_COUNT)
	
	packed[DamageAndDoT.DamageType.FIRE] = fire_shield
	packed[DamageAndDoT.DamageType.WATER] = water_shield
	packed[DamageAndDoT.DamageType.WIND] = wind_shield
	packed[DamageAndDoT.DamageType.POISON] = poison_shield
	packed[DamageAndDoT.DamageType.LIGHTNING] = lightning_shield
	packed[DamageAndDoT.DamageType.PHYSICAL] = physical_shield
	packed[DamageAndDoT.DamageType.EARTH] = earth_shield
	packed[DamageAndDoT.DamageType.ICE] = ice_shield
	
	return packed
