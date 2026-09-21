class_name TargetPhaseBar
extends PanelContainer

@onready var cancel_button := $VBoxContainer/Button

@export var slide_time := 0.2
@export var offset := Vector2(0, 100)
var _tween : Tween
var _is_active := false # Track the current state

func _ready() -> void:
	position = offset

func slide(active : bool) -> void:
	if _is_active == active:
		return
	
	_is_active = active
	
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	var target_pos := Vector2.ZERO if active else offset
	_tween.tween_property(self, "position", target_pos, slide_time)
