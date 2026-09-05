extends Node

signal game_over
signal level_clear

var game_mode = game_modes.QUICKGAME
var game_is_over: bool = false

var drinking_rules: bool = false

var z: int = 100
var cards_returned: int = 0
var draw_pile_size: int = 0

enum game_modes {QUICKGAME, CUSTOMGAME, ADVENTURE}
enum round_result {FULLVICTORY, VICTORY, FINALE, DEFEAT}
enum Location {DRAW_PILE, ROOM, WEAPON, DISCARD_PILE} # For logical transitions


func reset():
	game_is_over = false
	z = 100 # For ordering visible cards
	cards_returned = 0


func end_round():
	
	Player.charge = false
	game_is_over = true
	var result = round_result.VICTORY
	
	if Player.hp >= Player.max_hp:
		result = round_result.FULLVICTORY
	
	elif Player.hp <= 0:
		if draw_pile_size == 0:
			result = round_result.FINALE
			
		else:
			result = round_result.DEFEAT
		
	
	if game_mode == game_modes.ADVENTURE:
		match result:
			round_result.FULLVICTORY:
				pass
				
			round_result.VICTORY:
				pass
				
			round_result.FINALE:
				pass
				
			round_result.DEFEAT:
				game_over.emit(result)
				return
		
		level_clear.emit()
	
	else:		
		game_over.emit(result)
