extends Node2D

@export var events: Events
@export var room: Room
@export var drink_rule_tscn: PackedScene = preload("uid://f06tv6fp21cv")

var gui: CanvasLayer

func _ready():
	
	gui = get_node("/root/GUI")
	var board: CanvasLayer= $BoardUI
	var advance: bool = true

	# Only the top card of a pile will be selected
	get_viewport().physics_object_picking_sort = true
	get_viewport().physics_object_picking_first_only = true
	
	var draw_pile: DrawPile
	var discard_pile: DiscardPile = get_node("BoardUI/DiscardPile")
	
	$BoardUI/Foreground.visible = false
	
	if GameState.game_mode == GameState.game_modes.QUICKGAME:
		if !GameState.drinking_rules:
			$Background.texture = load("res://resources/art/bg/quickgame_bg.png")
		else:
			$Background.texture = load("res://resources/art/bg/drinkinggame_bg.png")
			var drink_popup = drink_rule_tscn.instantiate()
			board.add_child(drink_popup)
		
		draw_pile = events.start_game()
	
	elif GameState.game_mode == GameState.game_modes.CUSTOMGAME:
		$Background.texture = load("res://resources/art/bg/tutorial_bg.png")
		draw_pile = events.start_custom_game()
		$DialogueHandler.create_dialogue()
		
	elif GameState.game_mode == GameState.game_modes.ADVENTURE:
		$Background.texture = load("res://resources/art/bg/adventure_bg.png")
		$BoardUI/Foreground.visible = true
		
		if AdventureState.stored_hp <= 0:
			AdventureState.reset()
		
		if AdventureState.round_cards.is_empty():
			if AdventureState.round_number > 1:
				draw_pile = events.next_level()
			else:
				draw_pile = events.start_game()
			
		else:
			advance = false
			Player.hp = AdventureState.stored_hp
			draw_pile = events.resume_level()
			draw_pile.cards.clear()
			Player.weapon.cards.clear()
			
			for slot in room.get_children():
				room.remove_child(slot)
			
			for slot in AdventureState.room_slots:
				room.add_child(slot)
			
			room.update_slot_dict()
			var slot_coordinates = room.slot_coordinates
			
			for slot in room.room_slots:
				if slot.card != null:
					slot.card = AdventureState.round_cards.pop_back()
					slot.card.card_data.send_to(GameState.Location.ROOM)
					slot.card.update_position(slot_coordinates[slot])
					room.connect_card_signals(slot.card)
					slot.card.enable()
					
					if !slot.card.get_parent():
						draw_pile.add_child(slot.card)
			
			for card in AdventureState.round_cards:
				draw_pile.cards.append(card)
				if !card.try_escape.is_connected(room._on_try_escape):
					card.try_escape.connect(room._on_try_escape)
					card.enable()
				
				match card.card_data.location:
					GameState.Location.DISCARD_PILE:
						card.discard()
						draw_pile.cards.erase(card)
						discard_pile.cards.append(card)
					
					GameState.Location.WEAPON:
						draw_pile.cards.erase(card)
						Player.weapon.cards.append(card)
				
				if !card.get_parent():
					draw_pile.add_child(card)
					
				Player.can_escape = AdventureState.player_could_escape
			
		var text_format = "floor: %s   difficulty: %s"
		$"BoardUI/LevelInfo".text = text_format % [AdventureState.round_number, AdventureState.difficulty_level]
		
		if len(AdventureState.stored_weapon.cards) > 0:
			for i in AdventureState.stored_weapon.cards:
				for card in draw_pile.cards:
					if card == i:
						room.connect_card_signals(card)
						card.card_data.send_to(GameState.Location.WEAPON)
						card.update_position(card.card_data.check_new_coordinates())
						card.card_data.skip_animation = false
						draw_pile.cards.erase(card)
						Player.weapon.cards.append(card)
						card.card_ui.update_graphics()
			Player.uses_weapon = true
	
	room.draw_pile = draw_pile
	room.discard_pile = discard_pile
	board.add_child(draw_pile)
	
	for card in draw_pile.cards:
		if card.card_data.location != GameState.Location.ROOM:
			card.update_position(card.card_data.check_new_coordinates())
		card.card_ui.update_graphics()
		card.form_as_deck(draw_pile.cards.find(card))
	
	if Player.uses_weapon:
		var i = 0
		
		for card in Player.weapon.cards:
			
			if i < 1:
				card.update_position(CoordinatesList.WEAPON_BASE_POS)
			else:
				card.update_position(CoordinatesList.WEAPON_ENEMY_POS)
			
			Player.weapon.cards[i].z_index = -40 + i
			i += 1
	
	if advance:
		room.advance()
	
	room.update_dialog.connect(_on_update_dialog)


