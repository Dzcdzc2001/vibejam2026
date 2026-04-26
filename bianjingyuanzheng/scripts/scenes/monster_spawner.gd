class_name MonsterSpawner
extends Area2D

@export var spawn_radius: float = 150.0
@export var max_monsters: int = 3
@export var respawn_time: float = 30.0

var region_config: RegionConfig = null
var current_weather: String = "clear"
var active_monsters: Array[Node2D] = []
var _battle_in_progress: bool = false

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
	var actor_tex := load("res://assets/placeholder/actor_32x32.png")
	if actor_tex == null:
		# Fallback: visible colored rectangle if texture missing
		var rect := ColorRect.new()
		rect.size = Vector2(32, 32)
		rect.position = Vector2(-16, -16)
		rect.color = Color.ORANGE_RED
		rect.scale = Vector2(3.0, 3.0)
		monster_node.add_child(rect)
		match monster_res.monster_type:
			1: rect.color = Color.ORANGE
			2: rect.color = Color.PURPLE
	else:
		sprite.texture = actor_tex
		sprite.region_enabled = true
		sprite.hframes = 4
		match monster_res.monster_type:
			1:
				sprite.modulate = Color.ORANGE
				sprite.frame = 2  # elite: orange diamond
			2:
				sprite.modulate = Color.PURPLE
				sprite.frame = 3  # boss: purple star
			_:
				sprite.modulate = Color.ORANGE_RED
				sprite.frame = 1  # normal: red circle
		sprite.scale = Vector2(3.0, 3.0)
		monster_node.add_child(sprite)

	var collision := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = Vector2(32, 32)
	collision.shape = rect_shape
	monster_node.add_child(collision)

	var angle := randf_range(0, TAU)
	var distance := randf_range(0, spawn_radius)
	monster_node.position = position + Vector2(cos(angle), sin(angle)) * distance

	var ai_script := load("res://scripts/scenes/monster_ai.gd")
	if ai_script != null:
		monster_node.set_script(ai_script)
	monster_node.set("monster_data", monster_res)

	monster_node.body_entered.connect(_on_monster_touched.bind(monster_res))

	get_parent().add_child(monster_node)
	active_monsters.append(monster_node)

func _on_monster_touched(body: Node2D, monster_data: MonsterData) -> void:
	if body.name != "PlayerCharacter":
		return
	if _battle_in_progress:
		return
	_battle_in_progress = true

	if region_config == null:
		return

	BattleConfig.pending_monster = monster_data
	BattleConfig.pending_monster_instance = {
		"current_hp": monster_data.base_hp,
		"current_atk": monster_data.base_atk,
		"current_def": monster_data.base_def,
		"current_spd": monster_data.base_spd,
		"current_res": monster_data.base_res
	}
	BattleConfig.from_region = region_config.region_id if region_config else "unknown"
	BattleConfig.current_weather = current_weather
	get_tree().change_scene_to_file("res://scenes/battle_scene.tscn")
