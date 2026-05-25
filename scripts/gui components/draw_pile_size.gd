extends Label

func _ready() -> void:
	position = CoordinatesList.DRAW_PILE_SIZE_LABEL_POS

func _process(_delta: float) -> void:
	text = str(GameState.draw_pile_size)
