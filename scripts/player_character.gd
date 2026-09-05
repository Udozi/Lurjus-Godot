extends CharacterBody2D

@export var player_sprite: Sprite2D


func _ready() -> void:
	Player.update_character.connect(_on_update_character)


func _on_update_character(scene = "level"):
	
	if scene == "menu":
		update_sprite("menu")
	
	elif !GameState.game_is_over: 
		
		if Player.charge: update_sprite("charge")
		
		else: update_sprite("alive")
		
	else:
		update_sprite("ko")


func update_sprite(state: String):
	match state:
		"alive": 
			player_sprite.texture = load("res://resources/art/char/player.png")
			player_sprite.offset = Vector2(-250,200)
		"charge":
			player_sprite.texture = load("res://resources/art/char/player-charge.png")
			player_sprite.offset = Vector2(-250,200)
		"ko": 
			player_sprite.texture = load("res://resources/art/char/player-ko.png")
			player_sprite.offset = Vector2(-50,200)
		"menu":
			var menulevel: int = Navigation.get_menu_level()
			var sprite_str = "res://resources/art/char/menu_000%s.png"
			player_sprite.texture = load(sprite_str % str(menulevel))
			player_sprite.offset = Vector2(0,0)
			
			if menulevel == 4:
				await get_tree().create_timer(0.3).timeout
				sprite_str = "res://resources/art/char/menu_0005.png"
				player_sprite.texture = load(sprite_str)
				
				await get_tree().create_timer(0.3).timeout
				sprite_str = "res://resources/art/char/menu_0006.png"
				player_sprite.texture = load(sprite_str)
