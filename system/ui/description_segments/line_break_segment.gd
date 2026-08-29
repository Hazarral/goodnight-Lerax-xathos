class_name LineBreakSegment
extends DescriptionSegment

func wants_leading_space() -> bool:
	return false

func suppresses_following_space() -> bool:
	return true

func to_text() -> String:
	return "\n\n"
