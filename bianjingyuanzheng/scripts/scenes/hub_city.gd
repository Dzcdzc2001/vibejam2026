extends Node2D

func _ready() -> void:
	_update_hud()
	SaveManager.save_game(0, _build_save_data())
	$Actions/ForgeButton.pressed.connect(_on_forge_pressed)
	$Actions/LibraryButton.pressed.connect(_on_library_pressed)
	$Actions/PalaceButton.pressed.connect(_on_palace_pressed)
	$Actions/ExpeditionButton.pressed.connect(_on_expedition_pressed)

func _update_hud() -> void:
	var p := PlayerData.get_instance()
	$HUD/LevelLabel.text = "Lv.%d %s" % [p.level, p.player_name]
	$HUD/GoldLabel.text = "金币: %d" % p.gold

func _on_forge_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/forge_ui.tscn")

func _on_library_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/bestiary_ui.tscn")

func _on_palace_pressed() -> void:
	SaveManager.save_game(0, _build_save_data())

func _on_expedition_pressed() -> void:
	PlayerData.get_instance().current_region_scene = ""
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")

func _build_save_data() -> Dictionary:
	return {
		"player": PlayerData.get_instance().to_dict(),
		"current_scene": "res://scenes/hub_city.tscn",
		"play_time_seconds": 0
	}
