extends Label

func _process(_delta: float):
	var string = "Can escape: " + str(Player.can_escape)
	text = string
