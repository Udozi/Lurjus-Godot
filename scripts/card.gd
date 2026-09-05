class_name Card
extends Area2D

signal effects
signal mouseover
signal mouseoff
signal move_to_discard

@export var card_data: CardData
@export var graphics: Sprite2D
@export var value_label: Label

var card_ui_tscn: PackedScene = preload("uid://dm40migfgra3b")
var target_position = CoordinatesList.DRAW_PILE_POS
var card_ui: CardUI = card_ui_tscn.instantiate()
var destination = GameState.Location.DISCARD_PILE
var powerup1_sprite: Sprite2D
var powerup2_sprite: Sprite2D

signal card_played
signal try_escape


func _ready() -> void:
	var card_state: CardState = CardState.new()
	var pressed_state: CardState = card_ui.card_state_machine.states[card_state.State.PRESSED]
	pressed_state.card_activated.connect(_on_card_activated)
	
	#card_data.add_random_powerup()
	#card_data.add_random_powerup()
	
	if len(card_data.powerups) > 0 and len(card_data.powerups[0]) > 0:
		var loadpath = "res://resources/art/powerups/%s.png"
		var spritename = card_data.powerups[0][0] 
		powerup1_sprite = $Powerup1
		powerup1_sprite.texture = load(loadpath % spritename)
		
		if len(card_data.powerups[1]) > 0:
			spritename = card_data.powerups[1][0] 
			powerup2_sprite = $Powerup2
			powerup2_sprite.texture = load(loadpath % spritename)


func add_randomness():
	var offsets: Array[float] = [Player.drunkeness * 3, # x max offset (px)
								Player.drunkeness * 3,  # y max offset (px)
	 							Player.drunkeness / 10] # max rotation (rad)
	
	var rand_offx = randf_range(-offsets[0], offsets[0])
	var rand_offy = randf_range(-offsets[1], offsets[1])
	var rand_offset = Vector2(rand_offx, rand_offy)
	var rand_rotation = randf_range(-offsets[2], offsets[2])
	
	rotation += rand_rotation
	position += rand_offset


func update_position(new_position: Vector2):
	
	z_index = GameState.z
	
	if !card_data.skip_animation:
		disable()
		card_data.animation_going = true	
		var animation_length = 1.0 / Settings.animation_speed
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "position", new_position, animation_length)
		
		if !is_menu_card() and card_data.location == GameState.Location.DRAW_PILE:
			tween.parallel().tween_property(self, "rotation_degrees", 60, animation_length)
			tween.parallel().tween_property(self, "skew", deg_to_rad(30), animation_length)
		
		elif !is_menu_card() and card_data.location == GameState.Location.DISCARD_PILE:
			tween.parallel().tween_property(self, "rotation_degrees", 90, animation_length)
			tween.parallel().tween_property(self, "skew", 0, animation_length)
			
		else:
			tween.parallel().tween_property(self, "rotation", 0, animation_length)
			tween.parallel().tween_property(self, "skew", 0, animation_length)
		
		card_data.animation_going = false
		enable()
	
	else:
		position = new_position
		
	card_ui.update_graphics()


func form_as_deck(index: int, random = true):
	rotation = deg_to_rad(60)
	skew = deg_to_rad(30)
	position = 	Vector2(CoordinatesList.DRAW_PILE_POS.x,
						CoordinatesList.DRAW_PILE_POS.y - 2 * index)
	if random:
		add_randomness()


func discard():
	card_data.location = GameState.Location.DISCARD_PILE
	graphics.self_modulate.a = 1.0
	update_position(card_data.check_new_coordinates())
	move_to_discard.emit(self)


func play():
	
	if !is_menu_card():
		effects.emit(self)
	
	# These also happen to menu cards
	card_played.emit(self)
	card_ui.update_graphics()

	card_data.send_to(destination)
	
	if card_data.location == GameState.Location.DISCARD_PILE:
		discard()

	update_position(card_data.check_new_coordinates())


func _on_mouse_entered() -> void:
		
	if card_data.location == GameState.Location.ROOM:
		
		mouseover.emit(self)
		
	card_ui.card_state_machine.current_state.on_mouse_entered()
		
		
func _on_mouse_exited() -> void:
		
	if card_data.location == GameState.Location.ROOM:
		mouseoff.emit()
			
	card_ui.card_state_machine.current_state.on_mouse_exited()


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
				Player.update_weapon_alpha()

		

func enable():
	if card_ui.card_state_machine:
		card_ui.card_state_machine.current_state = card_ui.card_state_machine.find_child("PassiveState")
	
	
func disable():
	if card_ui.card_state_machine:
		card_ui.card_state_machine.current_state = card_ui.card_state_machine.find_child("SleepingState")
	

func is_menu_card():
	return card_data.menu_function != ""
	

func is_enabled():
	if card_ui.card_state_machine:
		var enabled: bool = false
		var state: CardState = card_ui.card_state_machine.current_state
		
		match state.state:
			state.State.PASSIVE, state.State.MOUSEOVER:
				enabled = true
		
		return enabled
