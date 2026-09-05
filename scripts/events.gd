class_name Events
extends Resource

signal hide_menus

@export_group("Cards per suit")
@export var spades : int = 13
@export var clubs : int = 13
@export var hearts : int = 9
@export var diamonds : int = 9

@export var draw_pile_tscn: PackedScene

var tutorial_deck_path: String = "res://import/tutorial-deck.csv"
var draw_pile: DrawPile


var suits_and_cards = {
	"spades":spades,
	"clubs":clubs,
	"hearts":hearts,
	"diamonds":diamonds
}


func read_csv(file_path):
	
	var content : Array = []
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	while !file.eof_reached():
		var line = file.get_line()
		var splitline = line.split(",")
		if len(splitline) > 1: content.append(splitline)
	
	file.close()
	
	return content
	

func open_menu(menu_content):
	
	MenuDeck.create_deck(suits_and_cards, menu_content)
	
	draw_pile = start_level(MenuDeck, false)

	return draw_pile


func start_game():
	
	GameState.reset()
	Player.reset()
	
	if GameState.game_mode == GameState.game_modes.ADVENTURE:
		if len(PlayingDeck.cards) > 0:
			PlayingDeck.create_deck(suits_and_cards,null,[],PlayingDeck)
			
		else:
			PlayingDeck.create_deck(suits_and_cards)
		
	else:
		GameState.game_mode = GameState.game_modes.QUICKGAME
		PlayingDeck.create_deck(suits_and_cards)
	
	hide_menus.emit()
	draw_pile = start_level(PlayingDeck)
	return draw_pile


func start_custom_game(path = tutorial_deck_path):
	
	GameState.reset()
	Player.reset()
	
	GameState.game_mode = GameState.game_modes.CUSTOMGAME
	var content = read_csv(path)
	PlayingDeck.create_deck(suits_and_cards,false,content)		
	
	hide_menus.emit()
	draw_pile = start_level(PlayingDeck, false)
	return draw_pile


func resume_level():
	draw_pile = draw_pile_tscn.instantiate()
	return draw_pile


func next_level():
	
	GameState.reset()
	Player.next_level()
	
	var adventure_deck = AdventureState.load_deck()
	PlayingDeck.create_deck(suits_and_cards,null,[],adventure_deck)
	draw_pile = start_level(PlayingDeck)
	
	return draw_pile


func start_level(playing_deck, shuffle = true):
	
	draw_pile = draw_pile_tscn.instantiate()
	
	for card in playing_deck.cards:		
		if card: 
			draw_pile.cards.append(card)
	
	for card in draw_pile.cards:
		
		if card.get_parent(): card.reparent(draw_pile)
		else: draw_pile.add_child(card)
		
		if !card.card_ui.get_parent():
			card.add_child(card.card_ui)
	
	if shuffle: draw_pile.cards.shuffle()
	else: draw_pile.cards.reverse()
	
	return draw_pile

	
	
