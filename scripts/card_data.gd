class_name CardData
extends Resource

const SUITS = ["clubs","spades","hearts","diamonds"]

@export_group("Card Attributes")
@export var suit : String = SUITS[0]
@export var index : int = 0
@export var skip_animation: bool = true
@export var animation_going: bool = false
@export var menu_function: String = ""

@export var powerup_handler: Powerup
var powerups: Array[Array] = []

var location = GameState.Location.DRAW_PILE
var value: int = index + 2
var playable: bool = true
var original_suit = suit
var menu_order = 1


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
		
		_: return CoordinatesList.DISCARD_PILE_POS


func add_random_powerup():
	var new_powerup: Array
	match suit:
		"spades","clubs":
			new_powerup = powerup_handler.randomize_powerup(powerup_handler.types.CURSE)
		"hearts":
			new_powerup = powerup_handler.randomize_powerup(powerup_handler.types.BOON_POTION)
		"diamonds":
			new_powerup = powerup_handler.randomize_powerup(powerup_handler.types.BOON_WEAPON)
	powerups.append(new_powerup)
