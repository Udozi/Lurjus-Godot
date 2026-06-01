class_name Card
extends Area2D

@export var card_data: CardData
@export var graphics: Sprite2D
@export var value_label: Label

var card_ui_tscn: PackedScene = preload("uid://dm40migfgra3b")
var target_position = CoordinatesList.DRAW_PILE_POS
var card_ui: CardUI = card_ui_tscn.instantiate()


signal card_played
signal try_escape

func _ready() -> void:
	var pressed_state = card_ui.card_state_machine.get_child(2)
	pressed_state.card_activated.connect(_on_card_activated)


func update_position(new_position: Vector2):
	
	var offsets: Array[float] = [Player.drunkeness * 3, Player.drunkeness * 3, Player.drunkeness / 10]
	rotation = randf_range(-offsets[2], offsets[2])
	
	var rand_offx = randf_range(-offsets[0], offsets[0])
	var rand_offy = randf_range(-offsets[1], offsets[1])
	var rand_offset = Vector2(rand_offx, rand_offy)
	var corrected_new_pos = new_position + rand_offset
	
	if card_data.skip_animation:
		position = corrected_new_pos
		
	else:
		disable()
		card_data.animation_going = true	
		var animation_length = 1.0 / Settings.animation_speed	
		var tween: Tween = create_tween()
		tween.tween_property(self, "position", corrected_new_pos, animation_length)
		card_data.animation_going = false
		enable()
			
	card_ui.position = position
	card_ui.update_graphics()
	z_index = GameState.z


func discard():
	card_data.location = GameState.Location.DISCARD_PILE
	update_position(card_data.check_new_coordinates())


func play():
		
	if !is_menu_card():
		print("Played ", card_data.suit, card_data.value)
		var effect = card_data.resolve_effects()
		
		match effect:
			"weapon equipped":
				Player.equip_new_weapon(self)
							
			"weapon used":
				Player.weapon.cards.append(self)
	
	# These also happen to menu cards
	card_played.emit(self)
	card_ui.update_graphics()

	update_position(card_data.check_new_coordinates())


func _on_mouse_entered() -> void:
	card_ui.card_state_machine.on_mouse_entered()


func _on_mouse_exited() -> void:
	card_ui.card_state_machine.on_mouse_exited()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	card_ui.card_state_machine.on_input(event)


func _on_card_activated():
	if !GameState.game_is_over:
		match card_data.location:
			GameState.Location.ROOM:
				play()
				
			GameState.Location.DRAW_PILE:
				try_escape.emit()
				
			GameState.Location.WEAPON:
				Player.uses_weapon = !Player.uses_weapon

		

func enable():
	if card_ui.card_state_machine:
		card_ui.card_state_machine.current_state = card_ui.card_state_machine.find_child("PassiveState")
	
	
func disable():
	if card_ui.card_state_machine:
		card_ui.card_state_machine.current_state = card_ui.card_state_machine.find_child("SleepingState")
	

func is_menu_card():
	return card_data.menu_function != ""
