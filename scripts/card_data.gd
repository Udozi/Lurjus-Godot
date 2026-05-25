class_name CardData
extends Resource

const SUITS = ["clubs","spades","hearts","diamonds"]

@export_group("Card Attributes")
@export var suit : String = SUITS[0]
@export var index : int = 0

@export_group("Card Powerups")
@export var powerups: Array[String] = []

var location = GameState.Location.DRAW_PILE
var value: int = index + 2
var playable: bool = true


func send_to(new_location):
	GameState.z += 1
	
	self.location = new_location


func check_new_coordinates() -> Vector2:
	
	match location:
		
		GameState.Location.DRAW_PILE:
			return CoordinatesList.DRAW_PILE_POS
			
		GameState.Location.WEAPON:
			if is_instance_valid(Player.weapon) and len(Player.weapon.cards) > 1:
				return CoordinatesList.WEAPON_ENEMY_POS
				
			else:
				return CoordinatesList.WEAPON_BASE_POS
		
	return CoordinatesList.DISCARD_PILE_POS
			

func resolve_effects():
	print("Resolving ",suit,value)
	var weapon_power: int = 0
	var weapon_durability: int = 2^32
	
	if is_instance_valid(Player.weapon):
		var current_weapon_length: int = len(Player.weapon.cards)
		if current_weapon_length > 0:
			weapon_power = Player.weapon.cards[0].card_data.value
			
		if current_weapon_length > 1:
			weapon_durability = Player.weapon.cards[-1].card_data.value

	
	if suit == "spades" or suit == "clubs":
		if Player.uses_weapon:
			if weapon_durability > value:
				Player.take_damage(max(value - weapon_power,0))	
				send_to(GameState.Location.WEAPON)							
				return "weapon used"
			else:
				Player.discard_weapon()
				Player.take_damage(value)
				send_to(GameState.Location.DISCARD_PILE)
				return "weapon broke"
		else:
			Player.take_damage(value)
			send_to(GameState.Location.DISCARD_PILE)
			return "enemy defeated"
	
	elif suit == "hearts":
		if Player.can_heal:
			Player.heal(value)
			Player.can_heal = false
	
		send_to(GameState.Location.DISCARD_PILE)
		return "healed"
	
	else:			
		send_to(GameState.Location.WEAPON)
		return "weapon equipped"
		
