extends Node

enum DisplayMode {
	BASIC = 0,		## Simple succinct combat log
	ADVANCED = 1,	## Advanced combat log showing exactly what happened to shields and HP and so on
	DEVELOPER = 2	## Advanced scaling math and debug info
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

const ENTRY_LINE_DELIMITER := "\n\n"

var _playback_cursor := 0
var _is_playing := false

var entity_info_card_registry : Dictionary[Entity, EntityInfoCard] = {}

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

func play_logs() -> void:
	if _is_playing:
		return
	
	_is_playing = true

	_clear_logs()
	var developer_entry_counter := 1
	var index := 0 
	
	while index < _entries.size():
		var entry := _entries[index]
		
		if entry == null:
			index += 1
			continue
		
		var basic_string = entry.render_basic()
		if not basic_string.is_empty():
			_basic_log += basic_string + ENTRY_LINE_DELIMITER
		
		var advanced_string := entry.render_advanced()
		if not advanced_string.is_empty():
			_advanced_log += advanced_string + ENTRY_LINE_DELIMITER
		
		var developer_string := entry.render_developer()
		if not developer_string.is_empty():
			_developer_log += ("[Entry %d] " % developer_entry_counter) + developer_string + ENTRY_LINE_DELIMITER
			developer_entry_counter += 1
		
		## THis is old history, don't play back, be instant
		if index < _playback_cursor:
			index += 1
			continue # Instantly move to the next iteration. No waits, no tweens.
		
		## Update Entity card or any visuals here
		entry.execute_visuals()
		
		## Tell the Combat UI to actually render the log again
		EventBus.log_updated.emit()
		
		_playback_cursor = index + 1
		
		## The mandatory delay
		await get_tree().create_timer(GlobalSettings.ui_playback_delay).timeout
		
		index += 1
	
	EventBus.log_updated.emit()
	_is_playing = false

func is_log_playing() -> bool:
	return _is_playing

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

func register_entity(entity : Entity, entity_info_card : EntityInfoCard) -> void:
	entity_info_card_registry[entity] = entity_info_card

func _exit_tree() -> void:
	entity_info_card_registry.clear()
