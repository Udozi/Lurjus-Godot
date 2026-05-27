extends Node2D

@export var events: Events
@export var room: Room

signal try_escape


func _ready():
	
	var board: CanvasLayer= $BoardUI
	var draw_pile = events.start_game()	
	board.add_child(draw_pile)
	
	for card in draw_pile.cards:
		card.card_ui.update_graphics()	
	
	# Only the top card of a pile will be selected
	get_viewport().physics_object_picking_sort = true
	get_viewport().physics_object_picking_first_only = true
	
	room.advance(draw_pile)
	

func handle_inputs(_input: Input):
	
	if Input.is_action_just_pressed("new_game"):
		get_tree().change_scene_to_file("res://scenes/level.tscn")
	
	elif not GameState.game_is_over:	
		if Input.is_action_just_pressed("play_slot_w") and room.room_slots[0].card != null:
			room.room_slots[0].card.play()
			
		elif Input.is_action_just_pressed("play_slot_a") and room.room_slots[1].card != null:
			room.room_slots[1].card.play()
			
		elif Input.is_action_just_pressed("play_slot_s") and room.room_slots[2].card != null:
			room.room_slots[2].card.play()
			
		elif Input.is_action_just_pressed("play_slot_d") and room.room_slots[3].card != null:
			room.room_slots[3].card.play()
			
		elif Input.is_action_just_pressed("flee") and GameState.draw_pile_size > 0:
			room._on_try_escape()
			
		elif Input.is_action_just_pressed("toggle_weapon") and is_instance_valid(Player.weapon) and len(Player.weapon.cards) > 0:
			Player.uses_weapon = !Player.uses_weapon
	

func _process(_delta: float) -> void:
	if Input.is_anything_pressed():
		var action = Input
		handle_inputs(action)
		
