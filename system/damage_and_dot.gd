extends Node

enum DamageType {
	FIRE = 0,
	WATER = 1,
	WIND = 2,
	POISON = 3,
	LIGHTNING = 4,
	PHYSICAL = 5,
	EARTH = 6,
	ICE = 7,
	VOID = 8,
}

enum DoT {
	BURN = 0,
	CURRENT = 1,
	WIND_SHEAR = 2,
	POISON = 3,
	SHOCK = 4,
	BLEED = 5,
	CRUMBLE = 6,
	FROSTBITE = 7,
	VOID = 8
}

const ELEMENT_COUNT := 8

# Damage types
const FIRE := &"Fire"
const WATER := &"Water"
const WIND := &"Wind"
const POISON := &"Poison"
const LIGHTNING := &"Lightning"
const PHYSICAL := &"Physical"
const EARTH := &"Earth"
const ICE := &"Ice"
const VOID := &"Void"

# DoT types
const BURN := &"Burn"
const CURRENT := &"Current"
const WIND_SHEAR := &"Wind Shear"
const SHOCK := &"Shock"
const BLEED := &"Bleed"
const CRUMBLE := &"Crumble"
const FROSTBITE := &"Frostbite"

# Colors
const FIRE_COLOR_HEX := "#c0471a"
const WATER_COLOR_HEX := "#44a1e2"
const WIND_COLOR_HEX := "#6da88f"
const POISON_COLOR_HEX := "#5ed85d"
const LIGHTNING_COLOR_HEX := "#3761ff"
const PHYSICAL_COLOR_HEX := "#b4b4b4"
const EARTH_COLOR_HEX := "#836540"
const ICE_COLOR_HEX := "#bad3fb"
const VOID_COLOR_HEX := "#ff1d75"

func get_dot(damage_type : DamageType) -> DoT:
	return damage_type as DoT

func get_damage_type_name(damage_type : DamageType) -> StringName:
	match damage_type:
		DamageType.FIRE: return FIRE
		DamageType.WATER: return WATER
		DamageType.WIND: return WIND
		DamageType.POISON: return POISON
		DamageType.LIGHTNING: return LIGHTNING
		DamageType.PHYSICAL: return PHYSICAL
		DamageType.EARTH: return EARTH
		DamageType.ICE: return ICE
		DamageType.VOID: return VOID
	return &""

func get_damage_color_hex(damage_type : DamageType) -> String:
	match damage_type:
		DamageType.FIRE: return FIRE_COLOR_HEX
		DamageType.WATER: return WATER_COLOR_HEX
		DamageType.WIND: return WIND_COLOR_HEX
		DamageType.POISON: return POISON_COLOR_HEX
		DamageType.LIGHTNING: return LIGHTNING_COLOR_HEX
		DamageType.PHYSICAL: return PHYSICAL_COLOR_HEX
		DamageType.EARTH: return EARTH_COLOR_HEX
		DamageType.ICE: return ICE_COLOR_HEX
		DamageType.VOID: return VOID_COLOR_HEX
	return ""
