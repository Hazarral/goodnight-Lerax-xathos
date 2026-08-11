extends CanvasLayer

# 1. The Model Reference
var target_entity : Entity

# 2. UI References
@onready var hp_bar := $VBoxContainer/HPBar
@onready var hp_label := $VBoxContainer/HPBar/Label

@onready var fire_attack_button := $VBoxContainer/AttackButtons/FireAttack
@onready var water_attack_button := $VBoxContainer/AttackButtons/WaterAttack
@onready var void_attack_button := $VBoxContainer/AttackButtons/VoidAttack

# Map Enum strictly to the ShieldUI scripts
var shield_nodes : Dictionary[DamageAndDoT.DamageType, ShieldUI] = {} 

@export var fire_damage := 75
@export var water_damage := 40
@export var void_damage := 100

func _ready() -> void:
	fire_attack_button.text = "Attack: %d Fire damage" % fire_damage
	water_attack_button.text = "Attack: %d Water damage" % water_damage
	void_attack_button.text = "Attack: %d Void damage" % void_damage
	
	# Register the UI components using Enum keys
	shield_nodes[DamageAndDoT.DamageType.FIRE] = $VBoxContainer/Shields/FireShield
	shield_nodes[DamageAndDoT.DamageType.WATER] = $VBoxContainer/Shields/WaterShield
	shield_nodes[DamageAndDoT.DamageType.WIND] = $VBoxContainer/Shields/WindShield
	
	# NOTE: To test this, you must instantiate target_entity here.
	target_entity = Entity.new(preload("res://system/dummy.tres"))
	init_ui()

func init_ui() -> void:
	if target_entity == null:
		push_error("target_entity is null. Cannot initialize UI.")
		return

	hp_bar.max_value = target_entity.template.max_hp
	
	for damage_type : DamageAndDoT.DamageType in shield_nodes:
		var max_shield : int = target_entity.template.max_shields[damage_type]
		
		# Setup UI only (logic remains in Entity)
		shield_nodes[damage_type].setup_visuals(damage_type, max_shield)
		
	refresh_all_ui()

func refresh_all_ui() -> void:
	if not target_entity: 
		return
	
	# Update HP
	if target_entity.is_dead:
		hp_label.text = "DEAD!"
		hp_bar.value = 0.0
	else:
		hp_label.text = "%d/%d HP" % [target_entity.current_hp, target_entity.template.max_hp]
		hp_bar.value = target_entity.current_hp

	# Update Shields
	for damage_type : DamageAndDoT.DamageType in shield_nodes:
		var current_shield: int = target_entity.current_shields[damage_type]
		var max_shield: int = target_entity.template.max_shields[damage_type]
		
		shield_nodes[damage_type].update_visuals(damage_type, current_shield, max_shield)

# --- Input Handling ---

func apply_attack(damage_type: DamageAndDoT.DamageType, amount: int) -> void:
	if not target_entity or target_entity.is_dead:
		return
		
	# 1. Funnel attack into the Entity
	target_entity.take_damage(damage_type, amount)
	
	# 2. Re-sync the View
	refresh_all_ui()

func _on_fire_attack_pressed() -> void:
	apply_attack(DamageAndDoT.DamageType.FIRE, fire_damage)

func _on_water_attack_pressed() -> void:
	apply_attack(DamageAndDoT.DamageType.WATER, water_damage)

func _on_void_attack_pressed() -> void:
	apply_attack(DamageAndDoT.DamageType.VOID, void_damage)
