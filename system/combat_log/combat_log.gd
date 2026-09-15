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

var _null_count := 0			## Umbrella for all null
var _active_reservations:= 0	## For explicit registration/cancellation
const NULL_THRESHOLD := 0.5
const MAXIMUM_NULL_ENTRIES := 100

func register(entry : CombatLogEntry) -> void:
	_entries.append(entry)

func set_mode(display_mode : DisplayMode) -> void:
	_mode = display_mode

func _clear_logs() -> void:
	_basic_log = ""
	_advanced_log = ""
	_developer_log = ""

func reserve_slot() -> int:
	if _null_count >= mini(ceili(_entries.size() * NULL_THRESHOLD), MAXIMUM_NULL_ENTRIES) and _active_reservations == 0:
		_clear_null_entries()
	
	_entries.append(null)
	_null_count += 1
	_active_reservations += 1
	
	return _entries.size() - 1

func cancel_reserved_slot(index : int) -> void:
	if index < 0 or index >= _entries.size():
		push_error("Cannot cancel reserved slot %d: out of bounds!" % index)
		return
	_entries[index] = null  # NOTE: leave as null tombstone, do not remove_at() — would shift later indices
	_active_reservations -= 1

func fill_reserved_slot(index : int, entry : CombatLogEntry) -> void:
	if index < 0 or index >= _entries.size():
		push_error("Cannot fill reserved slot %d: out of bounds!" % index)
		return
	
	if _entries[index] != null:
		push_error("Slot %d is already filled! Overwriting %s with %s" % [index, _entries[index], entry])
	
	_entries[index] = entry
	_null_count -= 1
	_active_reservations -= 1

func _clear_null_entries() -> void:
	var write_ptr := 0
	for i in range(_entries.size()):
		if _entries[i] != null:
			_entries[write_ptr] = _entries[i]
			write_ptr += 1
	
	_entries.resize(write_ptr)
	_null_count = 0

func build_logs() -> void:
	## TODO: Write log logic here, build all 3 logs
	_clear_logs()
	
	var basic_arr := PackedStringArray()
	var advanced_arr := PackedStringArray()
	var developer_arr := PackedStringArray()
	
	var developer_entry_counter := 1
	
	for entry in _entries:
		if entry == null:
			continue
		
		var basic_string := entry.render_basic()
		if not basic_string.is_empty():
			basic_arr.append(basic_string)
		
		var advanced_string := entry.render_advanced()
		if not advanced_string.is_empty():
			advanced_arr.append(advanced_string)
		
		var developer_string := entry.render_developer()
		if not developer_string.is_empty():
			developer_arr.append(("[Entry %d] " % developer_entry_counter) + developer_string)
			developer_entry_counter += 1
	
	# Join them all in a single efficient C++ operation under the hood
	_basic_log = "\n\n".join(basic_arr)
	_advanced_log = "\n\n".join(advanced_arr)
	_developer_log = "\n\n".join(developer_arr)

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
