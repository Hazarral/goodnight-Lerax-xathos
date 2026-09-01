class_name CommaSegment
extends DescriptionSegment

func wants_leading_space() -> bool:
	return false

func to_text(_detailed : bool = false) -> String:
	return ","
