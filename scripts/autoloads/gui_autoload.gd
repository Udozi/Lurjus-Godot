extends CanvasLayer

var wait_for_animation: bool = false

var settings_menu: SettingsMenu
var gameover_menu: GameoverMenu
var confirm_menu: ConfirmMenu

var round_completed_screen: PopupScreen

var gui_components = [
	"uid://dhq3fs4a317y3", # settings menu
	"uid://btwemupq6qsip", # gameover menu
	"uid://cscw3q55sqv7v", # confirm menu
	"uid://072kjo6gnlba" # round completed screen
]

var resolutions = {
	"Resolution": null,
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
	GameState.level_clear.connect(_on_level_clear)
	
	round_completed_screen = get_node("RoundCompleteScreen")
	settings_menu = get_node("Settings Menu")
	gameover_menu = get_node("Gameover Menu")
	confirm_menu = get_node("Confirm Menu")
		
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_settings"):
		
		toggle_settings_menu()


func _on_level_clear():
	round_completed_screen.visible = true


func _on_gameover(result):
	
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
	settings_menu.hide_menu()


func toggle_settings_menu():
	if !settings_menu.visible:
		settings_menu.z_index = 1000
		settings_menu.show_menu()
		gameover_menu.hide_menu()
		confirm_menu.hide_menu()
	else:
		if GameState.game_is_over:
			gameover_menu.visible = true

		settings_menu.hide_menu()

			
func center_window():
	@warning_ignore("integer_division")
	var screen_center: Vector2i = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	@warning_ignore("integer_division")
	get_window().set_position(screen_center - window_size / 2)
