class_name Room
extends Node2D

@export var slot_w: Slot
@export var slot_a: Slot
@export var slot_s: Slot
@export var slot_d: Slot

@onready var room_slots: Array[Slot] = [slot_w, slot_a, slot_s, slot_d]

@onready var slot_coordinates= {
	slot_w : CoordinatesList.ROOM_SLOTW_POS,
	slot_a : CoordinatesList.ROOM_SLOTA_POS,
	slot_s : CoordinatesList.ROOM_SLOTS_POS,
	slot_d : CoordinatesList.ROOM_SLOTD_POS
}


func advance(draw_pile: DrawPile):
	if draw_pile:		
		for slot in room_slots:
			if !slot.card and len(draw_pile.cards) > 0:
				slot.card = draw_pile.cards.pop_back()
				slot.card.card_data.send_to(GameState.Location.ROOM)
				slot.card.update_position(slot_coordinates[slot])
				slot.card.enable()
			
				if slot.card and not slot.card.card_played.is_connected(_on_card_played):
					slot.card.card_played.connect(_on_card_played)
		
		if len(draw_pile.cards) > 0:
			var top_card: Card = draw_pile.cards[-1]
			if not top_card.try_escape.is_connected(_on_try_escape):
				top_card.try_escape.connect(_on_try_escape)
			top_card.enable()
		
		Player.can_heal = true
		GameState.draw_pile_size = len(draw_pile.cards)


func count_cards():
	var cards_left: int = 0
	
	for slot in room_slots:
		if slot.card:
			cards_left += 1
			
	#print("Cards left: ", cards_left)
	return cards_left


func _on_card_played(card: Card):
	
	var slot = Slot
	
	for roomslot in room_slots:
		if roomslot.has_the_card(card):
			slot = roomslot
	
	if slot:
		
		slot.card = null
		
		if count_cards() < 2:
			Player.can_escape = true
		
			if count_cards() == 0:
				var draw_pile: DrawPile = get_parent().get_child(7) # TODO: fix this magic number
				if draw_pile and len(draw_pile.cards) > 0:
					advance(draw_pile)
					
				else:
					GameState.end_round()
					
		else: Player.can_escape = false


func _on_try_escape():
	print("Tryna escape here")
	if Player.can_escape:
		var draw_pile: DrawPile = get_parent().get_child(7) # TODO: fix this magic number
		
		if count_cards() < 2:
			advance(draw_pile)
			
		else:
			flee()


func flee():
	
	var draw_pile: DrawPile = get_parent().get_child(7) # TODO: fix this magic number
	var returning_cards: Array[Card]
	
	for slot in room_slots:
		
		var card = slot.card
		card.disable()
		returning_cards.append(card)
		card.card_data.send_to(GameState.Location.DRAW_PILE)
		card.update_position(card.card_data.check_new_coordinates())

		card.z_index = 0
		slot.card = null
		
	returning_cards.shuffle()
	
	for card in returning_cards:
		draw_pile.cards.push_front(card)
	
	# To fix top card collision after fleeing
	for card in draw_pile.cards:
		card.z_index = draw_pile.cards.find(card)
		
	Player.can_escape = false
	advance(draw_pile)
