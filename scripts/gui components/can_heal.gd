extends Label

func _process(_delta: float):
	var string = "Can heal: " + str(Player.can_heal)
	text = string
