extends CanvasLayer

## Shields
@onready var fire_shield_label := $VBoxContainer/Shields/FireGroup/FireShieldLabel
@onready var fire_shield_bar := $VBoxContainer/Shields/FireGroup/FireShield
@export var max_fire_shield := 500
@export var current_fire_shield := max_fire_shield

@onready var water_shield_label := $VBoxContainer/Shields/WaterGroup/WaterShieldLabel
@onready var water_shield_bar := $VBoxContainer/Shields/WaterGroup/WaterShield
@export var max_water_shield := 700
@export var current_water_shield := max_water_shield

@onready var wind_shield_label := $VBoxContainer/Shields/WindGroup/WindShieldLabel
@onready var wind_shield_bar := $VBoxContainer/Shields/WindGroup/WindShield
@export var max_wind_shield := 1000
@export var current_wind_shield := max_wind_shield

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
	setup_shield_and_hp()
	
	update_shield_bar(DamageAndDoT.DamageType.FIRE)
	update_shield_bar(DamageAndDoT.DamageType.WATER)
	update_hp_bar()
	
	fire_attack_button.text = "Attack: %d Fire damage" % fire_damage
	water_attack_button.text = "Attack: %d Water damage" % water_damage
	void_attack_button.text = "Attack: %d Void damage" % void_damage

func setup_shield_and_hp() -> void:
	fire_shield_bar.max_value = max_fire_shield
	water_shield_bar.max_value = max_water_shield
	hp_bar.max_value = max_hp

func update_hp_bar() -> void:
	if is_dead:
		hp_label.text = "DEAD!"
		hp_bar.value = 0.0
		return
	
	hp_label.text = HP_LABEL_TEXT % [current_hp, max_hp]
	hp_bar.value = current_hp

func update_shield_bar(damage_type : DamageAndDoT.DamageType) -> void:
	if is_dead:
		print("Target already dead! Shield is of no use.")
		return
	
	match damage_type:
		DamageAndDoT.DamageType.FIRE:
			fire_shield_label.text = FIRE_SHIELD_TEXT % [current_fire_shield, max_fire_shield]
			fire_shield_bar.value = current_fire_shield
		DamageAndDoT.DamageType.WATER:
			water_shield_label.text = WATER_SHIELD_TEXT % [current_water_shield, max_water_shield]
			water_shield_bar.value = current_water_shield
		_:
			print("Other damage not implemented!")
			return

func is_breached() -> bool:
	print("This is a mockup Breached detection")
	if current_fire_shield <= 0:
		print("Fire shield breached")
	if current_water_shield <= 0:
		print("Water shield breached")
		
	return current_fire_shield <= 0 or current_water_shield <= 0

func has_no_shield() -> bool:
	return max_fire_shield <= 0 and max_water_shield <= 0

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
	## 0. Void special case
	if damage_type == DamageAndDoT.DamageType.VOID and (is_breached() or has_no_shield()):
		print("A Shield breached for the Void!")
		damage_hp(incoming_damage)
		return
		
	## 1. Hit the shield first
	var damage_to_shield : int = 0
	match damage_type:
		DamageAndDoT.DamageType.FIRE:
			damage_to_shield = mini(current_fire_shield, incoming_damage)
			if damage_to_shield > 0 and current_fire_shield <= 0:
				print("Fire shield broken!")
			
			current_fire_shield -= damage_to_shield
			update_shield_bar(DamageAndDoT.DamageType.FIRE)
		DamageAndDoT.DamageType.WATER:
			damage_to_shield = mini(current_water_shield, incoming_damage)
			if damage_to_shield > 0 and current_water_shield <= 0:
				print("Water shield broken!")
			
			current_water_shield -= damage_to_shield
			update_shield_bar(DamageAndDoT.DamageType.WATER)
		_:
			print("Other damage not implemented!")
			return
	
	## 2. The surplus will go into HP
	# This is guaranteed to be non-negative
	var damage_to_hp := incoming_damage - damage_to_shield 
	damage_hp(damage_to_hp)
	
func _on_fire_attack_pressed() -> void:
	damage(DamageAndDoT.DamageType.FIRE, fire_damage)
	print("Called damage function for fire")

func _on_water_attack_pressed() -> void:
	damage(DamageAndDoT.DamageType.WATER, water_damage)


func _on_void_attack_pressed() -> void:
	damage(DamageAndDoT.DamageType.VOID, void_damage)
