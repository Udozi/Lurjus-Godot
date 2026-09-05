extends Node

var stored_hp: int
var stored_weapon: CardPile = CardPile.new()
var round_number: int = 1
var difficulty_level: float = 0
var adventure_deck: Deck 
var player_items: Array = []

# When quitting mid-round
var round_cards: Array[Card] = [] # The stored cards after an autosave.
var room_slots: Array[Slot] = [] # Stores the room cards in exact positions they were in.
var player_could_escape: bool = true


func reset():
	
	PlayingDeck.cards.clear()
	round_number = 1
	difficulty_level = 0
	stored_weapon.cards.clear()
	round_cards.clear()
	adventure_deck = null
	player_items.clear()


func prepare_next_level():
	save_deck()
	round_cards.clear()
	round_number += 1
	difficulty_level += 1
	get_tree().reload_current_scene()


func save_round_cards():
	
	round_cards.clear()
	room_slots.clear()
	stored_hp = Player.hp
	player_could_escape = Player.can_escape
	
	var discard_pile: DiscardPile = get_node("/root/Level/BoardUI/DiscardPile")
	var weapon = Player.weapon
	var room: Room = get_node("/root/Level/BoardUI/Room")
	var draw_pile: DrawPile = get_node("/root/Level/BoardUI/DrawPile")
	
	if discard_pile:
		for card in discard_pile.cards:
			round_cards.append(card)
	
	if weapon:
		for card in weapon.cards:
			round_cards.append(card)
	
	if room:
		for slot in room.room_slots:
			room_slots.append(slot)
	
	if draw_pile:
		for card in draw_pile.cards:
			if card.is_class("Area2D"):
				round_cards.append(card)


func exit_adventure():
	
	var discard_pile: DiscardPile = get_node("/root/Level/BoardUI/DiscardPile")
	var weapon = Player.weapon
	var room: Room = get_node("/root/Level/BoardUI/Room")
	var draw_pile: DrawPile = get_node("/root/Level/BoardUI/DrawPile")
	
	save_round_cards()
	
	# Remove all cards and room slots from the scene tree to store them in memory during scene change.
	
	for card in discard_pile.cards:
		draw_pile.remove_child(card)
	
	for card in weapon.cards:
		if card.get_parent():
			draw_pile.remove_child(card)
	
	room.room_slots.reverse()
	for slot in room.room_slots:
		if slot.get_parent():
			if slot.card: round_cards.append(slot.card)
			room.remove_child(slot)
	
	for child in draw_pile.get_children():
		if child.is_class("Area2D"):
			draw_pile.remove_child(child)
	
	for card in draw_pile.cards:
		if card.get_parent():
			draw_pile.remove_child(card)


func save_deck():
	adventure_deck = PlayingDeck.duplicate()
	
	var draw_pile = get_node("/root/Level/BoardUI/DrawPile")
	var discard_pile = get_node("/root/Level/BoardUI/DiscardPile")
	
	for card in Player.weapon.cards:
		
		stored_weapon.cards.append(card)
		adventure_deck.cards.append(card)
		draw_pile.remove_child(card)
	
	for card in discard_pile.cards:
		
		adventure_deck.cards.append(card)
		draw_pile.remove_child(card)



func load_deck():
	return adventure_deck
