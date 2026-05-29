extends Control

@export var label: Label
	

func update_text(string: String):
	label.text = string


func _on_quit_button_pressed() -> void:
	get_tree().quit()
	visible = false


func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")
	visible = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("new_game"):
		_on_new_game_button_pressed()
