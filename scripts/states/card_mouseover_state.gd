extends CardState

func enter() -> void:
	pass


func on_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		transition_requested.emit(self, CardState.State.PRESSED)
	
func on_mouse_exited():
	transition_requested.emit(self, CardState.State.PASSIVE)
