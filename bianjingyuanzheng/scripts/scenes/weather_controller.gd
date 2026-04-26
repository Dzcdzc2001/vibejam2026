class_name WeatherController
extends Node

@export var weather_table: WeatherTable = null
var current_weather: WeatherEntry = null
var _weather_timer: float = 300.0

func _ready() -> void:
	_roll_weather()

func _process(delta: float) -> void:
	_weather_timer -= delta
	if _weather_timer <= 0:
		_roll_weather()
		_weather_timer = 300.0

func _roll_weather() -> void:
	if weather_table == null or weather_table.entries.is_empty():
		return

	# 60% chance to keep current weather
	if current_weather != null and randf() < 0.6:
		return

	var total_weight: float = 0.0
	for entry in weather_table.entries:
		total_weight += entry.base_weight + entry.night_bonus

	var roll := randf() * total_weight
	var cumulative: float = 0.0
	for entry in weather_table.entries:
		cumulative += entry.base_weight + entry.night_bonus
		if roll <= cumulative:
			current_weather = entry
			break

	if current_weather != null:
		EventBus.weather_changed.emit(current_weather.weather_id)
