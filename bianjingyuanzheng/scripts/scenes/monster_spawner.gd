class_name MonsterSpawner
extends Area2D

@export var spawn_radius: float = 150.0
@export var max_monsters: int = 3
@export var respawn_time: float = 30.0

var region_config: RegionConfig = null
var current_weather: String = "clear"
var active_monsters: Array[Node2D] = []

func initialize(config: RegionConfig, weather: String) -> void:
	region_config = config
	current_weather = weather
	_spawn_initial_monsters()

func _spawn_initial_monsters() -> void:
	for i in range(max_monsters):
		_spawn_one_monster()

func _spawn_one_monster() -> void:
	if region_config == null:
		return
	var pool := region_config.monster_pool
	if pool.is_empty():
		return
	var chosen_id := pool[randi() % pool.size()]
	var monster_res := load("res://resources/monsters/%s.tres" % chosen_id) as MonsterData
	if monster_res == null:
		return

	var monster_node := Area2D.new()
	monster_node.name = "Monster_%s" % chosen_id

	var sprite := Sprite2D.new()
	sprite.texture = load("res://assets/placeholder/actor_16x16.png")
	match monster_res.monster_type:
		1: sprite.modulate = Color.ORANGE
		2: sprite.modulate = Color.PURPLE
		_: sprite.modulate = Color.ORANGE_RED
	monster_node.add_child(sprite)

	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	collision.shape = rect
	monster_node.add_child(collision)

	var angle := randf_range(0, TAU)
	var distance := randf_range(0, spawn_radius)
	monster_node.position = position + Vector2(cos(angle), sin(angle)) * distance

	monster_node.set_script(load("res://scripts/scenes/monster_ai.gd"))
	monster_node.set("monster_data", monster_res)

	monster_node.body_entered.connect(_on_monster_touched.bind(monster_res))

	get_parent().add_child(monster_node)
	active_monsters.append(monster_node)

func _on_monster_touched(body: Node2D, monster_data: MonsterData) -> void:
	if body.name != "PlayerCharacter":
		return
	BattleConfig.pending_monster = monster_data
	BattleConfig.pending_monster_instance = {
		"current_hp": monster_data.base_hp,
		"current_atk": monster_data.base_atk,
		"current_def": monster_data.base_def,
		"current_spd": monster_data.base_spd,
		"current_res": monster_data.base_res
	}
	BattleConfig.from_region = region_config.region_id
	BattleConfig.current_weather = current_weather
	get_tree().change_scene_to_file("res://scenes/battle_scene.tscn")
