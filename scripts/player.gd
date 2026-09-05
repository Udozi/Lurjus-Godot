extends Node2D

signal update_character
signal update_health
signal has_jumped

@export var max_hp : int = 20
@export var drunkeness : float
@export var bubble : Sprite2D

var previous_hp
var hp : int = max_hp:
	set(new_value):
		hp = new_value
		
		if hp <= 0: GameState.end_round()
		
		elif hp > max_hp: 
			hp = max_hp
		
		update_character.emit()
		update_health.emit()
		
		previous_hp = hp

var charge : bool = false:
	set(new_value):
		charge = new_value
		
		if new_value:
			update_character.emit()

var weapon_tscn : PackedScene = preload("uid://83itocesu6hg")
var weapon : CardPile = weapon_tscn.instantiate()

var uses_weapon : bool = false
var can_escape : bool = true
var can_heal : bool = true


func update_menu_sprite():
	update_character.emit("menu")
	
	if Navigation.menu_name == "jump in":
		await get_tree().create_timer(1.0).timeout
		has_jumped.emit()


func update_weapon_alpha():
	var alpha: float = 1.0
	if !uses_weapon:
		alpha = 0.3
	
	for card in weapon.cards:
		card.graphics.self_modulate.a = alpha


func show_bubble():
	bubble.visible = true
	
	
func hide_bubble():
	bubble.visible = false


func equip_new_weapon(card):
	if is_instance_valid(weapon) and len(weapon.cards) > 0:
		discard_weapon()
	
	weapon.cards.append(card)	
	uses_weapon = true


func discard_weapon():
	if GameState.game_mode == GameState.game_modes.ADVENTURE:
		AdventureState.stored_weapon.cards.clear()
	
	for card in weapon.cards:
		card.discard()
	
	weapon.cards.clear()
	uses_weapon = false


func take_damage(damage: int):
	hp -= damage
	
	
func heal(amount: int):
	hp += amount
	
	
func reset():
	
	hp = max_hp
	previous_hp = hp
	uses_weapon = false
	can_escape = true
	can_heal = true
	charge = false
	weapon.cards.clear()
	drunkeness = Settings.initial_drunkeness
	update_character.emit()
	update_health.emit()


func next_level():
	hp = max(hp, ceil(max_hp * 0.5)) # Heals to at least 50% 
	previous_hp = hp
	weapon.cards.clear()
	uses_weapon = false
	can_escape = true
	can_heal = true
	charge = false
	update_character.emit()
	update_health.emit()
