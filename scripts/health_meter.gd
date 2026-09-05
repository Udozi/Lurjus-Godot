extends Sprite2D

var hp_label: Label
var health_empty: Sprite2D
var meter_tween: Tween

func _ready() -> void:
	position = CoordinatesList.HP_LABEL_POS
	hp_label = $HP
	health_empty = $HealthEmpty
	Player.update_health.connect(_on_health_updated)

func _on_health_updated() -> void:
	
	hp_label.text = str(Player.hp)
	animate_label()
	
	if meter_tween: meter_tween.kill()
	adjust_meter()

func animate_label() -> void:
	var label_tween: Tween = get_tree().create_tween()
	label_tween.tween_property(hp_label,"scale",Vector2(1.4,1.4),0.05)
	label_tween.tween_property(hp_label,"scale",Vector2(1.0,1.0),0.1)

func adjust_meter() -> void:
	
	var previous_hp = Player.hp
	if Player.previous_hp: previous_hp = Player.previous_hp
		
	var image_size: Vector2 = texture.get_size()
	var surface_level: float = image_size.y * min(1, (1 - float(Player.hp) / float(Player.max_hp)))
	var animation_length: float = abs(float(
		previous_hp - float(Player.hp))) / float(Player.max_hp) * 1.0 
	
	meter_tween = get_tree().create_tween()
	meter_tween.tween_property(health_empty,"region_rect",
		Rect2(0, 0, image_size.x, surface_level), animation_length)
	meter_tween.parallel().tween_property(health_empty,"position",
		Vector2(0, (surface_level - image_size.y)/2 ), animation_length)
	
	
	
	
