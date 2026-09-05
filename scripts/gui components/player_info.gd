extends Label

func _process(_delta: float):
	var canheal = "Can heal: " + str(Player.can_heal)
	var canescape = "Can escape: " + str(Player.can_escape)
	var usesweapon = "Uses weapon: " + str(Player.uses_weapon)
	text = str(canheal, "\n", canescape, "\n", usesweapon)  
