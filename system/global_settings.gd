extends Node

## CombatLogEntry playback speed, along with Entity Card's HP fluctuation and Death animation playback speed.
var ui_playback_delay : float = 0.15:
	set(value):
		ui_playback_delay = clampf(value, 0.0, 1.0)

const UI_PLAYBACK_DELAY_STEP := 0.05
