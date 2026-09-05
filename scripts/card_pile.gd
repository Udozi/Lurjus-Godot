class_name CardPile
extends Node2D

var cards: Array[Card] = []
var card_count: int = 0


func shuffle_pile():
	cards.shuffle()
