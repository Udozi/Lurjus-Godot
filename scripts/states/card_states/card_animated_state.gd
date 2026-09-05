extends CardState

func on_input(event: InputEvent) -> void:
	if event.is_action_released("select"):
		transition_requested.emit(self, CardState.State.PASSIVE)
