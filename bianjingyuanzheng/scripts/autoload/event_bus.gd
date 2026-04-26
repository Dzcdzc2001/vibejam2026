# scripts/autoload/event_bus.gd
extends Node

# -- 战斗信号 --
signal battle_started(monster_id: String)
signal battle_won(monster_id: String, drops: Dictionary)
signal battle_lost(monster_id: String)
signal qte_triggered(question_id: int, difficulty: int)
signal qte_success(counter_damage: float)
signal qte_failed(incoming_damage: float)
signal skill_parsed(input_text: String, creativity: int)
signal post_battle_reveal(extinct_species_id: String)

# -- 玩家与成长信号 --
signal player_leveled_up(new_level: int)
signal bestiary_unlocked(species_id: String)
signal bestiary_milestone(count: int)
signal weapon_forged(weapon_id: String)
signal weapon_enchanted(enchant_id: String)
signal territory_conquered(region_id: String)

# -- 世界与系统信号 --
signal weather_changed(weather_id: String)
signal region_entered(region_id: String)
signal region_exited(region_id: String)
signal item_obtained(item_id: String, count: int)
signal game_saved(slot: int)
signal game_loaded(slot: int)
