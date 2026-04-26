extends Node2D

@export var move_speed: float = 200.0

var region_config: RegionConfig = null
var weather_controller: WeatherController = null
var current_weather: String = "clear"

func _ready() -> void:
	region_config = load("res://resources/regions/volcano_region.tres")

	weather_controller = WeatherController.new()
	weather_controller.weather_table = region_config.weather_table
	add_child(weather_controller)

	EventBus.weather_changed.connect(_on_weather_changed)

	# Initialize monster spawners
	for spawner in $Monsters.get_children():
		if spawner is MonsterSpawner:
			spawner.initialize(region_config, current_weather)

	_update_hud()
	EventBus.region_entered.emit("volcano")

	# Wire trigger signals
	$Triggers/ExitTrigger.body_entered.connect(_on_exit_entered)
	$Triggers/BossLairTrigger.body_entered.connect(_on_boss_lair_entered)

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

func _on_exit_entered(_body: Node2D) -> void:
	EventBus.region_exited.emit("volcano")
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")

func _on_boss_lair_entered(_body: Node2D) -> void:
	var boss_res := load("res://resources/monsters/burning_rhino_king.tres") as MonsterData
	BattleConfig.pending_monster = boss_res
	BattleConfig.pending_monster_instance = {
		"current_hp": boss_res.base_hp,
		"current_atk": boss_res.base_atk,
		"current_def": boss_res.base_def,
		"current_spd": boss_res.base_spd,
		"current_res": boss_res.base_res
	}
	BattleConfig.from_region = region_config.region_id
	BattleConfig.current_weather = current_weather
	get_tree().change_scene_to_file("res://scenes/battle_scene.tscn")
