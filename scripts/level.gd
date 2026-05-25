extends Node2D

@export var events: Events
@export var room: Room

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


func _process(_delta: float) -> void:
	if Input.is_anything_pressed():
		var action = Input
		handle_inputs(action)
		
