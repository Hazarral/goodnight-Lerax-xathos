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

func build_logs() -> void:
	## TODO: Write log logic here, build all 3 logs
	_clear_logs()
	for entry in _entries:
		_basic_log += entry.render_basic() + "\n"
		_advanced_log += entry.render_advanced() + "\n"
		_developer_log += entry.render_developer() + "\n"

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
