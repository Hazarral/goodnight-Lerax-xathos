class_name TextSegment
extends DescriptionSegment

@export var highlighted : bool
@export_multiline var text : String

const HIGHLIGHTED_TEMPLATE := "[color=%s]%s[/color]"

func to_text(_detailed : bool = false) -> String:
	var sanitized_text := text.strip_edges()
	
	if not highlighted:
		return sanitized_text
	
	return HIGHLIGHTED_TEMPLATE % [
		DamageAndDoT.GENERIC_COLOR_HEX,
		sanitized_text
	]
