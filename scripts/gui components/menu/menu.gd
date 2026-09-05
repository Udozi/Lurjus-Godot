class_name Menu
extends Node2D

@export var events: Events
@export var room_tscn: PackedScene = preload("uid://dvhb3hskrlpb6")

var current_menu = Navigation.target_menu
var menu_level: int
var draw_pile: DrawPile
var discard_pile: DiscardPile = DiscardPile.new()
var room: Room


func _ready():
	
	Navigation.menu_name = "main"
	current_menu = Navigation.menus[Navigation.menu_name]
	draw_pile = events.open_menu(current_menu)
	
	# Only the top card of a pile will be selected
	get_viewport().physics_object_picking_sort = true
	get_viewport().physics_object_picking_first_only = true
	
	$BG.texture = load("res://resources/art/bg/mainmenu.png")
	var board: CanvasLayer= $MenuUI
	room = room_tscn.instantiate()
	room.draw_pile = draw_pile
	room.discard_pile = discard_pile
	room.change_menu.connect(change_menu)
	GUI.confirm_menu.confirm.connect(_on_confirm)
	GUI.confirm_menu.cancel.connect(_on_cancel)
	
	board.add_child(room)
	board.add_child(draw_pile)
	
	draw_menu()


func draw_menu():
	
	GameState.game_is_over = false
	Player.can_escape = true
	room.advance()


func change_menu():
	
	current_menu = Navigation.target_menu
	
	for card in draw_pile.cards:

		if !card.card_data.menu_function in current_menu:
			card.card_data.suit = "dummy"
			card.value_label.visible = false
		else:
			card.card_data.suit = card.card_data.original_suit
			card.value_label.visible = true
		
		card.card_ui.update_graphics()
	
	room.draw_pile.cards.sort_custom(sort_by_menu_order)
	
	draw_menu()


func sort_by_menu_order(a: Card, b: Card):
	
	if a.card_data.menu_order > b.card_data.menu_order:
		return true
		
	return false


func _on_cancel():
	Navigation.get_upper_menu()
	
	#if len(room.discard_pile.cards) > 0:
	var upper_menu_card: Card = discard_pile.cards.pop_back()
	if upper_menu_card: 

		if draw_pile.cards.find(upper_menu_card):
			draw_pile.cards.erase(upper_menu_card)
		draw_pile.cards.append(upper_menu_card)
	
	Navigation.go_to_menu(Navigation.menu_name)
	change_menu()


func _on_confirm():
	jump_to_game(Navigation.menu_name)


func jump_to_game(menu: String = ""):
	
	Navigation.menu_name = "jump in"
	Player.update_menu_sprite()
	await Player.has_jumped
	
	match menu:
		"new adventure":
			GameState.game_mode = GameState.game_modes.ADVENTURE
			GameState.drinking_rules = false
			AdventureState.round_cards.clear()
			AdventureState.reset()
			get_tree().change_scene_to_file("res://scenes/level.tscn")
		
		"continue":
			GameState.game_mode = GameState.game_modes.ADVENTURE
			GameState.drinking_rules = false
			get_tree().change_scene_to_file("res://scenes/level.tscn")
		
		"normal mode":
			GameState.game_mode = GameState.game_modes.QUICKGAME
			GameState.drinking_rules = false
			get_tree().change_scene_to_file("res://scenes/level.tscn")
		
		"drinking game":
			GameState.game_mode = GameState.game_modes.QUICKGAME
			GameState.drinking_rules = true
			get_tree().change_scene_to_file("res://scenes/level.tscn")
		
		"tutorial":
			GameState.game_mode = GameState.game_modes.CUSTOMGAME
			get_tree().change_scene_to_file("res://scenes/level.tscn")
			
		"main":
			get_tree().quit()


func handle_inputs():
	
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
	
	elif Input.is_action_just_pressed("play_slot_w"):
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
		

func _on_settings_menu_button_pressed() -> void:
	GUI.toggle_settings_menu()


func _input(_event: InputEvent) -> void:
	if Input.is_anything_pressed():
		handle_inputs()
