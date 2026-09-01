extends Node

enum Origin {
	THE_PRIMORDIAL_VOID,		## Draechen actions
	WORLD_WITH_NO_NAME,			## Fire
	VASSEON,					## Water
	THE_MEADOWS_OUT_OF_TIME,	## Wind
	EAX_7228,					## Lightning
	SIA,						## Poison
	DENOS_EN,					## Physical
	GRIERFARD,					## Earth
	ERANIAN_LEVOTICUS,			## Ice
	FOLASSO						## Void, final boss
}

const THE_PRIMORDIAL_VOID_NAME := "The Primordial Void"
const WORLD_WITH_NO_NAME_NAME := "World With No Name"
const VASSEON_NAME := "Vasseon"
const THE_MEADOWS_OUT_OF_TIME_NAME := "The Meadows Out of Time"
const EAX_7228_NAME := "EAX-7228"
const SIA_NAME := "Sia"
const DENOS_EN_NAME := "Denos En"
const GRIERFARD_NAME := "Grierfard"
const ERANIAN_LEVOTICUS_NAME := "Eranian Levoticus"
const FOLASSO_NAME := "Folasso"

func get_origin_name(origin : Origin) -> String:
	match origin:
		Origin.THE_PRIMORDIAL_VOID:
			return THE_PRIMORDIAL_VOID_NAME
		Origin.WORLD_WITH_NO_NAME:
			return WORLD_WITH_NO_NAME_NAME
		Origin.VASSEON:
			return VASSEON_NAME
		Origin.THE_MEADOWS_OUT_OF_TIME:
			return THE_MEADOWS_OUT_OF_TIME_NAME
		Origin.EAX_7228:
			return EAX_7228_NAME
		Origin.SIA:
			return SIA_NAME
		Origin.DENOS_EN:
			return DENOS_EN_NAME
		Origin.GRIERFARD:
			return GRIERFARD_NAME
		Origin.ERANIAN_LEVOTICUS:
			return ERANIAN_LEVOTICUS_NAME
		Origin.FOLASSO:
			return FOLASSO_NAME
		_:
			push_error("Unknown Origin: %s" % origin)
			return "Unknown Origin"
