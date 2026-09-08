extends Node

## This holds constants and static functions that allow operation on status effects
enum CheckpointType {
	TURN_START,
	PRE_SHIELD_REGEN,
	POST_SHIELD_REGEN,
	PRE_CRUMBLE_CORROSION,
	POST_CRUMBLE_CORROSION,
	PRE_DOT_TICK,
	POST_DOT_TICK,
	PRE_WIND_SHEAR_SPREAD,
	POST_WIND_SHEAR_SPREAD,
	PRE_WIND_SHEAR_BLAST,
	POST_WIND_SHEAR_BLAST,
	PRE_VOID_TICK,
	POST_VOID_TICK,
	PRE_VOID_ESCALATION,
	POST_VOID_ESCALATION,
	POST_CAST_SUCCESS,
	PRE_POISON_EXPLOSION,
	POST_POISON_EXPLOSION,
	PRE_POISON_TRANSFER,
	POST_POISON_TRANSFER,
	PRE_FROSTBITE_SHATTER,
	POST_FROSTBITE_SHATTER,
	PRE_SHOCK_CONVULSION,
	POST_SHOCK_CONVULSION,
	PRE_BLEED_HEALING_REDUCTION,
	POST_BLEED_HEALING_REDUCTION,
	PRE_BLEED_RUPTURE,
	POST_BLEED_RUPTURE,
	PRE_DAMAGE_TO_HP_TAKEN,
	POST_DAMAGE_TO_HP_TAKEN,
	PRE_ELEMENTAL_RESONANCE,	## Cannot interfere with damage, so it can only happen before or after damage event
	POST_ELEMENTAL_RESONANCE,	## Same as above
	PRE_ELEMENTAL_CASCADE,		## Same as above
	POST_ELEMENTAL_CASCADE,		## Same as above
	PRE_HEAL,
	POST_HEAL,
	PRE_DEATH,
	POST_DEATH,
	TURN_END
}

static func compare_priority(a : HookBinding, b : HookBinding) -> bool:
	return a.priority < b.priority

## ============================================================
## PRIORITY NAMESPACES
## Each CheckpointType has its OWN independent priority range.
## A status hooking PRE_DOT_TICK and a status hooking PRE_HEAL
## are never compared to each other — priority only orders
## statuses that share the exact same CheckpointType.
## Within a namespace: lower number = resolves first.
## Space everything by 10 to leave room for insertion; only
## drop to fractional/hundreds-shift if a namespace is exhausted.
## ============================================================

## --- TURN_START ---
## Statuses that need to act before ANYTHING else this turn
## (state resets, turn-count increments, pre-combat flags).

## --- TURN_END ---
## Statuses that resolve at the close of a turn if not
## consumed/interrupted earlier (e.g. Void Charged applying
## its stored Void stack if never cancelled).
const VOID_CHARGED_TURN_END := 100

## --- PRE_SHIELD_REGEN / POST_SHIELD_REGEN ---
## Anything modifying Attrition calculation or shield regen cap
## before it's applied, or reacting to the post-regen shield state.

## --- PRE_CRUMBLE_CORROSION / POST_CRUMBLE_CORROSION ---
## Hooks around Crumble's shield-splash damage (Stage B).

## --- PRE_DOT_TICK / POST_DOT_TICK ---
## Fires once per DoT-ticking stage (Stage C), around the whole
## batch of standard elemental ticks (Burn, Current, Wind Shear,
## Poison, Shock, Bleed, Crumble, Frostbite in pipeline order).

## --- PRE_WIND_SHEAR_SPREAD / POST_WIND_SHEAR_SPREAD ---
## The "duplicate other DoT damage to other Wind-Sheared enemies"
## portion of Stage D.

## --- PRE_WIND_SHEAR_BLAST / POST_WIND_SHEAR_BLAST ---

## --- PRE_VOID_TICK / POST_VOID_TICK ---

## --- PRE_VOID_ESCALATION / POST_VOID_ESCALATION ---
## The "1.20^Elapsed turns" stacking escalation step, kept
## separate from the tick itself so a status can intercept/
## cancel escalation without touching the actual damage
## (e.g. Void Charged listens here or on damage/shield-break
## to decide whether to interrupt).

## --- POST_CAST_SUCCESS ---
## Fires once a caster's action has been confirmed to execute
## (AP spent, cooldown started) after its effects applied.

## --- PRE_POISON_EXPLOSION / POST_POISON_EXPLOSION ---
## Death-triggered Poison AoE detonation (Async effect).

## --- PRE_POISON_TRANSFER / POST_POISON_TRANSFER ---
## The "highest current HP enemy inherits all Poison instances"
## step, kept separate from the explosion since transfer can be
## intercepted/redirected independently of whether the explosion
## itself was modified.

## --- PRE_FROSTBITE_SHATTER / POST_FROSTBITE_SHATTER ---
## Fires right before or after Frostbite deals its Shatter damage

## --- PRE_SHOCK_CONVULSION / POST_SHOCK_CONVULSION ---
## Stage F's AP-spend-triggered instant Lightning damage.

## --- PRE_BLEED_HEALING_REDUCTION / POST_BLEED_HEALING_REDUCTION ---

## --- PRE_BLEED_RUPTURE / POST_BLEED_RUPTURE ---
## Truly asynchronous: fires whenever ANY heal resolves anywhere,
## dealing the reduced-healing portion as Physical damage to HP.
## Naturally brackets PRE_HEAL/POST_HEAL rather than a turn stage.

## --- PRE_DAMAGE_TO_HP_TAKEN / POST_DAMAGE_TO_HP_TAKEN ---
## Generic bracket around ANY damage-to-HP resolution, regardless
## of source stage. Highest-traffic namespace — every DamageEvent
## that reaches HP passes through here.
const VOID_CHARGED_POST_DAMAGE_TO_HP_TAKEN := 100

## --- PRE_ELEMENTAL_RESONANCE / POST_ELEMENTAL_RESONANCE ---
## Cannot interfere with damage math itself (per inline comment),
## so these only bracket — never nest inside — a damage event.

## --- PRE_ELEMENTAL_CASCADE / POST_ELEMENTAL_CASCADE ---
## Same non-interference constraint as Resonance above.

## --- PRE_HEAL / POST_HEAL ---
## Brackets any heal resolution. Bleed Rupture listens here
## (see above) rather than being a heal-stage constant itself.

## --- PRE_DEATH / POST_DEATH ---
## Brackets an entity's state transition to DEAD. Poison
## Explosion/Transfer are typically registered as reactions
## to POST_DEATH rather than being POST_DEATH itself.
