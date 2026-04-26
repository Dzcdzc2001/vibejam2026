class_name PostBattleReveal
extends RefCounted

var _extinct_db: ExtinctSpeciesDB = null

func _get_db() -> ExtinctSpeciesDB:
    if _extinct_db == null:
        _extinct_db = load("res://resources/bestiary/extinct_species_db.tres")
    return _extinct_db

func get_species_entry(species_id: String) -> ExtinctSpeciesEntry:
    var db := _get_db()
    if db == null: return null
    for entry in db.entries:
        if entry.species_id == species_id: return entry
    return null

func get_reveal_data(monster: MonsterData) -> Dictionary:
    var entry := get_species_entry(monster.extinct_species_id)
    if entry == null: return {}
    return {
        "common_name": entry.common_name,
        "scientific_name": entry.scientific_name,
        "extinct_year": entry.extinct_year,
        "extinct_cause": entry.extinct_cause,
        "cause_detail": entry.cause_detail,
        "warning_message": entry.warning_message,
        "habitat": entry.habitat,
        "diet": entry.diet,
        "habitat_detail": entry.habitat_detail if monster.monster_type >= 1 else "",
        "diet_detail": entry.diet_detail if monster.monster_type >= 1 else "",
        "human_timeline": entry.human_timeline if monster.monster_type == 2 else "",
        "monster_type": monster.monster_type
    }
