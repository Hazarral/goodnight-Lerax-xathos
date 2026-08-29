class_name TurnsSegment
extends DescriptionSegment

@export var value : int

const TEMPLATE := "%d Turns"

func to_text() -> String:
	return TEMPLATE % value
