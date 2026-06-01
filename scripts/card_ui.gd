class_name CardUI
extends Control

@export var sound: AudioStream

@onready var card: Card = get_parent()
@onready var card_state_machine: CardStateMachine = $CardStateMachine


var tween: Tween
var card_folder : String = "res://resources/art/cards/"


func _ready() -> void:
		
	card_state_machine.init(self)
	update_graphics()	

		
func update_graphics():
	
	if card:
		if card.is_menu_card():
			if card.card_data.location == GameState.Location.DRAW_PILE or card.card_data.suit == "dummy":
				card.graphics.texture = load(card_folder + "card_cancel.png")
			
			else:
				card.graphics.texture = load(card_folder + card.card_data.suit +".png")
				card.value_label.text = card.card_data.menu_function
				
		
		else:
			if card.card_data.location == GameState.Location.DRAW_PILE:
				card.graphics.texture = load(card_folder + "card_back.png")
			
			else:
				card.graphics.texture = load(card_folder + card.card_data.suit + str(card.card_data.index + 2) +".png")