func _on_update_dialog():
	$DialogueHandler.row_number += 1
	var row: String = $DialogueHandler.give_row()
	var splitrow = row.split("/")
	
	var dialogue_text = splitrow[0]	
	$"BoardUI/Dialogue".text = dialogue_text
	
	if len(splitrow) > 1:
		var allow_escape = splitrow[1]
		match allow_escape:
			"false":
				room.allow_escape = false
			"true":
				room.allow_escape = true
		Player.can_escape = room.allow_escape


func handle_inputs(_input: Input):
	
	if Input.is_action_just_pressed("new_game"):
		GameState.game_mode = GameState.game_modes.QUICKGAME
		get_tree().change_scene_to_file("res://scenes/level.tscn")
		
	elif Input.is_action_just_pressed("custom_game"):
		GameState.game_mode = GameState.game_modes.CUSTOMGAME
		get_tree().change_scene_to_file("res://scenes/level.tscn")
		
	elif Input.is_action_just_pressed("new_adventure"):
		GameState.game_mode = GameState.game_modes.ADVENTURE
		AdventureState.reset()
		get_tree().change_scene_to_file("res://scenes/level.tscn")
		
	elif not GameState.game_is_over:	
		if Input.is_action_just_pressed("play_slot_w"):
			var card: Card = room.room_slots[0].card
			if card and card.is_enabled(): card.play()
			
		elif Input.is_action_just_pressed("play_slot_a"):
			var card: Card = room.room_slots[1].card
			if card and card.is_enabled(): card.play()
			
		elif Input.is_action_just_pressed("play_slot_s"):
			var card: Card = room.room_slots[2].card
			if card and card.is_enabled(): card.play()
			
		elif Input.is_action_just_pressed("play_slot_d"):
			var card: Card = room.room_slots[3].card
			if card and card.is_enabled(): card.play()
			
		elif Input.is_action_just_pressed("flee") and GameState.draw_pile_size > 0:
			room._on_try_escape()
			
		elif Input.is_action_just_pressed("toggle_weapon") and is_instance_valid(Player.weapon) and len(Player.weapon.cards) > 0:
			Player.uses_weapon = !Player.uses_weapon
			Player.update_weapon_alpha()
			
		elif Input.is_action_just_pressed("discard_draw_pile"):
			for i in range(len(room.draw_pile.cards)):
				if !room.draw_pile.cards[0].move_to_discard.is_connected(room._on_discard):
					room.draw_pile.cards[0].move_to_discard.connect(room._on_discard)
				room.draw_pile.cards[0].card_data.skip_animation = false
				room.draw_pile.cards[0].discard()
				
		elif Input.is_action_just_pressed("charge"):
			
			if !Player.charge and room.all_cards_enabled():
				Player.charge = true
				room.play_random()


func _on_settings_menu_button_pressed() -> void:
	gui.toggle_settings_menu()
	

func _process(_delta: float) -> void:
	
	if Input.is_anything_pressed():
		var action = Input
		handle_inputs(action)
