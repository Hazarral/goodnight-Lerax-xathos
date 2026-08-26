extends Control

## Assign in Inspector: the Dragon's EntityTemplate (e.g. Draechen)
@export var player_template : EntityTemplate
## Assign in Inspector: the enemy/dummy EntityTemplate
@export var enemy_template : EntityTemplate
## Assign in Inspector: which Action resources the player should know this encounter
## (e.g. res://system/Actions/spells/bite.tres, claw.tres, fire_breath.tres)
@export var starting_actions : Array[Action]

var player_entity : Player
var enemy_entity_1 : Entity
var enemy_entity_2 : Entity

var log_label : RichTextLabel
var player_state_label : Label
var enemy_1_state_label : Label
var enemy_2_state_label : Label

func _ready() -> void:
	_build_test_ui()
	_spawn_entities()
	_learn_starting_actions()
	_start_combat()

	_log("=== EVENT-DRIVEN COMBAT TEST INITIALIZED ===")
	_update_display()

func _spawn_entities() -> void:
	if player_template == null:
		_log("[color=red]No player_template assigned! Assign one in the Inspector.[/color]")
		return
	if enemy_template == null:
		_log("[color=red]No enemy_template assigned! Assign one in the Inspector.[/color]")
		return

	player_entity = Player.new(player_template)
	enemy_entity_1 = Entity.new(enemy_template)
	enemy_entity_2 = Entity.new(enemy_template)

func _learn_starting_actions() -> void:
	if player_entity == null:
		return

	for action in starting_actions:
		if action:
			player_entity.learn_action(action)

func _start_combat() -> void:
	if not player_entity or not enemy_entity_1 or not enemy_entity_2:
		return

	CombatSystem.initialize_factions([player_entity], [enemy_entity_1, enemy_entity_2])

func cast_action(action : Action) -> void:
	if not action:
		return

	if not player_entity or player_entity.current_state == Entity.State.DEAD:
		_log("[color=red]Caster is dead or missing! Cannot cast.[/color]")
		return

	_log("\n[b]Cast:[/b] %s" % action.action_name)

	# Stamp the caster onto every ActionEvent this Action carries, then cast.
	action.cast(player_entity)

	_update_display()

func _entity_state_text(entity : Entity, label : String) -> String:
	if not entity:
		return "%s: [not spawned]" % label

	var text := "%s: %s | HP: %d/%d | State: %s\nShields -> " % [
		label,
		entity.template.entity_name,
		entity.current_hp,
		entity.get_max_hp(),
		"DEAD" if entity.current_state == Entity.State.DEAD else "ALIVE"
	]

	for i in range(DamageAndDoT.ELEMENT_COUNT):
		if entity.max_shields[i] > 0:
			var t_name = DamageAndDoT.DamageType.keys()[i]
			text += "[%s: %d/%d] " % [t_name, entity.current_shields[i], entity.get_max_shield(i)]

	return text

func _update_display() -> void:
	player_state_label.text = _entity_state_text(player_entity, "Player")
	enemy_1_state_label.text = _entity_state_text(enemy_entity_1, "Enemy 1")
	enemy_2_state_label.text = _entity_state_text(enemy_entity_2, "Enemy 2")

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

	player_state_label = Label.new()
	player_state_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	player_state_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(player_state_label)

	enemy_1_state_label = Label.new()
	enemy_1_state_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	enemy_1_state_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(enemy_1_state_label)
	
	enemy_2_state_label = Label.new()
	enemy_2_state_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	enemy_2_state_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(enemy_2_state_label)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox)

	# One button per Action assigned in starting_actions, built after _ready
	# reads the export values, so we defer button creation slightly.
	call_deferred("_build_action_buttons", hbox)

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

func _build_action_buttons(hbox : HBoxContainer) -> void:
	for action in starting_actions:
		if not action:
			continue

		var btn = Button.new()
		btn.text = "Cast: %s" % action.action_name
		btn.pressed.connect(func(): cast_action(action))
		hbox.add_child(btn)
