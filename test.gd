extends CanvasLayer

## Shields

## HP
@onready var hp_bar := $VBoxContainer/HPBar
@onready var hp_label := $VBoxContainer/HPBar/Label
@export var max_hp := 1000
@export var current_hp := max_hp
var is_dead := false

## Attacks
@onready var fire_attack_button := $VBoxContainer/AttackButtons/FireAttack
@export var fire_damage := 75

@onready var water_attack_button := $VBoxContainer/AttackButtons/WaterAttack
@export var water_damage := 40

@onready var void_attack_button := $VBoxContainer/AttackButtons/VoidAttack
@export var void_damage := 100

## Text
const FIRE_SHIELD_TEXT := "%d/%d Fire Shield"
const WATER_SHIELD_TEXT := "%d/%d Water Shield"
const HP_LABEL_TEXT := "%d/%d HP"

func _ready() -> void:
	update_hp_bar()
	
	fire_attack_button.text = "Attack: %d Fire damage" % fire_damage
	water_attack_button.text = "Attack: %d Water damage" % water_damage
	void_attack_button.text = "Attack: %d Void damage" % void_damage

func update_hp_bar() -> void:
	if is_dead:
		hp_label.text = "DEAD!"
		hp_bar.value = 0.0
		return
	
	hp_label.text = HP_LABEL_TEXT % [current_hp, max_hp]
	hp_bar.value = current_hp

func damage_hp(damage_to_hp : int) -> void:
	current_hp = maxi(0, current_hp - damage_to_hp)
	if current_hp <= 0:
		print("Target killed!")
		is_dead = true
	
	update_hp_bar()

func damage(damage_type : DamageAndDoT.DamageType, incoming_damage : int) -> void:
	if is_dead:
		print("Target already dead! You can absorb them instead.")
		return
	
	print("Damage function not implemented")
	
func _on_fire_attack_pressed() -> void:
	damage(DamageAndDoT.DamageType.FIRE, fire_damage)
	print("Called damage function for fire")

func _on_water_attack_pressed() -> void:
	damage(DamageAndDoT.DamageType.WATER, water_damage)


func _on_void_attack_pressed() -> void:
	damage(DamageAndDoT.DamageType.VOID, void_damage)
