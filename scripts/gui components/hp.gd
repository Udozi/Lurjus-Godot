extends Label


func _ready() -> void:
	position = CoordinatesList.HP_LABEL_POS


func _process(_delta: float) -> void:
	text = str(Player.hp)
