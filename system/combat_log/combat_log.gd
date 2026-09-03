extends Node

enum DisplayMode {
	BASIC,		## Simple succinct combat log
	ADVANCED,	## Advanced combat log showing exactly what happened to shields and HP and so on
	DEVELOPER	## Advanced scaling math and debug info
}

var _entries : Array[CombatLogEntry]
var _mode := DisplayMode.BASIC 

var _basic_log : String = ""
var _advanced_log : String = ""
var _developer_log : String = ""

func register(entry : CombatLogEntry) -> void:
	_entries.append(entry)

func set_mode(display_mode : DisplayMode) -> void:
	_mode = display_mode

func _clear_logs() -> void:
	_basic_log = ""
	_advanced_log = ""
	_developer_log = ""

func _prefix(is_first_condition : bool) -> String:
	return "" if is_first_condition else "\n\n"

func build_logs() -> void:
	## TODO: Write log logic here, build all 3 logs
	_clear_logs()
	var basic_is_first := true
	var advanced_is_first := true
	var developer_is_first := true
	var developer_line_counter := 1
	
	for entry in _entries:
		var basic_string := entry.render_basic()
		if not basic_string.is_empty():
			_basic_log += _prefix(basic_is_first) + basic_string
			basic_is_first = false
		
		var advanced_string := entry.render_advanced()
		if not advanced_string.is_empty():
			_advanced_log += _prefix(advanced_is_first) + advanced_string
			advanced_is_first = false
		
		var developer_string := entry.render_developer()
		if not developer_string.is_empty():
			_developer_log += _prefix(developer_is_first) + "[%d] " % developer_line_counter + developer_string
			developer_line_counter += 1
			developer_is_first = false

func get_log(mode : DisplayMode) -> String:
	match mode:
		DisplayMode.BASIC:
			return _basic_log
		DisplayMode.ADVANCED:
			return _advanced_log
		DisplayMode.DEVELOPER:
			return _developer_log
		_:
			return ""	
