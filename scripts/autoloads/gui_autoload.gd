extends CanvasLayer

var gui_components = [
	"uid://dhq3fs4a317y3", # settings menu
	"uid://btwemupq6qsip" # gameover menu
]

var resolutions = {
	"3840x2160": Vector2i(3840,2160),
	"2560x1440": Vector2i(2560,1440),
	"1920x1080": Vector2i(1920,1080),
	"1366x768": Vector2i(1366,768),
	"1280x720": Vector2i(1280,720),
	"1440x900": Vector2i(1440,900),
	"1600x900": Vector2i(1600,900),
	"1024x600": Vector2i(1024,600),
	"800x600": Vector2i(800,600)
}

func _ready() -> void:
	for i in gui_components:
		var new_scene = load(i).instantiate()
		add_child(new_scene)
		new_scene.hide()
	GameState.game_over.connect(_on_gameover)
		
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_settings"):
		var settings_menu = get_node("Settings Menu")
		settings_menu.visible = !settings_menu.visible
		if settings_menu.visible:
			settings_menu.update_button_values()


func _on_gameover(result):
	var gameover_menu = get_node("Gameover Menu")
	
	match result:
		GameState.round_result.DEFEAT:
			gameover_menu.update_text("You lose!")
		GameState.round_result.FINALE:
			gameover_menu.update_text("Almost there!")
		GameState.round_result.VICTORY:
			gameover_menu.update_text("You win!")
		GameState.round_result.FULLVICTORY:
			gameover_menu.update_text("Perfect victory!!!")
	
	gameover_menu.visible = true

			
func center_window():
	@warning_ignore("integer_division")
	var screen_center: Vector2i = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	@warning_ignore("integer_division")
	get_window().set_position(screen_center - window_size / 2)
