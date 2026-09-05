class_name Powerup
extends Resource

enum types {BOON_WEAPON, BOON_POTION, CURSE}

var boons_weapons = {
	"lifesteal": "On kill: Gain 1 HP",
	"patching": "On kill: Gain 2 Durability",
	"ravenous": "On kill: Gain 3 Power until discarded",
	"recycling": "Add %s Power to the next equipped weapon",
	"breaking": "Has %s extra power against Spades",
	"burning": "Has %s extra power against Diamonds",
	"renewing": "Gets full Durability after killing a %s or %s"
}

var boons_potions = {
	"delicious": "Does not cause or be affected by Potion sickness",
	"repairing": "Also adds %s to current weapon's Durability",
	"explosive": "Does not heal. Reduces the Damage of all enemies in the room",
	"overhealing": "Can heal over the Maximum health value",
	"strengthening": "Take %s less damage from the next enemy you fight"
}

var curses = {
	"stalking": "Upon flee: Stays in the room",
	"stealing": "Upon flee: Randomly discard a Hearts and a Diamonds card",
	"rallying": "While alive: increases the Damage of all other enemies in the room by %s",
	"taunting": "Must be fought before other enemies",
	"infested": "Upon death: Fills the room with smaller enemies",
	"withering": "Upon dealing damage: Reduces your max HP by 1"
}


func randomize_powerup(type):
	var d: Dictionary
	
	match type:
		types.BOON_WEAPON:
			d = boons_weapons
		types.BOON_POTION:
			d = boons_potions
		types.CURSE:
			d = curses
	
	var i = randi() % d.size()
	var key = d.keys()[i]
	var text = d.values()[i]
	var return_array = [key, text]
	
	return(return_array)
