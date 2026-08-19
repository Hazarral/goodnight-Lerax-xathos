extends Control

## This script is a THEME REFERENCE, not final combat UI wiring.
## It shows the pattern for turning a KnownAction (action + cooldown_remaining)
## into a themed Button with correct disabled state and label text,
## using only CombatTheme.tres — no textures anywhere.

func _ready() -> void:
	_demo_populate_action_list()


## Example of the exact pattern you'd use once KnownAction/Entity are wired in:
## for k in draechen.known_actions:
##     _add_action_button(k.action, k.is_ready(), k.cooldown_remaining)
func _demo_populate_action_list() -> void:
	var list := $Frame/Root/ActionBar/ActionBarRow/ActionScroll/ActionList

	# Clear any placeholder buttons left in the scene, rebuild from "data"
	for child in list.get_children():
		child.queue_free()

	# Fake KnownAction-shaped data for the demo; replace with real known_actions
	var demo_actions := [
		{"name": "Bite", "ap": 2, "cooldown": 0},
		{"name": "Claw", "ap": 2, "cooldown": 0},
		{"name": "Fire Breath", "ap": 2, "cooldown": 2},
		{"name": "Void Maw", "ap": 4, "cooldown": 0},
		{"name": "Wing Buffet", "ap": 3, "cooldown": 1},
		{"name": "Tail Sweep", "ap": 3, "cooldown": 0},
		{"name": "Frost Exhale", "ap": 3, "cooldown": 0},
	]

	for data in demo_actions:
		_add_action_button(data.name, data.ap, data.cooldown)


func _add_action_button(action_name: String, ap_cost: int, cooldown_remaining: int) -> void:
	var list := $Frame/Root/ActionBar/ActionBarRow/ActionScroll/ActionList

	var btn := Button.new()
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.custom_minimum_size = Vector2(0, 34)

	# AP cost is ALWAYS shown; cooldown is an ADDITIONAL badge, never a replacement.
	var label_text := "%s        %d AP" % [action_name, ap_cost]
	if cooldown_remaining > 0:
		label_text += "  ·  CD %d" % cooldown_remaining
		btn.disabled = true

	btn.text = label_text
	btn.pressed.connect(func(): _on_action_pressed(action_name))
	list.add_child(btn)


func _on_action_pressed(action_name: String) -> void:
	print("Cast pressed: ", action_name)
	# Real implementation calls KnownAction.cast() here and re-renders on result.
