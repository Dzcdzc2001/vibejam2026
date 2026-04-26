class_name SkillParser
extends RefCounted

var keyword_db: SkillKeywordDB = null

func _init() -> void:
    keyword_db = load("res://resources/keywords/skill_keyword_db.tres")

func parse_creativity(input_text: String, region_type: String, weapon_type: String, monster_element: String) -> int:
    if input_text.is_empty():
        return 20

    for word in keyword_db.easter_egg_words:
        if input_text.contains(word):
            return keyword_db.easter_egg_words[word]

    var score: int = 20
    score += _score_theme_fit(input_text, region_type, weapon_type, monster_element)
    score += _score_creativity(input_text)
    score += _score_literal(input_text)
    score += randi_range(-5, 5)
    return clampi(score, 0, 100)

func _score_theme_fit(text: String, region: String, weapon: String, element: String) -> int:
    var score := 0
    for kw in keyword_db.get_region_keywords(region):
        if text.contains(kw): score += 15; break
    for kw in keyword_db.get_weapon_keywords(weapon):
        if text.contains(kw): score += 10; break
    for kw in keyword_db.get_elemental_keywords(element):
        if text.contains(kw): score += 15; break
    return min(score, 40)

func _score_creativity(text: String) -> int:
    var score := 10
    if text.length() >= 2: score += 5
    if text.length() >= 4: score += 5
    if text.contains("之"): score += 5
    if text.contains("的"): score += 3
    var has_chinese := false
    for c in text:
        if c.unicode_at(0) > 127: has_chinese = true; break
    if has_chinese: score += 5
    return min(score, 30)

func _score_literal(text: String) -> int:
    var score := 10
    for w in ["斩", "击", "破", "裂", "刺", "射", "冲", "劈", "砍", "碎", "崩", "震", "突", "袭", "轰"]:
        if text.contains(w): score += 5; break
    for w in ["星", "冰", "焰", "火", "光", "影", "暗", "风", "雷", "月", "日", "天", "地", "海", "山"]:
        if text.contains(w): score += 5; break
    return min(score, 20)
