extends Node

signal game_over

var score: int = 0
var game_is_over: bool = false

var z: int = 0
var cards_returned: int = 0
var draw_pile_size: int = 0

enum round_result {FULLVICTORY, VICTORY, FINALE, DEFEAT}
enum Location {DRAW_PILE, ROOM, WEAPON, DISCARD_PILE} # For logical transitions


func reset():
	game_is_over = false
	score = 0
	z = 0
	cards_returned = 0


func end_round():
	
	var result = round_result.VICTORY
	
	if Player.hp >= Player.max_hp:
		result = round_result.FULLVICTORY
	
	elif Player.hp <= 0:
		if draw_pile_size == 0:
			result = round_result.FINALE
			
		else:
			result = round_result.DEFEAT
		
	game_is_over = true	
	game_over.emit(result)
	
