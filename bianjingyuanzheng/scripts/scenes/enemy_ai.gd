class_name EnemyAI
extends RefCounted

func decide_action(monster: MonsterData, current_hp: int, max_hp: int, pending_charge: SkillData) -> Dictionary:
    if pending_charge != null:
        return {"action": "release_charge", "skill": pending_charge}

    var hp_ratio := float(current_hp) / float(max_hp)

    if hp_ratio < 0.3 and monster.charge_skills.size() > 0 and randf() < 0.5:
        return {"action": "charge", "skill": monster.charge_skills[randi() % monster.charge_skills.size()]}

    if monster.charge_skills.size() > 0 and randf() < 0.2:
        return {"action": "charge", "skill": monster.charge_skills[randi() % monster.charge_skills.size()]}

    if monster.instant_skills.is_empty():
        return {"action": "instant", "skill": null}
    return {"action": "instant", "skill": monster.instant_skills[randi() % monster.instant_skills.size()]}
