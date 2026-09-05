class_name GameoverMenu
extends Control

@export var label: Label
@export var events: Events
	

func _ready() -> void:
	events.connect("hide_menus",hide_menu)


func update_text(string: String):
	label.text = string


func hide_menu() -> void:
	visible = false


func _on_quit_button_pressed() -> void:
	get_tree().quit()
	hide_menu()


func _on_new_game_button_pressed() -> void:
	GameState.game_mode = GameState.game_modes.QUICKGAME
	get_tree().change_scene_to_file("res://scenes/level.tscn")
	hide_menu()


func _on_play_tutorial_button_pressed() -> void:
	GameState.game_mode = GameState.game_modes.CUSTOMGAME
	get_tree().change_scene_to_file("res://scenes/level.tscn")
	hide_menu()


func _on_new_adventure_button_pressed() -> void:
	GameState.game_mode = GameState.game_modes.ADVENTURE
	AdventureState.reset()
	get_tree().change_scene_to_file("res://scenes/level.tscn")
	hide_menu()


func _on_menu_button_pressed() -> void:
	
	if GameState.game_mode == GameState.game_modes.ADVENTURE:
		AdventureState.exit_adventure()
	
	GameState.game_mode = GameState.game_modes.QUICKGAME
	
	get_tree().change_scene_to_file("res://scenes/gui components/menu/menu.tscn")
	visible = false
