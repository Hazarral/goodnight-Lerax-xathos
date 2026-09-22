class_name VoidSegment
extends DescriptionSegment

@export var stacks : int
const SIMPLE_TEMPLATE := "[color=%s]%d Void Stack%s[/color]"
const DETAILED_TEMPLATE := "[color=%s]%d Void Stack%s[/color] [color=%s][Base Damage at 0 Target Attrition and %d Stack%s: (%.2f(%.2fHealth) + %.2f(%.2fShield) + %.2f(%.2fP^%.2f) + %.2f(%.2fM^%.2f)) * %d = [/color][color=%s]%d[/color][color=%s]][/color]"

func to_text(detailed : bool = false) -> String:
	if detailed:
		var the_draechen := CombatSystem.get_the_draechen()
		var max_hp := the_draechen.get_max_hp()
		var total_shield := the_draechen.get_total_max_shield()
		var potency := the_draechen.get_potency()
		var mastery := the_draechen.get_mastery()

		var hp_term := DamageAndDoT.MAX_HP_SCALING * max_hp
		var shield_term := DamageAndDoT.TOTAL_MAX_SHIELD_SCALING * total_shield
		var potency_term := DamageAndDoT.POTENCY_COEFFICIENT_SCALING * pow(potency, DamageAndDoT.POTENCY_EXPONENT_SCALING)
		var mastery_term := DamageAndDoT.MASTERY_COEFFICIENT_SCALING * pow(mastery, DamageAndDoT.MASTERY_EXPONENT_SCALING)
		
		var void_damage := DamageAndDoT.get_void_damage_to_enemy(
			the_draechen.get_max_hp(), 
			the_draechen.get_total_max_shield(),
			the_draechen.get_potency(),
			the_draechen.get_mastery(),
			0,
			stacks,
			0
		)
		
		return DETAILED_TEMPLATE % [
			DamageAndDoT.VOID_COLOR_HEX,               # 1. %s
			stacks,                                    # 2. %d
			"s" if stacks != 1 else "",                 # 3. %s
			DamageAndDoT.GENERIC_COLOR_HEX,            # 4. %s
			stacks,                                    # 5. %d
			"s" if stacks != 1 else "",                 # 6. %s
			hp_term,                                   # 7. %.2f (HP term value)
			DamageAndDoT.MAX_HP_SCALING,               # 8. %.2f (HP coefficient)
			shield_term,                               # 9. %.2f (Shield term value)
			DamageAndDoT.TOTAL_MAX_SHIELD_SCALING,     # 10. %.2f (Shield coefficient)
			potency_term,                              # 11. %.2f (Potency term value)
			DamageAndDoT.POTENCY_COEFFICIENT_SCALING,  # 12. %.2f (Potency coefficient)
			DamageAndDoT.POTENCY_EXPONENT_SCALING,     # 13. %.2f (Potency exponent)
			mastery_term,                              # 14. %.2f (Mastery term value)
			DamageAndDoT.MASTERY_COEFFICIENT_SCALING,  # 15. %.2f (Mastery coefficient)
			DamageAndDoT.MASTERY_EXPONENT_SCALING,     # 16. %.2f (Mastery exponent)
			stacks,                                    # 17. %d   (Multiplier)
			DamageAndDoT.VOID_COLOR_HEX,               # 18. %s 
			void_damage,                               # 19. %d   (Final damage value)
			DamageAndDoT.GENERIC_COLOR_HEX             # 20. %s 
		]
	
	return SIMPLE_TEMPLATE % [
		DamageAndDoT.VOID_COLOR_HEX,
		stacks,
		"s" if stacks != 1 else ""
	]
