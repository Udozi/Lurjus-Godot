extends Node

var menus = {
	"main": ["tutorial","quickgame","adventure","extras"],
	"quickgame": ["normal mode","drinking game"],
	"adventure": ["new adventure","continue"],
	"extras": ["credits","achievements","artbook"],
	"normal mode": [],
	"drinking game": [],
	"new adventure": [],
	"continue": [],
	"tutorial": [],
	"jump in": []
}

var menu_levels = {
	1: ["main"],
	2: ["quickgame", "adventure", "extras"],
	3: ["normal mode", "drinking game", "new adventure", "continue", "tutorial"],
	4: ["jump in"]
}

var menu_confirms = {
	"normal mode": "Start a game in normal mode?",
	"drinking game": "Start a game with drinking rules?",
	"new adventure": "Start a new adventure?",
	"continue": "Continue adventure?",
	"tutorial": "Start tutorial?",
	"exit": "Exit game?"
}

var target_menu: Array = menus["main"]:
	set(new_target):
		target_menu = new_target
		Player.update_menu_sprite()

var menu_name: String = "main"


func get_menu_level():
	for level in menu_levels:
		if menu_name in menu_levels[level]:
			return level


func get_upper_menu():
	if get_tree():
		
		for m in menus:
			if menu_name in menus[m]:
				menu_name = m


func go_to_menu(menu_function):
	if get_tree():
		
		menu_name = menu_function
		target_menu = menus[menu_function]
