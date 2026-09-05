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
		

func create_deck(suits, menu_content = null, custom_content: Array = [[]], template: Deck = null):
	
	cards.clear()
	var button_order : int = 0

	if template:
		
		template.cards = clean(template.cards)
		
		if AdventureState.round_number > 1:
			cards.clear()
			
			for card in template.cards:
				card.card_data.value = card.card_data.index + int(ceil(AdventureState.difficulty_level)) + 1
				cards.append(card)
				card.card_data.skip_animation = true
				card.card_data.location = GameState.Location.DRAW_PILE
				card.update_position(CoordinatesList.DRAW_PILE_POS)
		
		else:
			var new_cards: Array[Card] = []
			
			for card in template.cards:
				card.card_data.value = card.card_data.index + int(ceil(AdventureState.difficulty_level)) + 1
				new_cards.append(card)
				card.card_data.skip_animation = true
				card.card_data.location = GameState.Location.DRAW_PILE
				card.update_position(CoordinatesList.DRAW_PILE_POS)
				
			cards = new_cards
	
	# Custom game / Tutorial
	elif len(custom_content) > 0 and !custom_content[0].is_empty(): 
		
		for i in range(len(custom_content)):
			var new_card: Card = card_tscn.instantiate()
			
			var suit: String = custom_content[i][0]
			new_card.card_data.suit = custom_content[i][0]
			
			var index: int = int(custom_content[i][1]) - 2
			new_card.card_data.index = index
			new_card.card_data.value = index + 2

			cards.append(new_card)
			new_card.update_position(CoordinatesList.DRAW_PILE_POS)
	
	# Menu / Quick Game / New adventure
	else:
		if menu_content:
			var card_num: int = 0 # So all menu cards always appear in the same order
			
			for menu in Navigation.menus:
				button_order = 0
				
				for suit in suits:
					var new_card: Card = card_tscn.instantiate()
					new_card.card_data.suit = suit
					new_card.card_data.original_suit = suit
					new_card.card_data.menu_order = card_num
					
					if button_order < len(Navigation.menus[menu]):
						new_card.card_data.menu_function = Navigation.menus[menu][button_order]
					
					cards.append(new_card)
					new_card.update_position(CoordinatesList.DRAW_PILE_POS)
					
					button_order += 1
					card_num += 1
			
			cards = clean(cards)
			
			for card: Card in cards:
				
				if card.card_data.menu_function == "": 
					card.card_data.suit = "dummy"
			
		else: # Quick game / New adventure
			
			for suit in suits:
				var count : int = suits[suit]
				for i in count:
					var new_card: Card = card_tscn.instantiate()
					
					new_card.card_data.suit = suit
					new_card.card_data.index = i
					
					var value: int
					if GameState.game_mode == GameState.game_modes.QUICKGAME: value = i + 2
					else: value = i + 1 + int(AdventureState.difficulty_level)
					new_card.card_data.value = value
					
					cards.append(new_card)
					new_card.update_position(CoordinatesList.DRAW_PILE_POS)
	
	cards = clean(cards)
