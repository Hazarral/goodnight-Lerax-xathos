extends CanvasLayer

@onready var hp_label := $VBoxContainer/Label
@onready var attack_button := $VBoxContainer/Button

@export var max_fire_shield := 500
@export var current_fire_shield := max_fire_shield
@export var max_hp := 1000
@export var current_hp := max_hp
@export var damage := 500

var is_dead := false

const HP_LABEL_TEXT := "%d/%d HP, %d/%d Fire Shield"

func _ready() -> void:
	update_hp_label()
	attack_button.text = "Attack: %d damage" % damage

func update_hp_label() -> void:
	if is_dead:
		hp_label.text = "DEAD!"
		return
	
	hp_label.text = HP_LABEL_TEXT % [current_hp, max_hp, current_fire_shield, max_fire_shield]

func _on_button_pressed() -> void:
	if is_dead:
		print("Target already dead! You can absorb them instead.")
		return
	
	var damage_to_shield = mini(current_fire_shield, damage)
	current_fire_shield -= damage_to_shield
	current_hp = maxi(current_hp - (damage - damage_to_shield), 0)
	
	if damage_to_shield > 0 and current_fire_shield <= 0:
		print("Fire shield broken!")
	if current_hp <= 0:
		current_hp = 0 # Clamp nicely
		is_dead = true
		print("Target killed!")
	
	update_hp_label()
