class_name ShieldBar
extends Control

var current : int = 0
var max_value : int = 100
var attrition : int = 0

const COLOR_FILL := Color("4a7a7a")		# Shield current teal color
const COLOR_ATTRITION := Color("ff006a")	# Void pink Attrition color
const COLOR_TRACK_BORDER := Color("322e37")

const PULSE_SPEED := 1.5  # radians/sec-ish; tune to taste
var pulse_time : float = 0.0

func set_values(p_current : int, p_max_value : int, p_attrition : int) -> void:
	current = p_current
	max_value = max(p_max_value, 1)
	attrition = p_attrition
	set_process(attrition > 0)  # only tick the pulse when there's something to pulse
	queue_redraw()

func _process(delta : float) -> void:
	pulse_time += delta
	queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y
	
	var fill_w := w * (float(current) / max_value)
	var attrition_w := w * (float(attrition) / max_value)
	
	draw_rect(Rect2(0, 0, w, h), Color("17151a"))
	draw_rect(Rect2(0, 0, fill_w, h), COLOR_FILL)
	
	if attrition > 0:
		var pulse_alpha := (sin(pulse_time * PULSE_SPEED) + 1.0) / 2.0  # oscillates 0..1
		var pulsing_color := COLOR_ATTRITION
		pulsing_color.a = pulse_alpha
		draw_rect(Rect2(w - attrition_w, 0, attrition_w, h), pulsing_color)
	
	draw_rect(Rect2(0, 0, w, h), COLOR_TRACK_BORDER, false, 1.0)
