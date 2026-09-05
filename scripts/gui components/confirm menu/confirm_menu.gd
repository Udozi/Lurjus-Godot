extends Control
class_name ConfirmMenu

signal confirm
signal cancel

@export var events: Events


func _ready() -> void:
	#events.connect("hide_menus",hide_menu)
	pass


func show_menu(confirm_text: String):
	$Panel/VBoxContainer/Label.text = confirm_text
	visible = true


func hide_menu() -> void:
	visible = false


func _on_cancel_button_pressed() -> void:
	cancel.emit()
	hide_menu()


func _on_confirm_button_pressed() -> void:
	confirm.emit()
	hide_menu()
