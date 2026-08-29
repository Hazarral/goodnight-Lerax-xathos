class_name StacksSegment
extends DescriptionSegment

@export var value : int

const TEMPlATE := "%d Stacks of"

func to_text() -> String:
	return TEMPlATE % value
