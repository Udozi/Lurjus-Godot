class_name CardUI
extends Control

@export var sound: AudioStream

@onready var card: Card = get_parent()
@onready var card_state_machine = $CardStateMachine

var tween: Tween
var card_folder : String = "res://resources/art/cards/"
var pressed_state: CardState 

func _ready() -> void:
	
	card_state_machine.init(self)
	update_graphics()
	pressed_state = $CardStateMachine/PressedState
		
func update_graphics():
	
	if card:
		if card.is_menu_card() and card.card_data.suit != "dummy":
			card.graphics.texture = load(card_folder + card.card_data.suit +".png")
			card.value_label.text = card.card_data.menu_function
			card.value_label.label_settings = load("uid://cofj8k2y33x2")
		
		elif card.card_data.suit == "dummy":
			card.graphics.texture = load(card_folder + "card_cancel.png")
		
		else:
			if card.card_data.location == GameState.Location.DRAW_PILE:
				card.graphics.texture = load(card_folder + "card_back.png")
				if card.powerup1_sprite: card.powerup1_sprite.visible = false
				card.value_label.text = ""
			
			else:
				card.graphics.texture = load(card_folder + card.card_data.suit +".png")
				if card.powerup1_sprite: card.powerup1_sprite.visible = true
				card.value_label.text = str(card.card_data.value)
				card.value_label.label_settings.font_size = 30
				
				if card.card_data.suit == "hearts" or card.card_data.suit == "diamonds":
					card.value_label.label_settings = load("uid://b6jeo0ons6j53")
				
				else:
					card.value_label.label_settings = load("uid://bpf2dypw237c8")
