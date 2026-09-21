extends Node

## CombatLogEntry playback speed, along with Entity Card's HP fluctuation and Death animation playback speed.
var ui_playback_delay : float = 0.15:
	set(value):
		ui_playback_delay = clampf(value, 0.0, 1.0)

const UI_PLAYBACK_DELAY_STEP := 0.05

## Buff and Debuff bar, as well as the details
var buff_and_debuff_display_fixed_precision : bool = false
var buff_and_debuff_display_precision : int = 2:
	set(value):
		buff_and_debuff_display_precision = clampi(value, 1, 4)
