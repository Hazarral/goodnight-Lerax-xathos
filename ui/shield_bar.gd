class_name ShieldBar
extends Control

var current : int = 0
var max_value : int = 100
var attrition : int = 0

const COLOR_FILL := Color("4a7a7a")   # shield teal
const COLOR_ATTRITION := Color("ff006a")  # void pink
const COLOR_TRACK_BORDER := Color("322e37")

func set_values(p_current : int, p_max_value : int, p_attrition : int) -> void:
	current = p_current
	max_value = max(p_max_value, 1)  # guard divide-by-zero
	attrition = p_attrition
	queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y
	
	var fill_w := w * (float(current) / max_value)
	var attrition_w := w * (float(attrition) / max_value)
	
	draw_rect(Rect2(0, 0, w, h), Color("17151a"))  # track background
	draw_rect(Rect2(0, 0, fill_w, h), COLOR_FILL)
	draw_rect(Rect2(w - attrition_w, 0, attrition_w, h), COLOR_ATTRITION)
	draw_rect(Rect2(0, 0, w, h), COLOR_TRACK_BORDER, false, 1.0)  # border, unfilled
