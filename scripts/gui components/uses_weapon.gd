extends Label

func _process(_delta: float):
	var string = "Use weapon: " + str(Player.uses_weapon)
	text = string
