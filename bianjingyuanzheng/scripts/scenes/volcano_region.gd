extends Node2D

@export var move_speed: float = 200.0

var region_config: RegionConfig = null
var weather_controller: WeatherController = null
var current_weather: String = "clear"

func _ready() -> void:
	region_config = load("res://resources/regions/volcano_region.tres")

	weather_controller = WeatherController.new()
	if region_config != null and region_config.weather_table != null:
		weather_controller.weather_table = region_config.weather_table
	else:
		weather_controller.weather_table = _create_default_weather_table()
	add_child(weather_controller)

	EventBus.weather_changed.connect(_on_weather_changed)

	# Initialize monster spawners
	for spawner in $Monsters.get_children():
		if spawner is MonsterSpawner and region_config != null:
			spawner.initialize(region_config, current_weather)

	_update_hud()
	EventBus.region_entered.emit("volcano")

	# Wire trigger signals
	$Triggers/ExitTrigger.body_entered.connect(_on_exit_entered)
	$Triggers/BossLairTrigger.body_entered.connect(_on_boss_lair_entered)
	$HUD/BackToHubButton.pressed.connect(_on_back_to_hub_pressed)

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	$PlayerCharacter.velocity = input * move_speed
	$PlayerCharacter.move_and_slide()

func _on_weather_changed(weather_id: String) -> void:
	current_weather = weather_id
	_update_hud()

func _update_hud() -> void:
	var p := PlayerData.get_instance()
	$HUD/RegionLabel.text = region_config.display_name if region_config else "火山地带"
	$HUD/WeatherLabel.text = "天气: %s" % current_weather
	$HUD/PlayerLabel.text = "Lv.%d HP:%d" % [p.level, p.base_hp]

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		_return_to_hub()

func _on_back_to_hub_pressed() -> void:
	_return_to_hub()

func _return_to_hub() -> void:
	EventBus.region_exited.emit("volcano")
	get_tree().change_scene_to_file("res://scenes/hub_city.tscn")

func _on_exit_entered(_body: Node2D) -> void:
	EventBus.region_exited.emit("volcano")
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")

func _on_boss_lair_entered(_body: Node2D) -> void:
	var boss_res := load("res://resources/monsters/burning_rhino_king.tres") as MonsterData
	if boss_res == null:
		return
	BattleConfig.pending_monster = boss_res
	BattleConfig.pending_monster_instance = {
		"current_hp": boss_res.base_hp,
		"current_atk": boss_res.base_atk,
		"current_def": boss_res.base_def,
		"current_spd": boss_res.base_spd,
		"current_res": boss_res.base_res
	}
	BattleConfig.from_region = region_config.region_id if region_config else "volcano"
	BattleConfig.current_weather = current_weather
	get_tree().change_scene_to_file("res://scenes/battle_scene.tscn")

func _create_default_weather_table() -> WeatherTable:
	var table := WeatherTable.new()
	table.region_id = "volcano"

	var entries: Array[WeatherEntry] = []

	var clear_entry := WeatherEntry.new()
	clear_entry.weather_id = "clear"
	clear_entry.display_name = "晴天"
	clear_entry.base_weight = 25.0
	entries.append(clear_entry)

	var eruption := WeatherEntry.new()
	eruption.weather_id = "volcano_eruption"
	eruption.display_name = "火山喷发"
	eruption.base_weight = 10.0
	eruption.monster_atk_mod = 1.3
	eruption.monster_def_mod = 1.2
	eruption.player_spd_mod = 0.8
	eruption.player_hp_drain = 5.0
	eruption.rare_spawn_bonus = 0.2
	eruption.creativity_bonus = 2
	entries.append(eruption)

	var ash := WeatherEntry.new()
	ash.weather_id = "ash_storm"
	ash.display_name = "灰烬风暴"
	ash.base_weight = 15.0
	ash.monster_atk_mod = 1.1
	ash.monster_def_mod = 1.5
	ash.player_spd_mod = 0.6
	ash.player_hp_drain = 3.0
	entries.append(ash)

	var geo := WeatherEntry.new()
	geo.weather_id = "geothermal"
	geo.display_name = "地热活跃"
	geo.base_weight = 12.0
	geo.monster_atk_mod = 1.2
	geo.rare_spawn_bonus = 0.3
	geo.creativity_bonus = 3
	entries.append(geo)

	var aurora := WeatherEntry.new()
	aurora.weather_id = "volcano_aurora"
	aurora.display_name = "极光火山"
	aurora.base_weight = 8.0
	aurora.night_bonus = 1.0
	aurora.monster_atk_mod = 0.8
	aurora.monster_def_mod = 0.9
	aurora.player_spd_mod = 1.2
	aurora.rare_spawn_bonus = 0.5
	aurora.creativity_bonus = 5
	entries.append(aurora)

	table.entries = entries
	return table
