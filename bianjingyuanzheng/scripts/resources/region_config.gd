class_name RegionConfig
extends Resource

@export var region_id: String = ""
@export var display_name: String = ""
@export var scene_path: String = ""
@export var difficulty: int = 1
@export var monster_pool: Array[String] = []
@export var elite_monsters: Array[String] = []
@export var boss_monster: String = ""
@export var weather_table: WeatherTable = null
@export var bgm: AudioStream = null
@export var entry_world_position: Vector2 = Vector2.ZERO
