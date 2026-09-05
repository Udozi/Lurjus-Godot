class_name Room
extends Node2D

signal update_dialog
signal increase_drink_counter
signal change_menu

@export var slot_w: Slot
@export var slot_a: Slot
@export var slot_s: Slot
@export var slot_d: Slot

@export var bubble: Bubble

var allow_escape: bool = true
var draw_pile: DrawPile 
var discard_pile: DiscardPile

@onready var room_slots: Array[Slot] = [slot_w, slot_a, slot_s, slot_d]

@onready var slot_coordinates= {
	slot_w : CoordinatesList.ROOM_SLOTW_POS,
	slot_a : CoordinatesList.ROOM_SLOTA_POS,
	slot_s : CoordinatesList.ROOM_SLOTS_POS,
	slot_d : CoordinatesList.ROOM_SLOTD_POS
}


func update_slot_dict():
	slot_w = get_child(0)
	slot_a = get_child(1)
	slot_s = get_child(2)
	slot_d = get_child(3)
	
	room_slots = [slot_w, slot_a, slot_s, slot_d]
	
	slot_coordinates = {
	slot_w : CoordinatesList.ROOM_SLOTW_POS,
	slot_a : CoordinatesList.ROOM_SLOTA_POS,
	slot_s : CoordinatesList.ROOM_SLOTS_POS,
	slot_d : CoordinatesList.ROOM_SLOTD_POS
}


func update_card_indices():
	for card in draw_pile.cards:
		if card and !card.is_menu_card() and card.card_data.suit != "dummy":
			var index = draw_pile.cards.find(card)
			card.z_index = 50 + index
			card.form_as_deck(index, true)


func advance():
	# Draw cards from the draw pile into the room
	var top_card: Card
	
	update_slot_dict()
	update_card_indices()
	
	if draw_pile and !GameState.game_is_over:
		for slot in room_slots:
			if len(draw_pile.cards) > 0:
				top_card = draw_pile.cards[-1]
				
				if top_card.card_data.suit == "dummy":
					for card in draw_pile.cards:
						if card.card_data.suit != "dummy":
							card.update_position(card.target_position)
							draw_pile.cards.erase(card)
							draw_pile.cards.push_back(card)
							top_card = card
				
				if !slot.card and top_card.card_data.suit != "dummy":
					slot.card = draw_pile.cards.pop_back()
					slot.card.card_data.send_to(GameState.Location.ROOM)
					slot.card.card_data.skip_animation = false
					slot.card.update_position(slot_coordinates[slot])
					slot.card.disable()
					
					var wait_time: float = 1.0 / (Settings.animation_speed * 2)
					await get_tree().create_timer(wait_time).timeout
				
					if slot.card and not slot.card.card_played.is_connected(_on_card_played):
						slot.card.card_played.connect(_on_card_played)
		
		Player.can_heal = true
		GameState.draw_pile_size = len(draw_pile.cards)
		
		if GameState.game_mode == GameState.game_modes.CUSTOMGAME:
			update_dialog.emit()
		
		elif GameState.game_mode == GameState.game_modes.ADVENTURE:
			AdventureState.save_round_cards()
		
		for slot in room_slots:
			if slot.card:
				slot.card.enable()
				connect_card_signals(slot.card)
				
		for card in draw_pile.cards:
			card.enable()
			if not card.try_escape.is_connected(_on_try_escape):
				card.try_escape.connect(_on_try_escape)
				
		if Player.charge:
			play_random()


func all_cards_enabled():
	var allenabled = true
	
	for slot in room_slots:
		if slot.card and !slot.card.is_enabled():
			allenabled = false
			
	return allenabled


func balance_next_room():
	
	# Escaping from a room full of enemies guarantees at least one weapon or potion in the next room
	# if any in deck
	
	var reds_found: bool = false

	for card in draw_pile.cards:
		if !reds_found and (card.card_data.suit == "hearts" or card.card_data.suit == "diamonds"):
			reds_found = true	
			
			draw_pile.cards.pop_at(draw_pile.cards.find(card))
			draw_pile.cards.append(card)


