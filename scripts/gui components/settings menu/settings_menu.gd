class_name SettingsMenu
extends Control

@export var events: Events

@onready var resolutions_option_button: OptionButton = $Panel/HBoxContainer/VBoxContainer/OptionButton
	
func _ready() -> void:
	events.connect("hide_menus",hide_menu)
	add_resolutions()


func add_resolutions():
	for r in GUI.resolutions:
		resolutions_option_button.add_item(r)
		
		
func update_button_values():
	var window_size_string = str(get_window().size.x, "x", get_window().size.y)
	var resolutions_index = GUI.resolutions.keys().find(window_size_string)
	resolutions_option_button.selected = resolutions_index


func _on_option_button_item_selected(index):
	var key = resolutions_option_button.get_item_text(index)
	
	if GUI.resolutions[key]:
		get_window().set_size(GUI.resolutions[key])
		GUI.center_window()

func _on_full_screen_toggled(toggled_on: bool) -> void:
	if toggled_on: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		$Panel/HBoxContainer/VBoxContainer/OptionButton.disabled = true
		
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		$Panel/HBoxContainer/VBoxContainer/OptionButton.disabled = false
		

func show_menu():
	visible = true
	resolutions_option_button.selected = 0


func hide_menu() -> void:
	visible = false


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_resume_button_pressed() -> void:
	hide_menu()


func _on_menu_button_pressed() -> void:
	
	if GameState.game_mode == GameState.game_modes.ADVENTURE:
		AdventureState.exit_adventure()
	
	GameState.game_mode = GameState.game_modes.QUICKGAME
	get_tree().change_scene_to_file("res://scenes/gui components/menu/menu.tscn")
	visible = false
	
