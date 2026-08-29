@abstract class_name DescriptionSegment
extends Resource

func wants_leading_space() -> bool:
	return true

func suppresses_following_space() -> bool:
	return false

## There is nothing here
@abstract func to_text() -> String
