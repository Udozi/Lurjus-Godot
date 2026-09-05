class_name DrawPile
extends CardPile

var label: Label


func _ready() -> void:
	label = $DrawPileSize
	if len(cards) > 0 and cards[-1].is_menu_card():
		label.visible = false
	
	
func _process(_delta: float) -> void:
	if label:
		label.text = str(len(cards))
