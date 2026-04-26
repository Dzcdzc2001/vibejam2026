extends Control

func _ready() -> void:
	$VBoxContainer/ContinueButton.disabled = not SaveManager.save_exists(0)
	$VBoxContainer/NewGameButton.pressed.connect(_on_new_game_pressed)
	$VBoxContainer/ContinueButton.pressed.connect(_on_continue_pressed)
	$VBoxContainer/BestiaryButton.pressed.connect(_on_bestiary_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed() -> void:
	PlayerData.get_instance().from_dict({})
	get_tree().change_scene_to_file("res://scenes/hub_city.tscn")

func _on_continue_pressed() -> void:
	var data := SaveManager.load_game(0)
	if not data.is_empty():
		PlayerData.get_instance().from_dict(data.get("player", {}))
		var scene := data.get("current_scene", "res://scenes/hub_city.tscn")
		get_tree().change_scene_to_file(scene)

func _on_bestiary_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/bestiary_ui.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
