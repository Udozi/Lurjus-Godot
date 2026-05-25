extends Node2D

@export var max_hp : int = 20
@export var hp : int = max_hp
@export var drunkeness : float = 1

var weapon_tscn : PackedScene = preload("uid://83itocesu6hg")
var weapon : CardPile = weapon_tscn.instantiate()

var uses_weapon : bool = false
var can_escape : bool = true
var can_heal : bool = true


func toggle_weapon():
	pass


func equip_new_weapon(card):
	if is_instance_valid(Player.weapon) and len(weapon.cards) > 0:
			Player.discard_weapon()
	
	weapon.cards.append(card)	
	uses_weapon = true


func discard_weapon():	
	for card in weapon.cards:
		card.discard()
	
	weapon.cards.clear()	
	uses_weapon = false


func take_damage(damage: int):
	hp -= damage
	if hp <= 0:
		GameState.end_round()
	
	
func heal(amount: int):
	hp += amount
	if hp > max_hp: hp = max_hp
	
	
func reset():
	
	hp = max_hp
	uses_weapon = false
	can_escape = true
	can_heal = true
	weapon.cards.clear()
