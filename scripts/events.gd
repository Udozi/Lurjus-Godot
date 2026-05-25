class_name Events
extends Resource

@export_group("Cards per suit")
@export var spades : int = 13
@export var clubs : int = 13
@export var hearts : int = 9
@export var diamonds : int = 9

@export var draw_pile_tscn: PackedScene


var suits_and_cards = {
	"spades":spades,
	"clubs":clubs,
	"hearts":hearts,
	"diamonds":diamonds
}


func start_game():
	
	Player.reset()
	GameState.reset()
	
	PlayingDeck.create_deck(suits_and_cards)	
	
	var draw_pile = start_level(PlayingDeck)
	return draw_pile


func start_level(playing_deck):
	
	var draw_pile = draw_pile_tscn.instantiate()
	
	
	for card in playing_deck.cards:
		draw_pile.cards.append(card)
	
	draw_pile.cards.shuffle()
	
	for card in draw_pile.cards:
		draw_pile.add_child(card)
		
		card.add_child(card.card_ui)

	return draw_pile

	
	
