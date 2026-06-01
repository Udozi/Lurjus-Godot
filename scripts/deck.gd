class_name Deck
extends Node2D

var card_tscn: PackedScene = preload("uid://bskp8xtr1rvol")
var cards: Array[Card] = []
			

func clean(dirty_deck: Array[Card]) -> Array[Card]:
	var clean_deck: Array[Card] = []
	for card in dirty_deck:
		if is_instance_valid(card):
			clean_deck.append(card)	
	return clean_deck
		

func create_deck(suits, menu_content = null):
	
	var button_order : int = 0
	
	for suit in suits:
		
		if menu_content:
			
			var new_card: Card = card_tscn.instantiate()
			new_card.card_data.suit = suit
			
			if button_order < len(menu_content):
				new_card.card_data.menu_function = menu_content[button_order]
			
			cards.append(new_card)				
			new_card.update_position(CoordinatesList.DRAW_PILE_POS)
			
			button_order += 1
		
		else:
			var count : int = suits[suit]
			for i in count:
				var new_card: Card = card_tscn.instantiate()
				
				new_card.card_data.suit = suit
				new_card.card_data.index = i
				var value: int = i + 2
				new_card.card_data.value = value
				
				cards.append(new_card)				
				new_card.update_position(CoordinatesList.DRAW_PILE_POS)

		cards = clean(cards)
