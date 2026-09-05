class_name DialogueHandler
extends Node

var row_number = 0
var dialogue: Array = []

func create_dialogue(file_path = "res://import/tutorial-dialogue.csv"):
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	while !file.eof_reached():
		
		var line = file.get_line()
		dialogue.append(line)
	
	file.close()
	row_number = 0


func give_row(row = row_number):
	if len(dialogue) > row:
		return dialogue[row]
		
	else: return ""
