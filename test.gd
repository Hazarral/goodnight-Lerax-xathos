extends CanvasLayer

@onready var fire_shield_label := $VBoxContainer/Shields/FireGroup/FireShieldLabel
@onready var fire_shield_bar := $VBoxContainer/Shields/FireGroup/FireShield
@onready var hp_bar := $VBoxContainer/HPBar
@onready var hp_label := $VBoxContainer/HPBar/Label
@onready var attack_button := $VBoxContainer/Button

@export var max_fire_shield := 500
@export var current_fire_shield := max_fire_shield
@export var max_hp := 1000
@export var current_hp := max_hp
@export var damage := 75

var is_dead := false

const FIRE_SHIELD_TEXT := "%d/%d Fire Shield"
const HP_LABEL_TEXT := "%d/%d HP"

func _ready() -> void:
	fire_shield_bar.max_value = max_fire_shield
	hp_bar.max_value = max_hp
	
	update_shield_bar()
	update_hp_bar()
	attack_button.text = "Attack: %d damage" % damage

func update_hp_bar() -> void:
	if is_dead:
		hp_label.text = "DEAD!"
		hp_bar.value = 0.0
		return
	
	hp_label.text = HP_LABEL_TEXT % [current_hp, max_hp]
	hp_bar.value = current_hp

func update_shield_bar() -> void:
	if is_dead:
		print("Target already dead! Shield is of no use.")
		return
	
	fire_shield_label.text = FIRE_SHIELD_TEXT % [current_fire_shield, max_fire_shield]
	fire_shield_bar.value = current_fire_shield

func _on_button_pressed() -> void:
	if is_dead:
		print("Target already dead! You can absorb them instead.")
		return
	
	var damage_to_shield := mini(current_fire_shield, damage)
	current_fire_shield -= damage_to_shield
	current_hp = maxi(current_hp - (damage - damage_to_shield), 0)
	
	if damage_to_shield > 0:
		update_shield_bar()
		if current_fire_shield <= 0:
			print("Fire shield broken!")
	
	if current_hp <= 0:
		current_hp = 0 # Clamp nicely
		is_dead = true
		print("Target killed!")
	
	update_hp_bar()
