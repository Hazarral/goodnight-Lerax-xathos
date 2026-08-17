extends Control

var target_entity : Entity
var player_entity : Entity

var log_label : RichTextLabel
var state_label : Label

# Test configuration
var fire_damage := 75
var water_damage := 40
var void_damage := 150

func _ready() -> void:
	# Initialize a standalone CombatSystem instance
	_build_test_ui()
	_spawn_dummy_entities()
	
	_log("=== EVENT-DRIVEN COMBAT TEST INITIALIZED ===")
	_update_display()

func _spawn_dummy_entities() -> void:
	# Create a mock player entity to act as the damage source
	var player_template := EntityTemplate.new()
	player_template.entity_name = "Player Caster"
	player_template.max_hp = 1000
	player_template.max_shields.resize(DamageAndDoT.ELEMENT_COUNT)
	player_entity = Entity.new(player_template, 1.0)
	player_entity.is_player_faction = true

	# Create the dummy target template with live test shields
	var template := EntityTemplate.new()
	template.entity_name = "Test Dummy"
	template.max_hp = 500
	
	template.max_shields.resize(DamageAndDoT.ELEMENT_COUNT)
	template.max_shields[DamageAndDoT.DamageType.FIRE] = 100
	template.max_shields[DamageAndDoT.DamageType.WATER] = 100
	
	target_entity = Entity.new(template, 1.0)
	target_entity.is_player_faction = false

func apply_attack(damage_type: DamageAndDoT.DamageType, amount: int) -> void:
	if not target_entity or target_entity.current_state == Entity.State.DEAD:
		_log("[color=red]Target is already dead! Cannot attack.[/color]")
		return
		
	var type_name = DamageAndDoT.DamageType.keys()[damage_type]
	_log("\n[b]Action:[/b] Queuing DamageEvent -> %d [color=yellow]%s[/color] damage." % [amount, type_name])
	
	# 1. Create the DamageEvent pointing to source, target, type, and amount
	var event := DamageEvent.new(player_entity, target_entity, damage_type, amount, false)
	
	# 2. Register it into the CombatSystem's queue
	CombatSystem.register_damage_event(event)
	
	# 3. Process the queue (dispatches resolve() -> take_damage / shield_cascade)
	CombatSystem.process_damage_event_queue()
	
	# Refresh display state
	_update_display()

func _update_display() -> void:
	var state_text = "Entity: %s | HP: %d/%d | State: %s\nShields -> " % [
		target_entity.template.entity_name,
		target_entity.current_hp,
		target_entity.get_max_hp(),
		"DEAD" if target_entity.current_state == Entity.State.DEAD else "ALIVE"
	]
	
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		if target_entity.template.max_shields[i] > 0:
			var t_name = DamageAndDoT.DamageType.keys()[i]
			state_text += "[%s: %d/%d] " % [t_name, target_entity.current_shields[i], target_entity.get_max_shield(i)]
			
	state_label.text = state_text

func _log(text: String) -> void:
	log_label.append_text(text + "\n")

# --- Dynamic UI Generator ---
func _build_test_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	margin.add_child(vbox)
	
	state_label = Label.new()
	state_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	state_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(state_label)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox)
	
	var btn_fire = Button.new()
	btn_fire.text = "Attack: %d Fire" % fire_damage
	btn_fire.pressed.connect(func(): apply_attack(DamageAndDoT.DamageType.FIRE, fire_damage))
	hbox.add_child(btn_fire)
	
	var btn_water = Button.new()
	btn_water.text = "Attack: %d Water" % water_damage
	btn_water.pressed.connect(func(): apply_attack(DamageAndDoT.DamageType.WATER, water_damage))
	hbox.add_child(btn_water)
	
	var btn_void = Button.new()
	btn_void.text = "Attack: %d Void" % void_damage
	btn_void.pressed.connect(func(): apply_attack(DamageAndDoT.DamageType.VOID, void_damage))
	hbox.add_child(btn_void)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	vbox.add_child(scroll)
	
	log_label = RichTextLabel.new()
	log_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_label.bbcode_enabled = true
	log_label.scroll_following = true
	scroll.add_child(log_label)
