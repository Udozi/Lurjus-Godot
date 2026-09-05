class_name DrinkRule
extends Panel

var force_popup: bool = false # Minimum time a popup must show
var popup_timer: Timer = Timer.new()
var total_drink_count: int = 0
var show_start_info: bool = true


func _ready() -> void:
	add_child(popup_timer)
	popup_timer.connect("timeout",_on_timeout)
	popup_timer.start(0.1)
	
	get_parent().find_child("Room").connect("increase_drink_counter",_on_increase_drink_counter)
	$Rule.visible = false


func _on_increase_drink_counter(sips : int, game_lost : bool = false):
	visible = true	
	force_popup = true
	popup_timer.start(Settings.popup_duration)
	
	$Rule.visible = true
	$Total.visible = true
	
	if !game_lost:
		total_drink_count += sips
		Player.drunkeness += float(sips) / 10
		
		$Rule.text = "Drink " + str(sips)
		$Drink.texture = load("res://resources/art/bg/lager.png")
		
	else:
		$Rule.text = "Take a shot!"
		$Drink.texture = load("res://resources/art/bg/shot.png")
		
	$Total.text = "Total sips this game: " + str(total_drink_count)
	
	shake_icon($Drink)
	
	
func _on_timeout():
	if show_start_info:
		shake_icon($Drink)
		popup_timer.start(Settings.popup_duration/2)
	force_popup = false
	

func shake_icon(icon: Sprite2D):
	var tween: Tween = create_tween()
	var animation_length = 2/Settings.animation_speed
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(icon, "rotation_degrees", -20, animation_length)
	tween.tween_property(icon, "rotation_degrees", 20, animation_length)
	tween.tween_property(icon, "rotation_degrees", 0, animation_length)
	
	
func _input(_event: InputEvent) -> void:
	if Input.is_anything_pressed() and !force_popup:
		$StartInfo.visible = false
		show_start_info = false
		visible = false
