class_name PopupScreen
extends TextureRect

var events: Events

func _ready() -> void:
	events = preload("uid://70ms57quwy61")


func _input(_event: InputEvent) -> void:
	if visible and Input.is_action_just_pressed("flee"):
		visible = false
		AdventureState.prepare_next_level()
