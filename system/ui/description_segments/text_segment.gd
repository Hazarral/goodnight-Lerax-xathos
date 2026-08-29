class_name TextSegment
extends DescriptionSegment

@export_multiline var text : String

func to_text() -> String:
	return text.strip_edges()
