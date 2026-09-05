class_name Bubble
extends Sprite2D

@export var thought : Label


func appear(text: String, lethal: bool):
	thought.text = text
	if lethal:
		thought.label_settings.font_color = ("FF0000")
	visible = true
	

func disappear():
	visible = false
	thought.label_settings.font_color = ("FFFFFF")