func connect_card_signals(card: Card):
	
	if not card.effects.is_connected(resolve_effects):
		card.effects.connect(resolve_effects)
	if not card.mouseover.is_connected(show_bubble):
		card.mouseover.connect(show_bubble)
	if not card.mouseoff.is_connected(hide_bubble):
		card.mouseoff.connect(hide_bubble)
	if not card.move_to_discard.is_connected(_on_discard):
		card.move_to_discard.connect(_on_discard)
	if not card.card_played.is_connected(_on_card_played):
		card.card_played.connect(_on_card_played)


func count_cards():
	var cards_and_enemies_left : Array[int] = [] 
	var cards_left: int = 0
	var enemies_left: int = 0
	
	for slot in room_slots:
		if slot.card:
			cards_left += 1
			if slot.card.card_data.suit == "spades" or slot.card.card_data.suit == "clubs":
				enemies_left += 1
	
	cards_and_enemies_left.append(cards_left)
	cards_and_enemies_left.append(enemies_left)
	return cards_and_enemies_left


func _on_discard(card):
	draw_pile.cards.erase(card)
	discard_pile.cards.append(card)


func resolve_effects(card, preview = false): # Resolve a card's effects when played
	var card_data = card.card_data
	var suit = card_data.suit
	var value = card_data.value
	var weapon_power: int = 0
	var weapon_durability: int = 2^32
	
	var action: String = "enemy defeated" # string to return
	
	if is_instance_valid(Player.weapon):
		var current_weapon_length: int = len(Player.weapon.cards)
		if current_weapon_length > 0:
			weapon_power = Player.weapon.cards[0].card_data.value
			
		if current_weapon_length > 1:
			weapon_durability = Player.weapon.cards[-1].card_data.value

	
	match suit:
		"spades","clubs":
			
			var damage = 0
			if Player.uses_weapon:
				if weapon_durability > value:
					damage = max(value - weapon_power,0)
					card.destination = GameState.Location.WEAPON
					action = "weapon used"
				else:
					damage = value
					card.destination = GameState.Location.DISCARD_PILE
					action = "weapon broke"
			else:
				damage = value
				card.destination = GameState.Location.DISCARD_PILE
			
			if preview:
				return damage
				
			else:
				Player.take_damage(damage)
				
				if GameState.drinking_rules:
					calculate_drink_rule(card_data)
	
		"hearts":
			if preview:
				if Player.can_heal:
					return min(Player.max_hp - Player.hp, value)
				else:
					return 0
			
			else:
				if GameState.drinking_rules:
					calculate_drink_rule(card_data)
				
				if Player.can_heal:
					Player.heal(value)
					Player.can_heal = false
		
				card.destination = GameState.Location.DISCARD_PILE
				action = "healed"
	
		_:
			# Playing a Diamonds card
			if preview:
				return
			
			else:
				if GameState.drinking_rules:
					calculate_drink_rule(card_data)
				
				card.destination = GameState.Location.WEAPON
				action = "weapon equipped"
	
	if !preview:
		
		match action:
			"weapon equipped":
				Player.equip_new_weapon(card)
			
			"weapon used":
				Player.weapon.cards.append(card)
				
			"weapon broke":
				Player.discard_weapon()


func _on_card_played(card: Card):
	
	hide_bubble()
	
	if card.is_menu_card():
		flee(0, card.card_data.menu_function)
		
	var slot: Slot
	
	for roomslot in room_slots:
		if roomslot.has_the_card(card):
			slot = roomslot
	
	if slot:
		
		slot.card = null
		var cards_and_enemies_left: Array[int] = count_cards()
		var cards_left: int = cards_and_enemies_left[0]
		
		if cards_left < 2:
			Player.can_escape = allow_escape
		
			if cards_left == 0:
				if draw_pile and len(draw_pile.cards) > 0:
					advance()
					
				else:
					GameState.end_round()
					
		else: Player.can_escape = false


func _on_try_escape():
	if Player.can_escape:
		
		var cards_and_enemies_left: Array[int] = count_cards()
		var cards_left: int = cards_and_enemies_left[0]
		var enemies_left: int = cards_and_enemies_left[1]
		
		if cards_left < 2:
			advance()
			
		elif room_slots[0].card and room_slots[0].card.is_menu_card():
			flee(0,"cancel")
			
		else:
			flee(enemies_left)


