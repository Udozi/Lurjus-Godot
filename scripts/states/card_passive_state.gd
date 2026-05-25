extends CardState

func enter() -> void:
	if not card_ui.is_node_ready():
		await card_ui.ready


func on_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):		
		transition_requested.emit(self, CardState.State.PRESSED)
	
	
func on_mouse_entered():
	transition_requested.emit(self, CardState.State.MOUSEOVER)
