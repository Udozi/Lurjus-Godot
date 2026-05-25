class_name CardPile
extends Node2D

@export var card_tscn: PackedScene

var cards: Array[Card] = []
		
func shuffle_pile():
	cards.shuffle()
