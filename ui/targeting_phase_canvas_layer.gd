extends CanvasLayer

@onready var rect : ColorRect = $ColorRect
@export var fade_time := 0.2
var _tween : Tween

func fade_gray(active : bool) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	# gray_amount is a named variable for grayscale strength
	_tween.tween_property(rect.material, "shader_parameter/gray_amount", 1.0 if active else 0.0, fade_time)
