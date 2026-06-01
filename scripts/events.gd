class_name Events
extends Resource

@export_group("Cards per suit")
@export var spades : int = 13
@export var clubs : int = 13
@export var hearts : int = 9
@export var diamonds : int = 9

@export var draw_pile_tscn: PackedScene


var one_of_all = { 
	"spades":1,
	"clubs":1,
	"hearts":1,
	"diamonds":1,
	"dummy":1
}


var suits_and_cards = {
	"spades":spades,
	"clubs":clubs,
	"hearts":hearts,
	"diamonds":diamonds
}


func open_menu(menu_content):
	
	MenuDeck.create_deck(one_of_all, menu_content)
	
	var draw_pile = start_level(MenuDeck, false)

	return draw_pile


func start_game():
	
	Player.reset()
	GameState.reset()
	
	PlayingDeck.create_deck(suits_and_cards)	
	
	var draw_pile = start_level(PlayingDeck)
	return draw_pile


func start_level(playing_deck, shuffle = true):
	
	var draw_pile = draw_pile_tscn.instantiate()
	
	
	for card in playing_deck.cards:
		draw_pile.cards.append(card)
	
	if shuffle: draw_pile.cards.shuffle()
	else: draw_pile.cards.reverse()
	
	for card in draw_pile.cards:
		draw_pile.add_child(card)
		
		card.add_child(card.card_ui)

	return draw_pile

	
	
