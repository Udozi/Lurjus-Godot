class_name CardStateMachine
extends Node

@export var initial_state: CardState

var current_state: CardState
var	states := {}
var card: Card
var room: Room

func _ready() -> void:
	card = get_parent().get_parent()
	room = get_node("../../../../Room")

func init(card_ui: CardUI) -> void:
	for child: CardState in get_children():
		if child:
			states[child.state] = child
			child.transition_requested.connect(_on_transition_requested)
			child.card_ui = card_ui

	if initial_state:
		initial_state.enter()
		current_state = initial_state


func on_input(event: InputEvent) -> void:
	if current_state:
		current_state.on_input(event)
		
		
func on_gui_input(event: InputEvent) -> void:
	if current_state:
		current_state.on_gui_input(event)
		
		
func on_mouse_entered() -> void:
	if current_state:
		
		if card.card_data.location == GameState.Location.ROOM and room:
				room.show_bubble(card)
			
		current_state.on_mouse_entered()
		
		
func on_mouse_exited() -> void:
	if current_state:	
		
		if card.card_data.location == GameState.Location.ROOM and room:
			room.hide_bubble()
				
		current_state.on_mouse_exited()
		
		
func _on_transition_requested(from: CardState, to: CardState.State) -> void:

	if from != current_state:
		return
		
	if current_state:
		current_state.exit()
	
	var new_state: CardState = states[to]
	if not new_state:
		return
		
	new_state.enter()
	current_state = new_state
