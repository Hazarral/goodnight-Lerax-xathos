class_name ActionButton
extends Button

const ACTION_BASE_TEXT := "%s            %d AP"
const ACTION_EXTRA_COOLDOWN_TEXT := "   ·    CD %d"

var entity : Entity
var action_index : int
var known_action : KnownAction
var action : Action

signal pressed_action(entity : Entity, index : int)

func setup(p_entity : Entity, p_index : int) -> void:
	entity = p_entity
	action_index = p_index
	known_action = entity.known_actions[action_index]
	action = known_action.action

func render() -> void:
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	custom_minimum_size = Vector2(0, 34)
	
	var label_text := ACTION_BASE_TEXT % [action.action_name, action.action_point_cost]
	if known_action.cooldown_remaining > 0:
		label_text += ACTION_EXTRA_COOLDOWN_TEXT % known_action.cooldown_remaining
	text = label_text
	
	disabled = not known_action.is_castable()

func _on_mouse_entered() -> void:
	ActionTooltip.render(action)
	ActionTooltip.show()

func _on_mouse_exited() -> void:
	ActionTooltip.hide()

func _on_pressed() -> void:
	pressed_action.emit(entity, action_index)
