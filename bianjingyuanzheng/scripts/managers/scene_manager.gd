class_name SceneManager
extends Node

func switch_scene(current_node: Node, scene_path: String) -> void:
	current_node.get_tree().change_scene_to_file(scene_path)

func switch_to_battle(current_node: Node, monster_data: MonsterData) -> void:
	BattleConfig.pending_monster = monster_data
	current_node.get_tree().change_scene_to_file("res://scenes/battle_scene.tscn")

func return_from_battle(current_node: Node) -> void:
	var player: PlayerData = PlayerData.get_instance()
	var target := player.current_region_scene if not player.current_region_scene.is_empty() else "res://scenes/world_map.tscn"
	current_node.get_tree().change_scene_to_file(target)
