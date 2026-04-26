# scripts/autoload/save_manager.gd
extends Node

const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 3

func save_game(slot: int, data: Dictionary) -> bool:
	if slot < 0 or slot >= MAX_SLOTS:
		return false

	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var file := FileAccess.open(SAVE_DIR + "save_%d.json" % slot, FileAccess.WRITE)
	if file == null:
		return false

	data["save_version"] = 1
	data["timestamp"] = Time.get_unix_time_from_system()
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

	EventBus.game_saved.emit(slot)
	return true

func load_game(slot: int) -> Dictionary:
	var path := SAVE_DIR + "save_%d.json" % slot
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()

	if err != OK:
		return {}

	var data: Dictionary = json.get_data()
	EventBus.game_loaded.emit(slot)
	return data

func delete_save(slot: int) -> void:
	var path := SAVE_DIR + "save_%d.json" % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

func save_exists(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_DIR + "save_%d.json" % slot)

func get_save_meta(slot: int) -> Dictionary:
	var data := load_game(slot)
	if data.is_empty():
		return {}
	return {
		"level": data.get("player", {}).get("level", 1),
		"play_time": data.get("play_time_seconds", 0),
		"scene": data.get("current_scene", ""),
		"timestamp": data.get("timestamp", 0)
	}