func flee(enemy_count: int, menu_function = ""):
	
	var returning_cards: Array[Card]
	
	for slot in room_slots:
		
		var card = slot.card
		if card:
			card.disable()
			returning_cards.append(card)
			card.card_data.send_to(GameState.Location.DRAW_PILE)
			card.update_position(card.card_data.check_new_coordinates())
			card.z_index = 0
			
		slot.card = null
		
		var wait_time: float = 1.0 / (Settings.animation_speed * 2)
		if get_tree():
			await get_tree().create_timer(wait_time).timeout
		
	returning_cards.shuffle()
	
	for card in returning_cards:
		draw_pile.cards.push_front(card)
	
	if menu_function:
		resolve_menu_command(menu_function)
	
	# To fix top card collision after fleeing
	for card in draw_pile.cards:
		card.z_index = draw_pile.cards.find(card)
	
	if !menu_function:
		if enemy_count == len(room_slots):
			balance_next_room()
		
		advance()
		Player.can_escape = false


func play_random():
	var card_played = false
	
	while !card_played:
		var rand = randi_range(0,len(room_slots) - 1)
		if room_slots[rand].card: 
			room_slots[rand].card.play()
			
			card_played = true
			
			for slot in room_slots:
				if slot.card:
					slot.card.discard()
					slot.card = null
	
	if len(draw_pile.cards) > 0:
		advance()
		
	else:
		if count_cards()[0] == 0:
			GameState.end_round()


func resolve_menu_command(menu_function):
	match menu_function:
		
		# Lower menu
		"quickgame","extras","adventure":
			Navigation.go_to_menu(menu_function)
		
		"new adventure", "continue", "normal mode", "drinking game", "tutorial":
			Navigation.go_to_menu(menu_function)
			var confirm_text = Navigation.menu_confirms[Navigation.menu_name]
			GUI.confirm_menu.show_menu(confirm_text)

		# Upper menu
		_: 
			Navigation.get_upper_menu()
			var upper_manu_card: Card = discard_pile.cards.pop_back()
			if upper_manu_card: draw_pile.cards.append(upper_manu_card)
			
			if menu_function != "cancel":
				upper_manu_card.update_position(CoordinatesList.DRAW_PILE_POS)
				upper_manu_card = discard_pile.cards.pop_back()
				if upper_manu_card: draw_pile.cards.append(upper_manu_card)
				
			Navigation.go_to_menu(Navigation.menu_name)
	
	# Change to lower or upper menu
	change_menu.emit()


func calculate_drink_rule(cd: CardData):
	var sips: int = 0
	var game_lost: bool = false
	
	match cd.suit:
		"hearts": # 1 sip for each wasted HP
			if Player.can_heal:
				sips = max(Player.hp + cd.value - Player.max_hp, 0)
			else:
				sips = cd.value
		"diamonds": # Sips equal to unused discarded weapon's value
			if len(Player.weapon.cards) == 1:
				sips = Player.weapon.cards[0].card_data.value
			
	if Player.hp <= 0 and len(draw_pile.cards) > 0:
		game_lost = true
		
	if sips > 0 or game_lost:
		increase_drink_counter.emit(sips, game_lost)


func calculate_thought(card: Card):
	var result: String = ""
	var lethal: bool = false
	var effect = resolve_effects(card, true)
	
	match card.card_data.suit:
		"hearts":
			var base = "+%s"
			result = base % effect
			
		"clubs","spades":
			var base = "-%s"
			result = base % effect
			
			if effect >= Player.hp: lethal = true
			
	var return_array: Array
	return_array.append(result)
	return_array.append(lethal)
	return return_array


func show_bubble(card: Card):
	if bubble and !GameState.game_is_over:
		var thought: String = ""
		var lethal: bool = false
		
		if !GameState.game_is_over:
			var result_array = calculate_thought(card)
			if result_array:
				thought = result_array[0]
				lethal = result_array[1]
		
		if thought != "":
			bubble.appear(thought, lethal)


func hide_bubble():
	if bubble:
		bubble.disappear()
