class_name SkillKeywordDB
extends Resource

@export var region_keywords: Dictionary = {
    "volcano": ["熔岩", "火焰", "炽热", "岩浆", "火山", "燃烧", "焦土", "灰烬", "地核", "硫磺"],
    "glacier": ["冰封", "寒冰", "极地", "冰霜", "暴雪", "冻土", "冰晶", "凛冬", "冰川", "冻雨"]
}

@export var weapon_keywords: Dictionary = {
    "sword": ["斩", "剑", "刃", "劈", "砍"],
    "bow": ["射", "箭", "弓", "羽", "矢"],
    "staff": ["咒", "术", "魔法", "元素", "召唤"],
    "shield": ["盾", "反", "壁垒", "守护", "坚"]
}

@export var elemental_keywords: Dictionary = {
    "fire": ["火", "炎", "焰", "灼", "焚"],
    "ice": ["冰", "霜", "冻", "寒", "雪"],
    "physical": ["碎", "破", "裂", "崩", "震"]
}

@export var easter_egg_words: Dictionary = {
    "渡渡": 100, "犀牛": 100, "旅鸽": 100, "袋狼": 100,
    "灭绝": 95, "新生": 95, "涅槃": 95, "救赎": 95,
    "曙光": 90, "希望": 90, "远征": 90, "守护": 90
}

func get_region_keywords(region_type: String) -> Array:
    return region_keywords.get(region_type, [])

func get_weapon_keywords(weapon_type: String) -> Array:
    return weapon_keywords.get(weapon_type, [])

func get_elemental_keywords(element: String) -> Array:
    return elemental_keywords.get(element, [])

func check_easter_egg(word: String) -> int:
    return easter_egg_words.get(word, 0)
