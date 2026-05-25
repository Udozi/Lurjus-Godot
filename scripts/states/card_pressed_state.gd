extends CardState
signal card_activated

func enter() -> void:
	pass

func on_input(event: InputEvent) -> void:
	if event.is_action_released("select"):
		card_activated.emit()
		transition_requested.emit(self, CardState.State.PASSIVE)
